# Godot FMOD — AGENTS.md

AI assistant context for the godot-fmod repository. Read this before making changes.

---

## Project Overview

**Godot FMOD** is an official-grade, high-performance GDExtension plugin for Godot 4.x that provides a direct, idiomatic C++ wrapper around the **FMOD Studio** and **FMOD Core** APIs (targeting the FMOD 2.03.x series), accompanied by high-level Godot SceneTree nodes for rapid spatial audio workflows.

- **Engine:** Godot 4.x
- **Primary Language:** C++17 (Pure GDExtension)
- **Dependencies:** `godot-cpp` (submodule), `FMOD Engine SDK 2.03.x` (FMOD Studio + Core API)
- **Supported OS Platforms:** macOS (Apple Silicon arm64 & Intel x86_64), Linux (x86_64), Windows (x86_64 & arm64)

---

## Architecture & Directory Layout

```
godot-fmod/
├── platforms/
│   ├── gdextension/         # C++ GDExtension source & SCons build system
│   │   ├── godot-cpp/       # Godot C++ bindings submodule
│   │   ├── src/             # Native C++ source files
│   │   │   ├── register_types.cpp / .h  # Entry point & ClassDB registrations
│   │   │   ├── fmod_server.cpp / .h     # Singleton engine manager (lifecycle, banks, bus, listener)
│   │   │   ├── studio/                  # FMOD Studio API Wrappers
│   │   │   │   ├── fmod_bank.cpp / .h
│   │   │   │   ├── fmod_event_description.cpp / .h
│   │   │   │   ├── fmod_event_instance.cpp / .h
│   │   │   │   ├── fmod_bus.cpp / .h
│   │   │   │   └── fmod_vca.cpp / .h
│   │   │   ├── nodes/                   # High-Level Godot SceneTree Nodes
│   │   │   │   ├── fmod_event_emitter_2d.cpp / .h
│   │   │   │   ├── fmod_event_emitter_3d.cpp / .h
│   │   │   │   ├── fmod_listener_2d.cpp / .h
│   │   │   │   └── fmod_listener_3d.cpp / .h
│   │   │   └── utils/                   # Coordinate conversions & error checking
│   │   │       ├── fmod_types.h
│   │   │       └── fmod_macros.h
│   │   ├── thirdparty/
│   │   │   └── fmod/        # FMOD Core & Studio SDK headers and libraries
│   │   └── SConstruct       # SCons build recipe linking godot-cpp & FMOD
│   └── godot_editor/        # Test project & addon source
│       ├── project.godot    # Godot 4.x testbed project
│       ├── icon.svg
│       └── addons/
│           └── godot_fmod/
│               ├── bin/     # Native binaries (.dylib, .so, .dll) + FMOD shared libs
│               │   └── .gdignore
│               ├── icons/   # Custom node icons (SVG)
│               ├── internal/# Internal GDScript implementation (no class_name, preload only)
│               │   └── services/
│               │       └── csharp_service.gd # Auto-hides csharp/ folder via .gdignore
│               ├── csharp/  # C# typed wrapper classes (namespace: PoingStudios.GodotFmod)
│               │   ├── sample/
│               │   │   ├── DemoAudioCSharp.cs
│               │   │   └── DemoAudioCSharp.tscn
│               │   └── src/
│               │       ├── FmodEnums.cs
│               │       ├── FmodServer.cs
│               │       ├── FmodEventInstance.cs
│               │       ├── FmodEventDescription.cs
│               │       ├── FmodBank.cs
│               │       ├── FmodBus.cs
│               │       ├── FmodVca.cs
│               │       └── Nodes/
│               │           ├── FmodEventEmitter2D.cs
│               │           ├── FmodEventEmitter3D.cs
│               │           ├── FmodListener2D.cs
│               │           ├── FmodListener3D.cs
│               │           └── FmodNodeExtensions.cs
│               ├── godot_fmod.gdextension # GDExtension manifest
│               ├── plugin.cfg             # Addon metadata
│               └── plugin.gd              # EditorPlugin entry point
└── scripts/
    ├── build_local.sh       # Automated local build script
    └── setup_fmod_sdk.sh    # Helper script to download/link FMOD SDK headers and libs
```

---

## Key Classes & Responsibilities

| Class | Type | Purpose |
| :--- | :--- | :--- |
| `FmodServer` | Engine Singleton | Studio system lifecycle, bank loading, one-shots (`play_one_shot`), global parameters, bus routing, listeners |
| `FmodEventInstance` | `RefCounted` | 1:1 wrapper for `FMOD::Studio::EventInstance` (playback, 3D attributes, parameters, timeline, volume) |
| `FmodEventDescription`| `RefCounted` | 1:1 wrapper for `FMOD::Studio::EventDescription` (metadata, length, 3D flags, instance factory) |
| `FmodBank` | `RefCounted` | 1:1 wrapper for `FMOD::Studio::Bank` (bank lifecycle, sample loading states) |
| `FmodBus` | `RefCounted` | 1:1 wrapper for `FMOD::Studio::Bus` (submix volume, muting, pausing, stopping events) |
| `FmodVCA` | `RefCounted` | 1:1 wrapper for `FMOD::Studio::VCA` (group volume control) |
| `FmodEventEmitter3D` | `Node3D` | High-level 3D spatial emitter automatically calculating velocity and spatial orientation |
| `FmodEventEmitter2D` | `Node2D` | High-level 2D spatial audio emitter |
| `FmodListener3D` | `Node3D` | High-level 3D listener node forwarding camera/player transform to `FmodServer` |
| `FmodListener2D` | `Node2D` | High-level 2D listener node |

---

## Build & Test Commands

### Prerequisites

- **Godot 4.x** (executable at `/Volumes/Mac500GB/Downloads/Godot462.app`)
- **C++17 Compiler** (Clang on macOS, GCC/Clang on Linux, MSVC on Windows)
- **SCons** (`pip install scons`)
- **Python 3.x**
- **FMOD Engine SDK 2.03.x**

### Compile GDExtension

Using the build script:
```bash
./scripts/build_local.sh [platform] [target] [arch]
```
*Examples:*
```bash
./scripts/build_local.sh                             # Auto-detect host OS and architecture
./scripts/build_local.sh macos template_debug arm64 # Explicit macOS arm64 debug build
./scripts/build_local.sh windows template_release x86_64
```

Using SCons directly:
```bash
scons -C platforms/gdextension platform=macos target=template_debug arch=arm64
scons -C platforms/gdextension platform=linux target=template_debug arch=x86_64
scons -C platforms/gdextension platform=windows target=template_debug arch=x86_64
```

### Running the Godot Editor Testbed

```bash
/Volumes/Mac500GB/Downloads/Godot462.app/Contents/MacOS/Godot --path platforms/godot_editor -e
```

---

## Coding Rules & Guidelines

### C++ Rules

1. **Memory & Lifecycle**: Wrap raw FMOD C++ pointers safely. Release event instances and banks explicitly or via `RefCounted` destructors.
2. **Coordinate Space**: Always convert coordinates using `fmod_types.h` (Godot Y-Up / right-handed <-> FMOD).
3. **Error Handling**: Use `FMOD_CHECK_ERR(result, "Context message")` for every FMOD C++ API call.
4. **Registration**: Register all classes, methods, properties, and enums cleanly in `register_types.cpp` through `godot::ClassDB`.

### C# Rules & 1:1 API Parity

1. **1:1 API Parity**: Maintain **1:1 API parity** between C# wrappers (`PoingStudios.GodotFmod`) and GDExtension C++ `ClassDB` bindings at all times.
2. **Synchronized Updates**: Whenever a new method, property, or enum is added to or modified in the C++ GDExtension layer, the corresponding C# wrapper under `addons/godot_fmod/csharp/src/` **must** be updated synchronously.
3. **Naming & Style**: Use standard C# `PascalCase` for method names, properties, and enum members while wrapping snake_case `ClassDB` methods.
4. **Auto-Visibility**: The `csharp/` directory visibility is automatically managed by `internal/services/csharp_service.gd` via `.gdignore` based on project type.

### GDScript Rules

1. **Type Inference**: Always use `:=` instead of `=` for variable assignments.
2. **`internal/` Encapsulation**: The `internal/` directory inside `addons/godot_fmod/` **must not** contain any script with `class_name`. All internal scripts must be loaded explicitly using `preload(...)`.
3. **Tabs Indentation**: Use tabs for indentation, not spaces.

### General & Licensing Rules

1. **License Headers**: Every source file (`.cpp`, `.h`, `.cs`, `.gd`, `SConstruct`, `.sh`) must begin with the standard Poing Studios MIT License header block.
2. **Proprietary Asset Isolation**: Never commit proprietary FMOD SDK binaries (`.dylib`, `.so`, `.dll`), headers, or `.bank` audio files into Git. Keep them in `.gitignore`.
3. **Submodule Tracking**: Always specify explicit branches in `.gitmodules` (e.g. `branch = master`).

### GitHub & Git Workflow

- Always use the `gh` CLI for GitHub interactions.
- Never commit directly unless explicitly instructed.
- All code changes and responses must be in English.

