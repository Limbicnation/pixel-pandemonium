# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Pixel Pandemonium** is a 3D action game built with Godot 4.6 featuring fast-paced combat, procedurally generated content, and pixel art aesthetics. The codebase uses a component-based architecture with strict static typing and signal-driven communication.

## Running the Project

**In Godot Editor:**
- Press `F5` to run the main scene (`scenes/test_level.tscn`)
- Press `F6` to run the current scene

**From Command Line:**
```bash
# Run the project
godot --path .

# Run in editor mode
godot --editor --path .
```

## Architecture Principles

### 1. Component-Based Design

Reusable components attach to entities to provide functionality:

**HealthComponent** (`scripts/components/health_component.gd`):
- Manages health, damage, healing, invincibility frames
- Emits signals: `health_changed`, `health_depleted`, `damage_taken`, `healed`
- Attach to any entity (player, enemies, destructibles)

**CameraShake** (`scripts/components/camera_shake.gd`):
- Trauma-based shake system (0.0-1.0 scale)
- Exponential decay for natural feel
- Preset methods: `explosion()`, `gun_recoil()`, `landing()`, `strong_impact()`
- Insert between camera parent and Camera3D node

**Usage Pattern:**
```gdscript
@onready var health: HealthComponent = $HealthComponent

func _ready() -> void:
    health.health_depleted.connect(_on_death)
    health.damage_taken.connect(_on_damage_taken)
```

### 2. Signal-Driven Communication

Components and systems communicate via signals, never direct method calls:

```gdscript
# Component emits
signal health_changed(new_health: int, max_health: int)

# UI system responds
func _on_health_changed(current: int, maximum: int) -> void:
    health_bar.value = (float(current) / float(maximum)) * 100.0
```

**Key Signals:**
- `GameManager.state_changed` - Game state transitions
- `GameManager.score_changed` - Score updates
- `HealthComponent.health_depleted` - Entity death
- `PlayerController.weapon_fired` - Weapon effects

### 3. Global State Management

**GameManager** (`scripts/autoload/game_manager.gd`) - Autoload singleton:
- Manages game state (MENU, PLAYING, PAUSED, GAME_OVER)
- Tracks score, wave count, collectibles
- Controls pause/unpause and mouse capture
- Provides player reference: `GameManager.player`

Access from any script:
```gdscript
GameManager.add_score(100)
GameManager.change_state(GameManager.GameState.PLAYING)
```

### 4. Exponential Lerp for Smooth Physics

**CRITICAL PATTERN** - Delta-independent interpolation:

```gdscript
# ❌ WRONG - Delta-dependent (framerate-sensitive)
velocity.x = lerp(velocity.x, target, 0.1 * delta)

# ✅ CORRECT - Delta-independent (consistent across framerates)
velocity.x = lerpf(velocity.x, target, 1.0 - exp(-acceleration * delta))
```

Use exponential lerp for:
- Movement acceleration/deceleration
- Camera following
- Weapon sway/recoil recovery
- Any smooth transitions

Values: Fast (10.0-20.0), Medium (5.0-10.0), Slow (2.0-5.0)

## Code Standards

### Static Typing (Mandatory)

All variables, parameters, and return types MUST be explicitly typed:

```gdscript
# Variables
var current_health: int = 100
var move_speed: float = 5.0
var target: Node3D = null

# Functions
func take_damage(amount: int, source: Node) -> void:
    current_health -= amount

# Exports
@export var max_health: int = 100
@export var detection_range: float = 15.0
```

**Type Inference Fix:**
When `get_node()` returns ambiguous types, add explicit type:
```gdscript
# ❌ Error: Cannot infer type
var health_node := collider.get_node("HealthComponent")

# ✅ Fixed
var health_node: Node = collider.get_node("HealthComponent")
```

### Inspector Organization

Group related exports with `@export_group`:

```gdscript
@export_group("Movement")
@export var walk_speed: float = 8.0
@export var sprint_speed: float = 12.0

@export_group("Combat")
@export var damage: int = 25
@export var fire_rate: float = 10.0
```

### Null Safety

Always check node existence before use:

```gdscript
if camera == null:
    return

if raycast and raycast.is_colliding():
    var collider := raycast.get_collider()
    if collider and collider.has_method("interact"):
        collider.interact(self)
```

## Project Structure

```
pixel-pandemonium/
├── scripts/
│   ├── autoload/           # Global singletons (GameManager)
│   ├── components/         # Reusable components (Health, CameraShake)
│   └── entities/           # Game entities (PlayerController, Target)
├── scenes/                 # Scene files (.tscn)
│   ├── player.tscn
│   ├── test_level.tscn     # Main scene
│   └── crystal_core.tscn
├── assets/
│   ├── meshes/            # 3D models and materials
│   └── textures/          # Textures and images
└── project.godot          # Godot project configuration
```

## Physics Layers

Standard layer configuration:
- **Layer 1**: World (static geometry)
- **Layer 2**: Player
- **Layer 3**: Player projectiles
- **Layer 4**: Enemies
- **Layer 5**: Enemy projectiles
- **Layer 8**: Items/Pickups

Raycast mask example (exclude player):
```gdscript
query.collision_mask = 0xFFFFFFFF & ~(1 << 1)  # All except player
```

## Common Patterns

### Damage Application

```gdscript
# From raycast weapon
if collider.has_node("HealthComponent"):
    var health_node: Node = collider.get_node("HealthComponent")
    if health_node.has_method("take_damage"):
        health_node.take_damage(damage, self)
```

### Debris Cleanup

```gdscript
func _cleanup_debris(debris: RigidBody3D, delay: float) -> void:
    await get_tree().create_timer(delay).timeout
    if is_instance_valid(debris):
        var tween := create_tween()
        tween.tween_property(debris, "scale", Vector3.ZERO, 0.5)
        tween.tween_callback(debris.queue_free)
```

### Camera Shake Integration

```gdscript
@onready var camera_shake: CameraShake = $Head/CameraShake

func _fire_weapon() -> void:
    camera_shake.gun_recoil()  # Trauma: 0.15

func _on_explosion() -> void:
    camera_shake.explosion()   # Trauma: 1.0
```

## Input Actions

Defined in `project.godot`:
- `move_forward` / `move_backward` / `move_left` / `move_right` - WASD + Arrow keys
- `jump` - Space
- `sprint` - Shift
- `dodge` - Alt
- `fire` - Left mouse button
- `aim` - Right mouse button
- `interact` - E
- `ui_cancel` - Escape (pause)

## Godot Version

**Godot 4.6** with Forward+ renderer. The project uses Godot 4.x-specific features:
- `class_name` for named scripts
- `@export` and `@onready` annotations
- Typed GDScript 2.0 syntax
- CharacterBody3D (not KinematicBody)

## Development Workflow

1. Open project in Godot 4.6+
2. Main scene auto-loads: `scenes/test_level.tscn`
3. Press F5 to test
4. Scripts auto-reload on save (hot reload enabled)
5. Use Godot's built-in debugger for breakpoints and variable inspection

## Git LFS

Large binary files (3D models, textures) use Git LFS:
```bash
# Install Git LFS if needed
git lfs install

# LFS tracks: *.blend, *.fbx, *.png, *.jpg, *.wav, *.ogg
git lfs pull
```
