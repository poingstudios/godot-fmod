#!/usr/bin/env python3
# MIT License
# Copyright (c) 2026 Poing Studios

import base64
import glob
import json
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
import warnings

warnings.filterwarnings("ignore")

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

# 1. Secure Credential Retrieval
user = os.environ.get("FMOD_USER") or os.environ.get("FMOD_USERNAME") or os.environ.get("FMODUSER")
password = os.environ.get("FMOD_PASSWORD") or os.environ.get("FMOD_PASS") or os.environ.get("FMODPASS")
platform = sys.argv[1].lower() if len(sys.argv) > 1 else ("macos" if sys.platform == "darwin" else "windows" if sys.platform == "win32" else "linux")
version = os.environ.get("FMOD_VERSION", "20306")

if not user or not password:
    print("Error: Missing FMOD credentials in environment variables (FMOD_USER, FMOD_PASSWORD).")
    sys.exit(1)

PLATFORMS = {
    "macos": ("files/fmodstudio/api/Mac/", f"fmodstudioapi{version}mac-installer.dmg"),
    "linux": ("files/fmodstudio/api/Linux/", f"fmodstudioapi{version}linux.tar.gz"),
    "windows": ("files/fmodstudio/api/Windows/", f"fmodstudioapi{version}win-installer.exe"),
    "android": ("files/fmodstudio/api/Android/", f"fmodstudioapi{version}android.tar.gz"),
    "ios": ("files/fmodstudio/api/iOS/", f"fmodstudioapi{version}ios-installer.dmg"),
}

if platform not in PLATFORMS:
    print(f"Error: Unsupported platform '{platform}'")
    sys.exit(1)

api_path, filename = PLATFORMS[platform]
sdk_dest = os.path.abspath("platforms/gdextension/thirdparty/fmod")
bin_dest = os.path.abspath("platforms/godot_editor/addons/fmod/bin")

os.makedirs(f"{sdk_dest}/api", exist_ok=True)
os.makedirs(bin_dest, exist_ok=True)


def download_with_retry(download_url: str, output_file: str, max_retries: int = 5) -> None:
    """Downloads a file with automatic resume and retry on socket resets."""
    for attempt in range(1, max_retries + 1):
        try:
            req_headers = {
                "User-Agent": USER_AGENT,
                "Accept": "*/*",
                "Connection": "keep-alive",
            }
            existing_size = os.path.getsize(output_file) if os.path.exists(output_file) else 0
            if existing_size > 0:
                req_headers["Range"] = f"bytes={existing_size}-"

            req = urllib.request.Request(download_url, headers=req_headers)
            with urllib.request.urlopen(req, timeout=45) as resp:
                is_partial = getattr(resp, "status", None) == 206 or getattr(resp, "code", None) == 206
                open_mode = "ab" if is_partial and existing_size > 0 else "wb"

                with open(output_file, open_mode) as f:
                    while True:
                        chunk = resp.read(65536)
                        if not chunk:
                            break
                        f.write(chunk)
            return
        except Exception as err:
            if attempt == max_retries:
                raise RuntimeError(f"Download failed after {max_retries} attempts: {err}") from err
            wait_time = attempt * 2
            print(f"    Notice: Connection reset. Resuming download in {wait_time}s (attempt {attempt}/{max_retries})...")
            time.sleep(wait_time)


# 2. Authenticate with FMOD API
print(">>> Authenticating with fmod.com...")
auth_header = "Basic " + base64.b64encode(f"{user}:{password}".encode("utf-8")).decode("ascii")
auth_req = urllib.request.Request(
    "https://www.fmod.com/api-login",
    data=b"",
    headers={"Authorization": auth_header, "User-Agent": USER_AGENT},
    method="POST",
)

try:
    with urllib.request.urlopen(auth_req, timeout=30) as resp:
        token = json.loads(resp.read().decode("utf-8")).get("token")
except Exception:
    print("Error: Authentication with fmod.com failed. Verify credentials.")
    sys.exit(1)

if not token:
    print("Error: Authentication token missing in response.")
    sys.exit(1)

# 3. Resolve Download Link
query = urllib.parse.urlencode({"path": api_path, "filename": filename, "user": user})
dl_req = urllib.request.Request(
    f"https://www.fmod.com/api-get-download-link?{query}",
    headers={"Authorization": f"Bearer {token}", "User-Agent": USER_AGENT},
    method="GET",
)

try:
    with urllib.request.urlopen(dl_req, timeout=30) as resp:
        download_url = json.loads(resp.read().decode("utf-8")).get("url")
except Exception:
    print("Error: Failed to obtain authorized download URL.")
    sys.exit(1)

if not download_url:
    print("Error: Download URL missing in response.")
    sys.exit(1)

# 4. Download & Extraction in isolated temporary directory
with tempfile.TemporaryDirectory(prefix="fmod_provision_") as temp_dir:
    download_target = os.path.join(temp_dir, filename)
    print(f">>> Downloading {platform} SDK package...")
    download_with_retry(download_url, download_target)

    print(f">>> Extracting {platform} FMOD SDK...")
    extract_dir = os.path.join(temp_dir, "extracted")
    os.makedirs(extract_dir, exist_ok=True)

    if platform in ("macos", "ios"):
        mount_point = os.path.join(temp_dir, "dmg_mount")
        os.makedirs(mount_point, exist_ok=True)
        subprocess.run(["hdiutil", "attach", download_target, "-mountpoint", mount_point, "-nobrowse", "-quiet"], check=True)
        try:
            for path in glob.glob(f"{mount_point}/**/api", recursive=True):
                shutil.copytree(path, f"{sdk_dest}/api", dirs_exist_ok=True)
                break
        finally:
            subprocess.run(["hdiutil", "detach", mount_point, "-quiet"])

    elif platform in ("linux", "android"):
        with tarfile.open(download_target, "r:gz") as tar:
            if hasattr(tarfile, "data_filter"):
                tar.extractall(extract_dir, filter="data")
            else:
                tar.extractall(extract_dir)

        for path in glob.glob(f"{extract_dir}/**/api", recursive=True):
            shutil.copytree(path, f"{sdk_dest}/api", dirs_exist_ok=True)
            break

    elif platform == "windows":
        seven_zip = shutil.which("7z") or r"C:\Program Files\7-Zip\7z.exe"
        subprocess.run([seven_zip, "x", download_target, f"-o{extract_dir}", "-y"], check=True)
        for path in glob.glob(f"{extract_dir}/**/api", recursive=True):
            shutil.copytree(path, f"{sdk_dest}/api", dirs_exist_ok=True)
            break

# 5. Deploy runtime libraries to addons/fmod/bin/
print(">>> Deploying runtime libraries to addons/fmod/bin/...")
if platform == "macos":
    for lib in glob.glob(f"{sdk_dest}/api/core/lib/libfmod*.dylib") + glob.glob(f"{sdk_dest}/api/studio/lib/libfmodstudio*.dylib"):
        shutil.copy2(lib, bin_dest)
elif platform == "linux":
    for lib in glob.glob(f"{sdk_dest}/api/core/lib/x86_64/libfmod*.so*") + glob.glob(f"{sdk_dest}/api/studio/lib/x86_64/libfmodstudio*.so*"):
        shutil.copy2(lib, bin_dest)
elif platform == "windows":
    for lib in glob.glob(f"{sdk_dest}/api/core/lib/x64/fmod.dll") + glob.glob(f"{sdk_dest}/api/studio/lib/x64/fmodstudio.dll"):
        shutil.copy2(lib, bin_dest)

print(">>> FMOD SDK setup complete! Ready to compile.")
