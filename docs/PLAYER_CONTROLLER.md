# Player Controller Documentation

A **snappy**, responsive first-person character controller with satisfying shooting mechanics.

## Features

- ✅ **Snappy Movement** - High acceleration/friction for responsive controls
- ✅ **First-person mouse look** with FOV changes
- ✅ **Sprint** (Hold Shift) - Increases FOV dynamically
- ✅ **Jump** with coyote time, jump buffering, AND variable jump height
- ✅ **Fast Fall** - Press S/down in air to fall faster
- ✅ **Dodge/Roll** (Q or Ctrl) - Quick invincible dash
- ✅ **Shooting** - Full-auto hitscan weapon with recoil
- ✅ **Aim** (Right Click) - Reduces FOV, slower movement
- ✅ **Weapon Bob** - Visual feedback when moving
- ✅ **Screen Shake** - Trauma-based shake system
- ✅ **Muzzle Flash** - Light and visual kickback

## Controls

| Action | Key | Description |
|--------|-----|-------------|
| Move | W, A, S, D | Snappy directional movement |
| Look | Mouse | First-person camera |
| Jump | Space | Variable height (hold longer = higher) |
| Sprint | Shift | Faster speed + wider FOV |
| Dodge | Q / Ctrl | Quick dash with iframes |
| Fire | Left Click | Full-auto shooting |
| Aim | Right Click | Precision mode |
| Interact | E | Use objects |
| Pause | Escape | Toggle pause menu |

## Snappy Movement Values

These values make movement feel tight and responsive:

```gdscript
walk_speed = 8.0           # Faster base speed
sprint_speed = 12.0        # Quick sprint
acceleration = 80.0        # SNAP into movement
friction = 60.0            # SNAP to stop
gravity = 25.0             # Heavy, snappy falls
jump_velocity = 12.0       # High jumps
jump_cut_multiplier = 0.4  # Tap space = small hop, hold = full jump
```

## Shooting Mechanics

### Hitscan System
- Instant raycast hit detection
- No projectile travel time
- Accurate at all distances

### Recoil
- Vertical kick (gun rises)
- Random horizontal spread
- Automatic recovery
- Affects aim over sustained fire

### Full-Auto
- Hold LMB to fire continuously
- Fire rate: 12 shots/second
- Damage: 25 per shot

### Visual Feedback
- **Muzzle flash** - Brief light at gun barrel
- **Gun kick** - Weapon physically kicks back
- **Screen shake** - Trauma-based shake on every shot
- **Impact sparks** - Yellow glow at hit location
- **Target flash** - White flash on damaged enemies

## Exported Properties

### Movement (SNAPPY)
- `walk_speed`: 8.0 - Fast walking
- `sprint_speed`: 12.0 - Quick sprint
- `acceleration`: 80.0 - High for snappy starts
- `friction`: 60.0 - High for snappy stops
- `air_control`: 0.4 - Decent air movement
- `gravity`: 25.0 - Heavy gravity
- `fast_fall_multiplier`: 1.5 - Press down to fall faster

### Jump
- `jump_velocity`: 12.0 - High jump
- `jump_cut_multiplier`: 0.4 - Release early for shorter jumps
- `coyote_time`: 0.12 - Grace period after leaving ground
- `jump_buffer`: 0.12 - Input buffer

### Weapon
- `fire_rate`: 12.0 - Shots per second
- `damage`: 25 - Damage per shot
- `recoil_strength`: 0.04 - How much kick
- `recoil_recovery`: 5.0 - How fast to recover
- `weapon_range`: 100.0 - Max raycast distance

### Mouse Look
- `mouse_sensitivity`: 0.002
- `normal_fov`: 90.0
- `sprint_fov`: 100.0 - Widens when sprinting
- `fov_change_speed`: 10.0 - Smooth FOV transitions

## Scene Structure

```
Player (CharacterBody3D)
├── CollisionShape3D (Capsule)
├── MeshInstance3D (Debug capsule - hidden)
├── Head (Node3D)
│   ├── CameraShake (CameraShake component)
│   │   ├── Camera3D
│   │   │   └── RayCast3D (Weapon ray)
│   │   └── WeaponHolder
│   │       ├── GunBody (Mesh)
│   │       ├── GunBarrel (Mesh)
│   │       └── MuzzlePosition (Marker3D)
├── Timers
│   ├── DodgeTimer
│   ├── CoyoteTimer
│   ├── JumpBufferTimer
│   └── DodgeCooldownTimer
└── HealthComponent
```

## Testing

1. Open `scenes/test_level.tscn`
2. Press F5 to play
3. **Movement**: Try quick direction changes - should feel snappy
4. **Jump**: Tap space for small hop, hold for full jump
5. **Shoot**: Hold LMB at targets - watch recoil and impacts
6. **Sprint**: Hold Shift - FOV widens, gun bobs more
7. **Dodge**: Press Q to dash

## Target Practice

The test level includes:
- **3 Red Targets** - Static targets with health, flash white when hit, explode when destroyed
- **2 Physics Crates** - Shoot to push them around

Destroy targets to see the debris explosion effect!

## Tips for "Game Feel"

### Already Implemented
- ✅ Screen shake on every shot
- ✅ Gun kick animation
- ✅ Muzzle flash light
- ✅ Impact effects
- ✅ FOV changes
- ✅ Weapon bob when moving
- ✅ Fast fall for snappy platforming
- ✅ Variable jump height

### To Add Later
- Footstep sounds
- Bullet whiz-by sounds
- Ricochet effects
- Shell casing ejection
- Crosshair
- Hit markers
- Damage numbers

## Code Example: Applying Camera Shake

```gdscript
# From anywhere in player
var shake := $Head/CameraShake
shake.add_trauma(0.5)  # 0-1 scale

# Or use presets
shake.explosion()      # Maximum shake
shake.gun_recoil()     # Light shake
shake.strong_impact()  # Medium shake
```

## Troubleshooting

**Gun fires but no effects:**
- Check RayCast3D collision mask
- Ensure targets have HealthComponent

**Movement feels floaty:**
- Check acceleration is set to 80.0+
- Check friction is set to 60.0+

**Too much screen shake:**
- Reduce `max_offset` in CameraShake
- Reduce trauma amount when calling add_trauma()

**Can't hit targets:**
- Check target is on proper collision layer
- RayCast3D collision_mask should include target layer

---

*Updated: 2026-02-11 - Now with SNAPPY movement and satisfying SHOOTING!*
