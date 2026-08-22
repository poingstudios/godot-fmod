# Godot FMOD

[![CI - Build Verification](https://github.com/poingstudios/godot-fmod/actions/workflows/ci.yml/badge.svg)](https://github.com/poingstudios/godot-fmod/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Godot FMOD** is an official-grade, pure C++ GDExtension plugin for Godot 4.x providing direct, high-performance bindings to the **FMOD Studio** and **FMOD Core** APIs (FMOD 2.03.x series), along with high-level spatial audio nodes.

---

## Features

- **Direct 1:1 FMOD API Wrapper**: Full access to FMOD Studio (`FmodServer`, `FmodEventInstance`, `FmodEventDescription`, `FmodBank`, `FmodBus`, `FmodVCA`) and FMOD Core systems directly in GDScript and C#.
- **High-Level Spatial Nodes**:
  - `FmodEventEmitter3D` / `FmodEventEmitter2D`: 3D/2D spatial audio emitters with automatic velocity calculation and parameter modulation.
  - `FmodListener3D` / `FmodListener2D`: Spatial listener nodes tracking cameras and players.
- **Fast One-Shots**: Fire-and-forget 2D/3D event playback with `FmodServer.play_one_shot()`.
- **Pure GDExtension**: Zero GDScript overhead and direct native execution.
- **Multiplatform Support**: macOS (Apple Silicon & Intel), Linux (x86_64), Windows (x86_64 & arm64).

---

## Installation

1. Download the latest `godot-fmod-v*.zip` from [Releases](https://github.com/poingstudios/godot-fmod/releases).
2. Extract the `addons/godot_fmod` directory into your project's `res://addons/` folder.
3. Enable the plugin in **Project Settings -> Plugins**.

---

## Quick Start (GDScript)

### 1. Load Banks
```gdscript
func _ready() -> void:
	FmodServer.load_bank("res://banks/Desktop/Master.bank")
	FmodServer.load_bank("res://banks/Desktop/Master.strings.bank")
```

### 2. Play One-Shot Sound
```gdscript
# Simple 2D one-shot
FmodServer.play_one_shot("event:/SFX/Explosion")

# 3D one-shot at a specific position
FmodServer.play_one_shot_3d("event:/SFX/Gunshot", global_position)
```

### 3. Using Event Instances
```gdscript
var event_instance: FmodEventInstance = null

func _ready() -> void:
	event_instance = FmodServer.create_event_instance("event:/Music/BattleTheme")
	event_instance.set_parameter_by_name("Intensity", 0.5)
	event_instance.start()

func _exit_tree() -> void:
	if event_instance != null:
		event_instance.stop(FmodServer.STOP_ALLOWFADEOUT)
		event_instance.release()
```

---

## Building from Source

### Prerequisites
- Godot 4.x
- SCons (`pip install scons`)
- C++17 compiler (Clang / GCC / MSVC)
- [FMOD Engine 2.03.x SDK](https://fmod.com/download)

### Setup & Compilation
1. Clone repository with submodules:
   ```bash
   git clone --recursive https://github.com/poingstudios/godot-fmod.git
   cd godot-fmod
   ```
2. Configure FMOD SDK:
   ```bash
   ./scripts/setup_fmod_sdk.sh /path/to/fmod/sdk
   ```
3. Build for your host platform:
   ```bash
   ./scripts/build_local.sh
   ```

---

## License

This project is licensed under the [MIT License](LICENSE).  
FMOD Engine is proprietary software by Firelight Technologies Pty Ltd. Please refer to [FMOD Licensing](https://www.fmod.com/licensing) for commercial terms.