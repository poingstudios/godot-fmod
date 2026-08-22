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
import urllib.error
import urllib.parse
import urllib.request

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

# 2. Authenticate with FMOD API (using pure standard library urllib)
print(">>> Authenticating with fmod.com...")
auth_header = "Basic " + base64.b64encode(f"{user}:{password}".encode("utf-8")).decode("ascii")
auth_req = urllib.request.Request(
    "https://www.fmod.com/api-login",
    data=b"",
    headers={"Authorization": auth_header, "User-Agent": "GodotFmodProvisioner/1.0"},
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
    headers={"Authorization": f"Bearer {token}", "User-Agent": "GodotFmodProvisioner/1.0"},
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
    try:
        file_req = urllib.request.Request(download_url, headers={"User-Agent": "GodotFmodProvisioner/1.0"})
        with urllib.request.urlopen(file_req, timeout=120) as stream, open(download_target, "wb") as f:
            while True:
                chunk = stream.read(65536)
                if not chunk:
                    break
                f.write(chunk)
    except Exception as e:
        print(f"Error: Download interrupted: {e}")
        sys.exit(1)

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
            def is_within_directory(directory: str, target: str) -> bool:
                abs_directory = os.path.abspath(directory)
                abs_target = os.path.abspath(target)
                return os.path.commonprefix([abs_directory, abs_target]) == abs_directory

            def safe_extract(tar_obj: tarfile.TarFile, path: str = "."):
                for member in tar_obj.getmembers():
                    member_path = os.path.join(path, member.name)
                    if not is_within_directory(path, member_path):
                        raise RuntimeError(f"Attempted Path Traversal: {member.name}")
                tar_obj.extractall(path)

            safe_extract(tar, extract_dir)

        for path in glob.glob(f"{extract_dir}/**/api", recursive=True):
            shutil.copytree(path, f"{sdk_dest}/api", dirs_exist_ok=True)
            break

    elif platform == "windows":
        subprocess.run(["7z", "x", download_target, f"-o{extract_dir}", "-y"], check=True)
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
