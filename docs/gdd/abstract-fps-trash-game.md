# Abstract FPS: "Trash Vision" - Game Design Document

**Author:** Gero Doll
**Created:** 2026-02-12
**Version:** 1.0
**Engine:** Godot 4.6
**Target:** Solo development, 6-week prototype

---

## High Concept

**"A lo-fi FPS where killing enemies hijacks their vision - see what they saw, but expose yourself to attack."**

Fast-paced arena shooter with momentum-based movement, hitscan combat, and a unique "Trash Vision" mechanic that rewards aggressive play with tactical intel at the cost of vulnerability. Embraces primitive geometry and harsh neon aesthetics - intentionally rough, experimental, and memorable.

---

## Core Pillars

### 1. Speed
- High-velocity movement with momentum preservation
- Dash mechanic for burst mobility
- No cover camping - movement is survival
- Combat flows like Quake meets Mirror's Edge

### 2. Risk/Reward
- Trash Vision = intel vs vulnerability trade-off
- Headshots = instant kill (positioning matters)
- Limited ammo forces aggressive pushes for pickups
- Every kill is a decision: take the vision or keep moving?

### 3. Lo-fi Aesthetic
- "Trash game" as artistic choice, not limitation
- CSG primitives only - no imported models
- Glitch effects = feature, not bug
- Strong visual identity from constraints

---

## Mechanics

### Movement System

**Core Movement:**
```gdscript
# Momentum-based acceleration (delta-independent)
var acceleration: float = 10.0
var max_speed: float = 8.0
var air_acceleration: float = 5.0

velocity.x = lerpf(velocity.x, direction.x * max_speed, 1.0 - exp(-acceleration * delta))
velocity.z = lerpf(velocity.z, direction.z * max_speed, 1.0 - exp(-acceleration * delta))
```

**Key Features:**
- **Walk Speed:** 8.0 m/s (fast, but controllable)
- **Sprint Speed:** 12.0 m/s (unsustainable - use for positioning)
- **Jump Velocity:** 6.0 m/s (enough for vertical traversal)
- **Air Control:** 50% ground acceleration (mid-air correction)
- **Gravity:** 20.0 m/s² (snappy, responsive)

**Dash Mechanic:**
- **Cooldown:** 1.5 seconds
- **Velocity Burst:** 20.0 m/s in movement direction
- **Duration:** Instant (velocity applied, then decays naturally)
- **Visual:** Chromatic aberration pulse on activation
- **Use Cases:** Gap crossing, escape, aggressive close-range plays

**Wall-Running (Optional - Alpha/Polish):**
- **Trigger:** Speed > 10.0 m/s, wall angle < 70° from vertical
- **Duration:** 2.0 seconds max
- **Mechanics:** Gravity reduced to 5.0 m/s², forward boost applied
- **Exit:** Jump off wall for velocity bonus (1.5x current speed)
- **Cut If:** Implementation complexity exceeds 2 days

### Combat System

**Hitscan Weapon:**
- **Type:** Instant raycast from camera (no projectiles)
- **Fire Rate:** 10 rounds/second (600 RPM)
- **Magazine:** Infinite (no reload) - ammo pool only
- **Range:** Unlimited (raycast max_distance = 1000.0)
- **Damage:**
  - Body shot: 50 HP
  - Headshot: Instant kill (raycast detects CollisionShape head region)
- **Visual Feedback:**
  - Muzzle flash: OmniLight3D pulse (0.1s, intensity 5.0)
  - Hit marker: White crosshair flash (0.05s)
  - Screen shake: Minor trauma (0.1) on fire

**Ammo System:**
- **Starting Ammo:** 60 rounds
- **Max Ammo:** 120 rounds
- **Pickups:** Glowing cyan cubes (+10 ammo each)
- **Spawn Logic:** Drop from killed enemies + scattered in arena
- **Scarcity:** Forces movement toward danger zones

**Enemy AI:**
- **Behavior:** Simple chase + attack (NavigationAgent3D)
- **Detection Range:** 20.0 meters (line-of-sight check)
- **Attack Range:** 2.0 meters (melee damage: 25 HP/hit)
- **Health:** 100 HP (2 body shots or 1 headshot)
- **Speed:** 6.0 m/s (slower than player - kiting is viable)
- **Appearance:** Magenta CSGBox3D with emissive material

### Unique Hook: Trash Vision

**Mechanic Overview:**
When you kill an enemy, you experience a 2-second "death replay" from their perspective:

**Flow:**
1. **Kill Enemy** → Trigger signal `enemy_killed(enemy_position, enemy_rotation)`
2. **Camera Hijack** → Player camera lerps to enemy's death position (0.5s tween)
3. **Vision Window** → View arena from enemy POV for 2.0 seconds
4. **Vulnerability** → Player character frozen, defenseless
5. **Return** → Camera lerps back to player (0.3s tween), resume control

**Tactical Applications:**
- **Intel Gathering:** Spot other enemies from elevated positions
- **Route Planning:** See safe paths vs. ambush points
- **Risk Management:** Skip vision by moving immediately after kill
- **Bait Plays:** Intentionally kill exposed enemy to scout dangerous area

**Visual Design:**
- **Transition:** Glitch shader (RGB split + scanlines) during lerp
- **Vision State:** Desaturated colors, vignette effect
- **Enemy Highlights:** Other enemies glow cyan through walls
- **Timer:** Countdown UI (2... 1... 0)

**Implementation:**
```gdscript
# In player_controller.gd
func _on_enemy_killed(death_cam_pos: Vector3, death_cam_rot: Vector3) -> void:
    if not use_trash_vision:
        return

    is_trash_vision_active = true
    original_camera_transform = camera.global_transform

    # Lerp to death camera
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(camera, "global_position", death_cam_pos, 0.5)
    tween.tween_property(camera, "global_rotation", death_cam_rot, 0.5)

    # Hold for 2 seconds
    await get_tree().create_timer(2.0).timeout

    # Return to player
    tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(camera, "global_transform", original_camera_transform, 0.3)
    tween.tween_callback(func(): is_trash_vision_active = false)
```

**Alternative Hooks (Backup Plans):**

If Trash Vision doesn't playtest well:

1. **Ricochet Bullets:**
   - Bullets bounce off surfaces 3 times before dissipating
   - Enables trick shots around corners
   - Simpler implementation (just extend raycast logic)

2. **Kill Slow-Mo:**
   - Time slows to 20% for 1 second after kill (SUPERHOT-lite)
   - Allows tactical repositioning mid-combat
   - Engine.time_scale = 0.2

3. **Gravity Flip Dash:**
   - Dash inverts player gravity (ceiling becomes floor)
   - Creates vertical combat arenas
   - CharacterBody3D.up_direction = -Vector3.UP

---

## Visual Design

### Art Style: "Neon Void"

**Core Aesthetic:**
- Primitive CSG geometry floating in infinite black void
- AI generated textures and pure emissive materials (StandardMaterial3D)
- Harsh neon colors on pure black background
- Glitch effects emphasize "trash game" experimental vibe
- Strong silhouettes from high contrast (gameplay clarity)

**Color Palette:**
- **Cyan** (`#00FFFF`) - Player elements, ammo pickups, grid floor
- **Magenta** (`#FF00FF`) - Enemies, danger zones, muzzle flash
- **White** (`#FFFFFF`) - Accents, hit markers, UI text
- **Black** (`#000000`) - Void background, shadows, negative space

### Environmental Design

**Arena Layout:**
- **Platform Type:** Floating CSGBox3D nodes (5-15 units wide)
- **Verticality:** 3 distinct height levels (0m, 5m, 10m)
- **Spacing:** 3-8 meter gaps (requires dash/jump to cross)
- **Geometry:** No organic shapes - only boxes, cylinders, spheres
- **Floor Material:** Black base with cyan grid shader (1m grid spacing)

**Lighting:**
- **Ambient:** Fully black (Color(0, 0, 0, 1))
- **Key Light:** Single DirectionalLight3D, magenta tint, low intensity (0.3)
- **Point Lights:** OmniLight3D on each platform (cyan, range 10.0)
- **Glow:** WorldEnvironment with Glow enabled (intensity 1.0, bloom 0.5)

**Example Arena Blueprint (ASCII):**
```
        [Enemy Spawn]
             |
    [Platform 10m] ←--dash gap--→ [Platform 10m]
         |                              |
    [Platform 5m]  ←----jump--→   [Platform 5m]
         |                              |
    ═══[Grid Floor 0m]═══════════════════
         |
    [Player Spawn]        [Ammo Cube]
```

### VFX Systems: Visceral Impact Feedback

**Design Philosophy:**
Every action needs PUNCH. Inspired by DEAD TRASH's gore emphasis, we use chromatic aberration, screen shake, hit-stop, and color flashes to make combat feel brutal despite the abstract aesthetic.

---

#### 1. Screen Shake System (CameraShake Component)

**Trauma-Based Intensity:**
```gdscript
# Reuse from Pixel Pandemonium - scripts/components/camera_shake.gd
@onready var camera_shake: CameraShake = $Head/CameraShake

# Preset trauma values (0.0 - 1.0 scale)
func _fire_weapon() -> void:
    camera_shake.add_trauma(0.2)  # Subtle recoil

func _on_hit_enemy() -> void:
    camera_shake.add_trauma(0.4)  # Medium impact

func _on_headshot() -> void:
    camera_shake.add_trauma(0.8)  # Strong impact

func _on_take_damage(amount: int) -> void:
    camera_shake.add_trauma(0.6)  # Getting hit feedback

func _on_dash() -> void:
    camera_shake.add_trauma(0.3)  # Movement burst
```

**Shake Parameters:**
- **Max Roll:** 0.1 radians (camera tilt on impact)
- **Max Offset:** 0.5 units (positional shake)
- **Trauma Decay:** Exponential (recovers naturally over 1-2s)
- **Frequency:** 20 Hz (rapid oscillation for intensity)

---

#### 2. Chromatic Aberration System

**RGB Split Shader:**
```glsl
// res://shaders/chromatic_aberration.gdshader
shader_type canvas_item;

uniform float offset : hint_range(0.0, 20.0) = 0.0;
uniform float angle : hint_range(0.0, 6.28) = 0.0;  // Radians

void fragment() {
    vec2 dir = vec2(cos(angle), sin(angle));
    vec2 uv = SCREEN_UV;

    float r = texture(SCREEN_TEXTURE, uv + dir * offset * SCREEN_PIXEL_SIZE).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - dir * offset * SCREEN_PIXEL_SIZE).b;

    COLOR = vec4(r, g, b, 1.0);
}
```

**Intensity Mapping:**

| Event | Offset (pixels) | Duration | Angle |
|-------|----------------|----------|-------|
| Weapon fire | 2.0 | 0.05s | Random |
| Body hit | 5.0 | 0.1s | Impact direction |
| Headshot | 15.0 | 0.3s | Radial burst |
| Take damage | 8.0 | 0.15s | Damage source direction |
| Dash | 3.0 | 0.2s | Movement direction |

**Implementation:**
```gdscript
# In player_controller.gd
@onready var aberration_overlay: ColorRect = $"../UI/ChromaticAberration"

func _apply_aberration(intensity: float, duration: float, direction: Vector2 = Vector2.ZERO) -> void:
    var material: ShaderMaterial = aberration_overlay.material
    var angle := direction.angle() if direction != Vector2.ZERO else randf() * TAU

    material.set_shader_parameter("angle", angle)

    var tween := create_tween()
    tween.tween_method(
        func(val): material.set_shader_parameter("offset", val),
        intensity,
        0.0,
        duration
    ).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

# Usage examples
func _on_headshot() -> void:
    _apply_aberration(15.0, 0.3)  # Intense burst
    camera_shake.add_trauma(0.8)
    _freeze_frame(0.05)  # Hit-stop

func _fire_weapon() -> void:
    _apply_aberration(2.0, 0.05, Vector2(randf_range(-1, 1), randf_range(-1, 1)))
    camera_shake.add_trauma(0.2)
```

---

#### 3. Hit-Stop (Freeze Frame)

**Time Dilation on Impact:**
```gdscript
# Creates "meaty" impact feel by briefly pausing time
func _freeze_frame(duration: float) -> void:
    Engine.time_scale = 0.05  # Near-freeze (not fully stopped for audio)
    await get_tree().create_timer(duration * 0.05).timeout  # Real-time wait
    Engine.time_scale = 1.0

# Usage
func _on_headshot() -> void:
    _freeze_frame(0.08)  # 80ms pause (feels BRUTAL)

func _on_melee_hit() -> void:
    _freeze_frame(0.05)  # 50ms pause
```

**When to Use:**
- Headshots (0.08s)
- Melee kills (0.06s)
- Last enemy in wave (0.1s)
- Boss kills (0.15s)

**When NOT to Use:**
- Normal body shots (too frequent, would feel sluggish)
- Player taking damage (breaks control responsiveness)

---

#### 4. Color Flash Overlays

**Full-Screen Flash for Damage Feedback:**

**Setup:**
```gdscript
# UI/DamageFlash (ColorRect)
# Material: CanvasItemMaterial with blend mode "Add"
@onready var damage_flash: ColorRect = $"../UI/DamageFlash"

func _flash_screen(color: Color, intensity: float, duration: float) -> void:
    damage_flash.modulate = Color(color.r, color.g, color.b, intensity)

    var tween := create_tween()
    tween.tween_property(damage_flash, "modulate:a", 0.0, duration)
```

**Flash Types:**

| Event | Color | Intensity | Duration |
|-------|-------|-----------|----------|
| Take damage | Red (#FF0000) | 0.4 | 0.2s |
| Health critical (<25%) | Red pulse | 0.3 (loop) | 0.5s |
| Kill enemy | Cyan (#00FFFF) | 0.2 | 0.15s |
| Headshot | Magenta (#FF00FF) | 0.5 | 0.25s |
| Ammo pickup | White (#FFFFFF) | 0.15 | 0.1s |
| Trash Vision start | White → Cyan | 0.6 | 0.5s |

```gdscript
func _on_take_damage(amount: int) -> void:
    _flash_screen(Color.RED, 0.4, 0.2)
    camera_shake.add_trauma(0.6)
    _apply_aberration(8.0, 0.15, (global_position - damage_source_position).normalized())

func _on_headshot_kill() -> void:
    _flash_screen(Color.MAGENTA, 0.5, 0.25)
    _freeze_frame(0.08)
    _apply_aberration(15.0, 0.3)
    camera_shake.add_trauma(0.8)
```

---

#### 5. Muzzle Flash & Hit Sparks

**Muzzle Flash (Enhanced):**
```gdscript
# Camera/MuzzleFlash (OmniLight3D)
@onready var muzzle_flash: OmniLight3D = $Head/Camera3D/MuzzleFlash

func _fire_weapon() -> void:
    # Light pulse
    muzzle_flash.light_energy = 8.0
    muzzle_flash.light_color = Color.WHITE

    var tween := create_tween()
    tween.tween_property(muzzle_flash, "light_energy", 0.0, 0.08)

    # Particle burst (simple quad sprites)
    _spawn_muzzle_particles()

    # VFX combo
    camera_shake.add_trauma(0.2)
    _apply_aberration(2.0, 0.05)

func _spawn_muzzle_particles() -> void:
    # Spawn 3-5 white quads that fly outward and fade
    for i in randi_range(3, 5):
        var particle := MeshInstance3D.new()
        particle.mesh = QuadMesh.new()
        particle.mesh.size = Vector2(0.05, 0.05)

        var mat := StandardMaterial3D.new()
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.emission_enabled = true
        mat.emission = Color.WHITE
        mat.emission_energy = 5.0
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        particle.material_override = mat

        var spawn_pos := muzzle_flash.global_position
        var direction := -camera.global_transform.basis.z + Vector3(randf_range(-0.2, 0.2), randf_range(-0.2, 0.2), 0)

        particle.global_position = spawn_pos
        get_tree().root.add_child(particle)

        # Animate outward + fade
        var ptween := create_tween()
        ptween.set_parallel(true)
        ptween.tween_property(particle, "global_position", spawn_pos + direction * 0.5, 0.2)
        ptween.tween_property(particle, "scale", Vector3.ZERO, 0.2)
        ptween.tween_callback(particle.queue_free)
```

**Hit Sparks (Impact Point):**
```gdscript
func _on_raycast_hit(hit_point: Vector3, hit_normal: Vector3) -> void:
    # Spawn cyan spark burst at impact
    for i in randi_range(5, 10):
        var spark := _create_spark()
        spark.global_position = hit_point

        # Random direction within hemisphere facing hit_normal
        var random_dir := (hit_normal + Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))).normalized()

        var stween := create_tween()
        stween.set_parallel(true)
        stween.tween_property(spark, "global_position", hit_point + random_dir * randf_range(0.3, 0.8), 0.3)
        stween.tween_property(spark, "scale", Vector3.ZERO, 0.3)
        stween.tween_callback(spark.queue_free)

func _create_spark() -> MeshInstance3D:
    var spark := MeshInstance3D.new()
    spark.mesh = QuadMesh.new()
    spark.mesh.size = Vector2(0.03, 0.03)

    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.emission_enabled = true
    mat.emission = Color.CYAN
    mat.emission_energy = 8.0
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    spark.material_override = mat

    get_tree().root.add_child(spark)
    return spark
```

---

#### 6. Death Animations (Enhanced)

**Enemy Death VFX:**
```gdscript
func _on_health_depleted() -> void:
    # Explosion burst
    _spawn_death_particles()

    # Screen flash for player
    if is_visible_to_player():
        GameManager.player._flash_screen(Color.CYAN, 0.2, 0.15)

    # Geometry collapse
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(mesh, "scale", Vector3.ZERO, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
    tween.tween_property(mesh, "rotation", Vector3(PI * 4, PI * 4, PI * 2), 0.3)

    # Emit death camera for Trash Vision
    var cam_pos := global_position + Vector3(0, 1.5, 0)
    enemy_killed.emit(cam_pos, global_rotation)

    # Delayed cleanup
    await tween.finished
    queue_free()

func _spawn_death_particles() -> void:
    # Magenta particle burst (8-12 pieces of "debris")
    for i in randi_range(8, 12):
        var debris := MeshInstance3D.new()
        debris.mesh = BoxMesh.new()
        debris.mesh.size = Vector3(0.1, 0.1, 0.1)

        var mat := StandardMaterial3D.new()
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.emission_enabled = true
        mat.emission = Color.MAGENTA
        mat.emission_energy = 5.0
        debris.material_override = mat

        debris.global_position = global_position
        get_tree().root.add_child(debris)

        # Explosion outward
        var explosion_dir := Vector3(randf_range(-1, 1), randf_range(0.5, 1), randf_range(-1, 1)).normalized()

        var dtween := create_tween()
        dtween.set_parallel(true)
        dtween.tween_property(debris, "global_position", global_position + explosion_dir * randf_range(1.5, 3.0), 0.5)
        dtween.tween_property(debris, "rotation", Vector3(randf() * TAU, randf() * TAU, randf() * TAU), 0.5)
        dtween.tween_property(debris, "scale", Vector3.ZERO, 0.5).set_delay(0.3)
        dtween.tween_callback(debris.queue_free)
```

---

#### 7. Trash Vision Transition VFX

**Glitch Transition In:**
```gdscript
func _on_enemy_killed(death_cam_pos: Vector3, death_cam_rot: Vector3) -> void:
    if not use_trash_vision:
        return

    is_trash_vision_active = true
    original_camera_transform = camera.global_transform

    # WHITE FLASH
    _flash_screen(Color.WHITE, 0.8, 0.3)

    # HEAVY CHROMATIC ABERRATION BURST
    _apply_aberration(20.0, 0.5, Vector2.ZERO)  # Radial explosion

    # SCANLINE SHADER ACTIVATE
    scanline_overlay.visible = true
    var scan_mat: ShaderMaterial = scanline_overlay.material
    scan_mat.set_shader_parameter("intensity", 0.5)

    # CAMERA LERP
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(camera, "global_position", death_cam_pos, 0.5).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(camera, "global_rotation", death_cam_rot, 0.5).set_trans(Tween.TRANS_CUBIC)

    await tween.finished

    # VISION STATE EFFECTS
    _enable_xray_vision()  # Highlight enemies through walls
    _apply_desaturation()  # Shader: reduce color saturation to 30%

    # HOLD FOR 2 SECONDS
    await get_tree().create_timer(2.0).timeout

    # TRANSITION OUT
    _flash_screen(Color.CYAN, 0.6, 0.3)
    _apply_aberration(15.0, 0.3)

    tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(camera, "global_transform", original_camera_transform, 0.3)
    tween.tween_property(scan_mat, "shader_parameter/intensity", 0.0, 0.3)

    await tween.finished
    scanline_overlay.visible = false
    _disable_xray_vision()
    _remove_desaturation()
    is_trash_vision_active = false
```

---

#### VFX Priority List

**MVP (Must Have):**
- ✅ Screen shake on fire/hit/damage
- ✅ Chromatic aberration on headshot
- ✅ Muzzle flash (OmniLight3D)
- ✅ Color flash on damage (red screen)

**Alpha (Should Have):**
- ✅ Hit-stop on headshot
- ✅ Hit sparks at impact point
- ✅ Death particle burst
- ✅ Trash Vision glitch transition

**Polish (Nice to Have):**
- ⚠️ Muzzle particle sprites
- ⚠️ Trailing motion blur on dash
- ⚠️ Screen distortion shader on low health
- ⚠️ Procedural blood decals (abstract cyan splatters)

---

## Technical Implementation

### Godot Scene Architecture

```
Main.tscn
├── Arena (Node3D)
│   ├── NavigationRegion3D
│   │   └── [Baked mesh for enemy pathfinding]
│   ├── Platforms (CSGCombiner3D)
│   │   ├── Platform01 (CSGBox3D) - emissive black
│   │   ├── Platform02 (CSGBox3D)
│   │   └── Platform03 (CSGBox3D)
│   ├── GridFloor (MeshInstance3D)
│   │   └── [QuadMesh with grid shader]
│   └── SpawnPoints (Node3D)
│       ├── PlayerSpawn (Marker3D)
│       └── EnemySpawns (Node3D)
│           ├── EnemySpawn01 (Marker3D)
│           ├── EnemySpawn02 (Marker3D)
│           └── ... (8 total)
├── Player (CharacterBody3D)
│   ├── CollisionShape3D (CapsuleShape: height 2.0, radius 0.5)
│   ├── MeshInstance3D (CSGCylinder - cyan emissive)
│   ├── Head (Node3D) - pitch rotation node
│   │   ├── Camera3D
│   │   │   ├── RayCast3D (weapon firing)
│   │   │   └── MuzzleFlash (OmniLight3D)
│   │   └── CameraShake (from Pixel Pandemonium)
│   └── [player_controller.gd]
├── EnemySpawner (Node)
│   └── [enemy_spawner.gd]
├── WorldEnvironment
│   └── Environment
│       ├── Background: Color (0, 0, 0)
│       ├── Glow: Enabled (intensity 1.0)
│       └── Tonemap: ACES
├── DirectionalLight3D
│   ├── Color: Magenta tint
│   ├── Energy: 0.3
│   └── Rotation: (-45°, 45°, 0°)
└── UI (CanvasLayer)
    ├── Crosshair (CenterContainer)
    │   └── TextureRect (16x16 white cross)
    ├── AmmoCounter (Label)
    │   └── Text: "AMMO: 60"
    ├── KillCounter (Label)
    │   └── Text: "KILLS: 0"
    ├── TrashVisionTimer (Label)
    │   └── [Visible only during vision]
    └── GlitchOverlay (ColorRect)
        └── [Scanline shader material]
```

### Core Scripts

#### 1. player_controller.gd (~250 lines)

**Responsibilities:**
- Momentum-based movement (WASD + dash)
- Hitscan weapon (raycast damage)
- Trash Vision state management
- Ammo tracking

**Key Variables:**
```gdscript
# Movement
@export var walk_speed: float = 8.0
@export var sprint_speed: float = 12.0
@export var acceleration: float = 10.0
@export var dash_speed: float = 20.0
@export var dash_cooldown: float = 1.5

# Combat
@export var damage: int = 50
@export var headshot_multiplier: float = 2.0  # Instant kill
@export var fire_rate: float = 10.0
@export var max_ammo: int = 120
var current_ammo: int = 60

# Trash Vision
var is_trash_vision_active: bool = false
var original_camera_transform: Transform3D
```

**Key Methods:**
- `_physics_process(delta)` - Movement + weapon firing
- `_handle_movement(delta)` - Momentum system
- `_fire_weapon()` - Raycast damage application
- `_on_enemy_killed(pos, rot)` - Trash Vision trigger
- `_collect_ammo(amount)` - Pickup handling

#### 2. enemy_ai.gd (~180 lines)

**Responsibilities:**
- NavigationAgent3D pathfinding to player
- Chase behavior (distance < 20m)
- Melee attack (distance < 2m)
- Death camera emission

**Key Variables:**
```gdscript
@export var move_speed: float = 6.0
@export var detection_range: float = 20.0
@export var attack_range: float = 2.0
@export var attack_damage: int = 25
@export var attack_cooldown: float = 1.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health: HealthComponent = $HealthComponent
```

**Key Methods:**
- `_physics_process(delta)` - AI tick
- `_update_navigation()` - Set target to player position
- `_check_attack_range()` - Melee damage to player
- `_on_health_depleted()` - Emit death camera signal

**Death Signal:**
```gdscript
signal enemy_killed(death_cam_position: Vector3, death_cam_rotation: Vector3)

func _on_health_depleted() -> void:
    var cam_pos := global_position + Vector3(0, 1.5, 0)  # Eye height
    var cam_rot := global_rotation
    enemy_killed.emit(cam_pos, cam_rot)
    _play_death_animation()
```

#### 3. enemy_spawner.gd (~100 lines)

**Responsibilities:**
- Wave-based spawning system
- Difficulty scaling (more enemies per wave)
- Spawn at random Marker3D positions
- Track alive enemies

**Key Variables:**
```gdscript
@export var enemy_scene: PackedScene
@export var initial_enemies: int = 3
@export var enemies_per_wave: int = 2
@export var spawn_delay: float = 0.5

var current_wave: int = 1
var enemies_alive: int = 0
```

**Key Methods:**
- `_ready()` - Start first wave
- `spawn_wave()` - Instantiate enemies at spawn points
- `_on_enemy_died()` - Decrement counter, check wave complete
- `_next_wave()` - Increment wave, spawn more enemies

**Spawn Logic:**
```gdscript
func spawn_wave() -> void:
    var count := initial_enemies + (current_wave - 1) * enemies_per_wave
    for i in count:
        var spawn_point := spawn_points.pick_random()
        var enemy := enemy_scene.instantiate()
        enemy.global_position = spawn_point.global_position
        enemy.enemy_killed.connect(_on_enemy_died)
        get_parent().add_child(enemy)
        enemies_alive += 1
        await get_tree().create_timer(spawn_delay).timeout
```

#### 4. health_component.gd (Reuse from Pixel Pandemonium)

**Already implemented** - no changes needed.

**Signals used:**
- `health_changed(current: int, maximum: int)`
- `health_depleted()`
- `damage_taken(amount: int, source: Node)`

### Shader Implementations

#### 1. Grid Floor Shader

**File:** `res://shaders/grid_floor.gdshader`

```glsl
shader_type spatial;

uniform vec3 grid_color : source_color = vec3(0.0, 1.0, 1.0);  // Cyan
uniform float grid_scale : hint_range(0.1, 10.0) = 1.0;
uniform float line_width : hint_range(0.01, 0.1) = 0.02;

void fragment() {
    vec2 grid_uv = UV * grid_scale;
    vec2 grid = abs(fract(grid_uv - 0.5) - 0.5) / fwidth(grid_uv);
    float line = min(grid.x, grid.y);
    float alpha = 1.0 - min(line, 1.0);

    ALBEDO = vec3(0.0);
    EMISSION = grid_color * alpha;
    ALPHA = alpha;
}
```

#### 2. Chromatic Aberration Shader

**File:** `res://shaders/chromatic_aberration.gdshader`

```glsl
shader_type canvas_item;

uniform float offset : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    float r = texture(SCREEN_TEXTURE, uv + vec2(offset, 0.0) * SCREEN_PIXEL_SIZE).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - vec2(offset, 0.0) * SCREEN_PIXEL_SIZE).b;
    COLOR = vec4(r, g, b, 1.0);
}
```

**Usage:** Apply to ColorRect overlay, animate offset on weapon fire/hit.

#### 3. Scanline Shader

**File:** `res://shaders/scanlines.gdshader`

```glsl
shader_type canvas_item;

uniform float line_count : hint_range(100.0, 500.0) = 200.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.3;
uniform float speed : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    float scan = sin(UV.y * line_count + TIME * speed) * 0.5 + 0.5;
    COLOR = vec4(0.0, 0.0, 0.0, scan * intensity);
}
```

**Usage:** Overlay on UI layer, visible during Trash Vision transition.

#### 4. Emissive Material Template

**StandardMaterial3D settings:**
- **Albedo:** Color(0, 0, 0, 1) - Pure black
- **Emission:** Enabled
- **Emission Color:** Cyan/Magenta/White (per entity type)
- **Emission Energy:** 2.0 - 5.0 (visible in dark void)
- **Shading Mode:** Unshaded (optional - faster rendering)

---

## Scope & Milestones

### MVP (Week 1-2): Core Loop Playable

**Goal:** Prove the fun factor - movement + combat + basic Trash Vision.

**Features:**
- ✅ Player movement (walk, sprint, jump, dash)
- ✅ Hitscan weapon (raycast damage, headshot detection)
- ✅ Simple enemy AI (chase + attack)
- ✅ Basic arena (3-5 platforms, spawn points)
- ✅ Trash Vision mechanic (camera hijack on kill)
- ✅ Kill counter UI
- ✅ Ammo system (starting 60, max 120)

**Acceptance Criteria:**
- Can move fluidly around arena (dash feels responsive)
- Weapon fires at 10 RPM, hits register instantly
- Enemies chase and attack player
- Killing enemy triggers 2-second vision window
- Game loop: spawn → kill enemies → next wave

**Estimated Time:** 10-14 days (2-3 hours/day)

**Critical Path:**
1. Player controller (3 days)
2. Hitscan weapon (2 days)
3. Enemy AI (3 days)
4. Trash Vision (2 days)
5. Arena + spawner (2 days)

### Alpha (Week 3-4): Visual Identity + Polish

**Goal:** Establish "trash game" aesthetic, refine Trash Vision.

**Features:**
- ✅ Grid floor shader (world-space UV)
- ✅ Chromatic aberration on weapon fire
- ✅ Emissive materials (cyan player, magenta enemies)
- ✅ Ammo pickups (glowing cubes in arena)
- ✅ Wave spawner (difficulty scaling)
- ✅ Death animations (tween scale to zero)
- ✅ Muzzle flash VFX (OmniLight3D pulse)
- ✅ Hit markers (crosshair flash)

**Acceptance Criteria:**
- Distinct neon-on-black visual style
- Shaders working (grid floor, chromatic aberration)
- Ammo scarcity forces aggressive play
- Waves increase difficulty (more enemies)
- VFX provide clear feedback (hit confirmation)

**Estimated Time:** 10-14 days

**Critical Path:**
1. Shaders (grid floor, chromatic aberration) (3 days)
2. Material setup (emissive, glow) (2 days)
3. Ammo pickup system (2 days)
4. Wave spawner (2 days)
5. VFX polish (muzzle flash, hit markers) (3 days)

### Polish (Week 5-6): Juice + Optional Features

**Goal:** Make it feel good - add "game feel" improvements.

**Features:**
- ✅ Scanline UI shader
- ✅ Camera shake on weapon fire/hit
- ✅ Trash Vision VFX (glitch transition, desaturation)
- ✅ Enemy X-ray during vision (fresnel shader)
- ✅ Menu system (start, pause, game over)
- ⚠️ Wall-running (OPTIONAL - cut if time constrained)
- ⚠️ Sound effects (OPTIONAL - focus on visuals first)
- ⚠️ Multiple weapons (OPTIONAL - one is enough)

**Acceptance Criteria:**
- Game feels responsive (camera shake, hit feedback)
- Trash Vision has clear visual language (glitch effects)
- UI is functional (menus, pause, restart)
- Performance: 60 FPS on mid-range hardware

**Estimated Time:** 10-14 days

**Cut Priority (if time runs out):**
1. **First to cut:** Wall-running (complex raycasting)
2. **Second to cut:** Sound effects (visual game first)
3. **Third to cut:** Multiple weapons (one weapon is cleaner)

---

## Performance Targets

**Hardware:** Mid-range gaming PC (GTX 1060 equivalent)

**Frame Rate:**
- Target: 60 FPS constant
- Minimum: 30 FPS (during heavy combat)

**Optimization Strategies:**
- Use CSG only in editor - bake to MeshInstance3D at runtime
- Object pooling for enemies (reuse instances)
- OmniLight3D count < 10 simultaneous
- Shader complexity: Keep fragment operations minimal

**Bottleneck Monitoring:**
- Godot profiler: Track draw calls, physics collisions
- If FPS drops: Reduce enemy count or simplify shaders

---

## Success Metrics

**Primary Goal:** Is it fun?
- Does movement feel satisfying? (Dash responsive, momentum preserved)
- Does Trash Vision create tension? (Risk/reward is clear)
- Do you want to replay for higher scores? (One more wave syndrome)

**Secondary Goals:**
- Visual identity is memorable (harsh neon, glitch aesthetic)
- Core loop is complete (spawn, fight, die, restart)
- Technical execution is solid (no crashes, consistent FPS)

**Failure Conditions:**
- Movement feels floaty/unresponsive → Tune acceleration
- Trash Vision is ignored → Rework incentive (e.g., highlight ammo drops)
- Combat lacks impact → Add VFX juice (camera shake, particle bursts)

---

## References & Inspiration

### Game Inspirations

**SUPERHOT:**
- Minimalist aesthetic (white enemies, red highlights)
- Time manipulation creates tactical decisions
- Movement is the meta-game

**Devil Daggers:**
- Arena survival, wave-based enemies
- Lo-fi graphics (PS1-era aesthetic)
- Leaderboard-driven replayability
- Oppressive atmosphere from visual design

**Neon White:**
- Speed-running through 3D spaces
- Card mechanics (one-use abilities)
- Clean visual language (white player, colored enemies)
- Momentum preservation between actions

**Lovely Planet:**
- Primitive geometry (spheres, boxes, cylinders)
- Pastel colors (adapted to harsh neon for our theme)
- Speed-running focus
- Cute exterior, challenging core

**Quake III Arena:**
- Movement tech (strafe jumping, bunny hopping)
- Momentum-based combat
- Arena design (vertical + horizontal layers)
- Hitscan weapons (railgun instant hits)

**Mirror's Edge:**
- First-person parkour movement
- Dash/slide mechanics
- Color-coded environment navigation
- Flow state from movement mastery

### Godot Resources

**Official Documentation:**
- [CharacterBody3D](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html) - Movement implementation
- [NavigationAgent3D](https://docs.godotengine.org/en/stable/classes/class_navigationagent3d.html) - Enemy pathfinding
- [RayCast3D](https://docs.godotengine.org/en/stable/classes/class_raycast3d.html) - Hitscan weapon
- [Shader Language](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/index.html) - Grid floor, VFX

**Community Tutorials:**
- GDQuest: FPS controller tutorial (CharacterBody3D movement)
- Godot Recipes: Navigation system setup
- HeartBeast: Camera shake implementation (reusable from Pixel Pandemonium)

### Visual References

**Color Schemes:**
- Vaporwave aesthetics (cyan + magenta + purple)
- Cyberpunk neon signs (harsh contrast on black)
- Synthwave album covers (glowing grids, retro-futurism)

**Geometry Style:**
- Tron Legacy: Glowing primitive shapes
- Antichamber: Impossible geometry, stark colors
- Superhot: Clean silhouettes, high contrast

---

## Technical Constraints

**Development Context:**
- **Solo Developer:** Gero Doll
- **Timeline:** 6 weeks (flexible - prototype-driven)
- **Engine:** Godot 4.6 (Forward+ renderer)
- **Scope:** Single-level arena, no narrative, leaderboard-focused

**Asset Constraints:**
- **Zero external assets** - all CSG primitives or shaders
- **No audio** initially (visual-first design)
- **No 3D modeling software** required (CSG in-engine)

**Code Reuse:**
- HealthComponent from Pixel Pandemonium
- CameraShake component from Pixel Pandemonium
- GameManager pattern (autoload singleton)

**Hard Limits:**
- Max 20 enemies alive simultaneously (performance)
- Single weapon (no inventory system)
- Single arena (no level selection)
- No multiplayer (local single-player only)

---

## Design Philosophy

**"Trash Game" as Artistic Choice:**
- Embrace lo-fi constraints - don't apologize for them
- Bugs become features (glitch aesthetic)
- Raw, experimental, unpolished = authentic
- Strong identity from limitations, not despite them

**One Mechanic, Done Well:**
- Trash Vision is the hook - everything supports it
- No feature creep (no crafting, no skill trees, no loot)
- Depth from mastery, not complexity
- If it doesn't serve the core loop, cut it

**Fast Iteration > Perfect Planning:**
- Build MVP first, polish last
- Playtest early (does Trash Vision feel good?)
- Fail fast (if mechanic doesn't work, pivot)
- Scope cuts are expected, not failures

---

## Open Questions (To Resolve During Development)

1. **Trash Vision Duration:** Is 2 seconds too long? Too short?
   - Playtest with 1.5s, 2.0s, 2.5s variants
   - Track: Does player feel rushed or bored?

2. **Ammo Scarcity:** Should starting ammo be higher (90 instead of 60)?
   - Test: Do players run out before first kill?
   - Balance: Scarcity vs. frustration

3. **Enemy Count Scaling:** Linear (wave * 2) or exponential?
   - Current: Wave 1 = 3, Wave 2 = 5, Wave 3 = 7
   - Alternative: Wave 1 = 3, Wave 2 = 6, Wave 3 = 12 (exponential)

4. **Headshot Hitbox Size:** How forgiving should it be?
   - Test with CollisionShape radius: 0.2, 0.3, 0.5
   - Balance: Skill ceiling vs. accessibility

5. **Wall-Running Necessity:** Does core loop need it, or is dash enough?
   - Build MVP without wall-run first
   - Add only if playtesting reveals vertical mobility gap

---

## Changelog

**v1.0 (2026-02-12):**
- Initial GDD creation
- Defined Trash Vision mechanic as unique hook
- Established neon-on-black visual identity
- Outlined 6-week development roadmap (MVP → Alpha → Polish)
- Technical specs for Godot 4.6 implementation

---

**END OF DOCUMENT**

*This is a living document - update as design evolves during development.*
