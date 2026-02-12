# Pixel Pandemonium - Agent Guide

This document provides essential information for AI coding agents working on the Pixel Pandemonium project.

## Project Overview

**Pixel Pandemonium** is a fast-paced, chaotic 3D action game developed with Godot Engine 4.3. The project features dynamic pixel-based gameplay mechanics in a procedurally generated 3D world.

- **Engine**: Godot 4.3 (Forward Plus rendering)
- **Language**: GDScript (statically typed)
- **Dimensionality**: 3D
- **License**: GNU General Public License v3.0
- **Main Scene**: `res://scenes/crystal_core.tscn`

## Project Structure

```
.
├── project.godot          # Godot project configuration
├── icon.svg               # Project icon
├── README.md              # Human-readable project documentation
├── LICENSE                # GNU GPL v3.0 license
├── .gitignore             # Git ignore rules (Godot-specific)
├── .gitattributes         # Git LFS configuration for binary assets
│
├── assets/                # Game assets
│   ├── audio/             # Audio files
│   │   ├── music/         # Background music
│   │   └── sfx/           # Sound effects
│   ├── fonts/             # Font files (.ttf, .otf)
│   ├── meshes/            # 3D models
│   │   ├── environment/   # Environment meshes
│   │   └── promps/        # Prop meshes
│   ├── sprites/           # 2D sprite assets
│   └── tilemaps/          # Tilemap resources
│
├── scenes/                # Godot scene files (.tscn)
│   ├── crystal_core.tscn  # Main scene (entry point)
│   └── levels/            # Level scenes
│
└── scripts/               # GDScript source files
    ├── autoload/          # Autoload/singleton scripts
    ├── components/        # Reusable component scripts
    └── entities/          # Entity-specific scripts
```

## Technology Stack

### Core Technologies
- **Godot Engine 4.3**: Primary game engine
- **GDScript**: Game logic scripting language
- **Forward Plus**: Rendering pipeline (configured in project.godot)

### Asset Formats
- **3D Models**: FBX, glTF, GLB, OBJ, DAE, Blender files
- **Textures**: PNG, JPG, WEBP, TGA
- **Audio**: MP3, WAV, OGG
- **Fonts**: TTF, OTF

## Development Conventions

### Code Style (GDScript)
- **Use static typing**: Always declare variable types with `:` notation
  ```gdscript
  var move_speed: float = 5.0
  func _process(delta: float) -> void:
  ```
- **Use type inference sparingly**: Prefer explicit types for clarity
- **Function naming**: Use `snake_case` for functions and variables
- **Class naming**: Use `PascalCase` for class names
- **Constants**: Use `UPPER_SNAKE_CASE` for constants
- **Private members**: Prefix with underscore `_private_var`

### File Naming
- **Scenes**: Use `snake_case.tscn`
- **Scripts**: Use `snake_case.gd`
- **Resources**: Use `snake_case.tres`
- **Assets**: Use descriptive names with underscores

### Node Naming in Scenes
- Use `PascalCase` for node names
- Be descriptive: `PlayerCharacter`, `CollisionShape3D`

### Script Organization
Scripts should be organized by purpose:
- `autoload/`: Global singletons (game state, audio manager, etc.)
- `components/`: Reusable behavior components
- `entities/`: Scripts attached to specific game entities

## Git and Asset Management

### Git LFS
This project uses Git LFS for binary assets. The following file types are tracked:
- Images: `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.tga`
- 3D Models: `.fbx`, `.gltf`, `.glb`, `.blend`, `.obj`, `.dae`
- Audio: `.mp3`, `.wav`, `.ogg`
- Video: `.mp4`, `.mov`, `.webm`
- Fonts: `.ttf`, `.otf`
- Documents: `.pdf`, `.psd`, `.aseprite`, `.ase`

### Ignored Files
- `.godot/`: Godot's local cache
- `.import/`: Legacy import folder
- `export.cfg` and `export_presets.cfg`: Export configurations
- `*.translation`: Generated translation files
- `.mono/` and Mono-related files

## Build and Run

### Prerequisites
- Godot Engine 4.3 or later
- Git with LFS support

### Opening the Project
1. Launch Godot Engine
2. Click "Import" and select the `project.godot` file
3. The main scene (`crystal_core.tscn`) will auto-load

### Running the Project
- In Godot Editor: Press `F5` or click the "Play" button
- Main scene path: `res://scenes/crystal_core.tscn`

### Exporting
Export configurations should be defined in `export_presets.cfg` (not in repository). Configure export presets via:
- Godot Editor → Project → Export

## Testing Strategy

### Current Status
The project is in early development. Testing approach:
- Manual testing through editor play mode (`F5`)
- Scene-specific testing: Open individual `.tscn` files to test components

### Future Testing
Consider implementing:
- GDScript unit tests using GUT (Godot Unit Testing)
- Integration tests for scene loading
- Performance profiling for 3D scenes

## Key Configuration

### Input Actions
Default Godot input actions are used (`ui_up`, `ui_down`, etc.). Custom input actions should be defined in:
- Project Settings → Input Map

### Rendering
- **Renderer**: Forward Plus
- **Features**: PackedStringArray("4.3", "Forward Plus")

## Development Workflow

1. **Scene Editing**: Use Godot Editor for scene composition
2. **Scripting**: GDScript files can be edited externally or in-editor
3. **Asset Import**: Place assets in appropriate `assets/` subdirectories; Godot auto-imports
4. **Version Control**: Commit `.tscn`, `.gd`, `.tres` files; LFS handles binaries

## Security Considerations

- Do not commit sensitive data (API keys, credentials) in scripts
- Avoid hardcoding paths that may differ between environments
- Be cautious with `OS.execute()` or file system operations
- Review third-party assets for license compatibility with GPL v3.0

## Common Tasks

### Adding a New Scene
1. Create `.tscn` file in appropriate `scenes/` subdirectory
2. Set up node hierarchy in Godot Editor
3. Attach scripts from `scripts/` if needed
4. Register in autoload if it needs to be global

### Adding a New Script
1. Create `.gd` file in appropriate `scripts/` subdirectory
2. Use `class_name` for reusable scripts
3. Follow static typing conventions
4. Attach to scene nodes or use as autoload

### Importing 3D Models
1. Place model files in `assets/meshes/`
2. Godot auto-generates `.import` files
3. Configure import settings in the Import dock if needed
4. Instantiate in scenes using the imported scene

## Troubleshooting

- **Missing assets**: Ensure Git LFS files are pulled (`git lfs pull`)
- **Import errors**: Delete `.godot/imported/` folder and reimport
- **Script errors**: Check for type mismatches in GDScript (Godot 4.x is strict)

## Additional Resources

- [Godot 4.3 Documentation](https://docs.godotengine.org/en/4.3/)
- [GDScript Style Guide](https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot Best Practices](https://docs.godotengine.org/en/4.3/tutorials/best_practices/index.html)
