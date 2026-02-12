# Pixel Pandemonium - Feature Plan

A 3D action game with physics-based chaos, crystal collection objectives, and pixel-retro aesthetics.

---

## 🎯 Core Vision

**Genre:** 3D Action / Physics Sandbox  
**Core Loop:** Fight waves of enemies → Collect/Protect Crystal Cores → Cause Destruction  
**Aesthetic:** Pixel-perfect 3D with retro-modern visuals  
**Mood:** Chaotic, fast-paced, satisfying destruction

---

## ✅ Phase 1: Foundation (Core Mechanics)

### Player Systems
| Feature | Priority | Description |
|---------|----------|-------------|
| First-Person Controller | 🔴 Critical | WASD movement, mouse look, jump |
| Sprint & Dodge | 🔴 Critical | Shift to sprint, Space-double-tap to dodge |
| Weapon System | 🔴 Critical | Primary fire, alt-fire, melee attack |
| Health & Death | 🔴 Critical | Health bar, damage feedback, respawn |
| Interaction System | 🟡 High | Pick up, throw objects, activate buttons |

### Combat
| Feature | Priority | Description |
|---------|----------|-------------|
| Hitbox/Hurtbox Components | 🔴 Critical | Reusable damage system for all entities |
| Weapon: Blaster | 🔴 Critical | Rapid-fire projectile weapon |
| Weapon: Shotgun | 🟡 High | Spread shot, close-range |
| Weapon: Explosive | 🟡 High | Area damage, physics impulse |
| Melee Attack | 🟡 High | Quick knife/punch with knockback |

### Physics & Destruction
| Feature | Priority | Description |
|---------|----------|-------------|
| Destructible Props | 🔴 Critical | Objects that break into physics debris |
| Physics Impulse Weapons | 🟡 High | Weapons that push objects/enemies |
| Environmental Hazards | 🟡 High | Explosive barrels, falling objects |
| Explosion System | 🟡 High | Radial damage + physics force |

---

## ✅ Phase 2: Content (Enemies & Objectives)

### Enemy Types
| Enemy | Behavior | Priority |
|-------|----------|----------|
| Grunt | Basic melee rush | 🔴 Critical |
| Shooter | Ranged attacks from distance | 🔴 Critical |
| Charger | Fast rush attack with wind-up | 🟡 High |
| Tank | High health, slow, ground slam | 🟡 High |
| Bomber | Explodes on death/proximity | 🟡 High |
| Swarmer | Small, weak, spawns in groups | 🟢 Medium |

### AI Systems
| Feature | Priority | Description |
|---------|----------|-------------|
| Navigation (NavigationAgent3D) | 🔴 Critical | Pathfinding around obstacles |
| Vision/Detection System | 🔴 Critical | Line-of-sight, aggro range |
| Attack States | 🔴 Critical | Approach, attack, retreat behaviors |
| Wave Spawning System | 🟡 High | Configurable spawn points and timing |

### Objective System
| Feature | Priority | Description |
|---------|----------|-------------|
| Crystal Core (Collectible) | 🔴 Critical | Primary objective - pick up & extract |
| Crystal Defense Mode | 🟡 High | Protect crystal from waves |
| Extraction Zone | 🟡 High | Delivery point for collected crystals |
| Multi-Crystal Levels | 🟢 Medium | Multiple crystals to find |

---

## ✅ Phase 3: Progression & Meta

### Player Progression
| Feature | Priority | Description |
|---------|----------|-------------|
| Weapon Upgrades | 🟡 High | Damage, fire rate, magazine size |
| Passive Abilities | 🟢 Medium | Health boost, speed, pickup radius |
| Unlockable Weapons | 🟢 Medium | New weapons earned through progress |
| Player Rank/Level | 🟢 Medium | XP system for completing objectives |

### Economy
| Feature | Priority | Description |
|---------|----------|-------------|
| Score System | 🟡 High | Points for kills, destruction, speed |
| Credits/Currency | 🟢 Medium | Spend on upgrades between rounds |
| Combo Multiplier | 🟢 Medium | Chain kills for bonus points |

---

## ✅ Phase 4: Levels & Environments

### Level Design
| Feature | Priority | Description |
|---------|----------|-------------|
| Arena Levels (3) | 🔴 Critical | Combat-focused enclosed spaces |
| Exploration Levels (2) | 🟡 High | Larger maps with hidden crystals |
| Dynamic Elements | 🟡 High | Moving platforms, breakable walls |
| Spawn Points | 🟡 High | Player respawn, enemy spawn markers |

### Environmental Features
| Feature | Priority | Description |
|---------|----------|-------------|
| Destructible Cover | 🟡 High | Walls/crates that break under fire |
| Verticality | 🟢 Medium | Jump pads, ladders, multiple floors |
| Traps | 🟢 Medium | Floor spikes, crushing walls |

---

## ✅ Phase 5: Polish & Juice

### Visual Effects
| Feature | Priority | Description |
|---------|----------|-------------|
| Muzzle Flashes | 🔴 Critical | Weapon firing feedback |
| Hit/Impact Particles | 🔴 Critical | Bullet hits, explosion sparks |
| Screen Shake | 🟡 High | Explosions, heavy impacts |
| Damage Indicators | 🟡 High | Directional red flash when hit |
| Destruction Debris | 🟡 High | Physics chunks with particle trails |
| Crystal Glow Effects | 🟡 High | Collectible/important highlight |

### Audio
| Feature | Priority | Description |
|---------|----------|-------------|
| Weapon SFX | 🔴 Critical | Firing, reloading, impacts |
| Explosion SFX | 🔴 Critical | Varied by size |
| Enemy Vocalizations | 🟡 High | Alert, attack, death sounds |
| UI Sounds | 🟡 High | Menu clicks, pickup sounds |
| Music System | 🟡 High | Combat music, ambient tracks |
| Destruction Sounds | 🟢 Medium | Object breaking, debris |

### UI/UX
| Feature | Priority | Description |
|---------|----------|-------------|
| HUD (Health, Ammo, Score) | 🔴 Critical | Persistent on-screen info |
| Crosshair | 🔴 Critical | Center-screen aiming reticle |
| Damage Numbers | 🟡 High | Floating combat text |
| Minimap | 🟢 Medium | Nearby enemy/objective indicators |
| Main Menu | 🟡 High | Start, options, quit |
| Pause Menu | 🟡 High | Resume, restart, settings |
| Game Over Screen | 🟡 High | Stats, retry, return to menu |

---

## ✅ Phase 6: Technical Systems

### Core Infrastructure
| Feature | Priority | Description |
|---------|----------|-------------|
| Save/Load System | 🟡 High | Progress persistence |
| Settings (Graphics, Audio, Controls) | 🟡 High | Player preferences |
| Scene Manager | 🔴 Critical | Level transitions with loading |
| Event Bus (Autoload) | 🔴 Critical | Decoupled communication |
| Object Pooling | 🟡 High | Bullets, debris for performance |

### Performance
| Feature | Priority | Description |
|---------|----------|-------------|
| Visibility-based Culling | 🟡 High | Disable off-screen objects |
| Debris Cleanup System | 🟡 High | Remove old physics objects |
| LOD System | 🟢 Medium | Simplified distant models |
| FPS Counter | 🟢 Medium | Debug/optimization tool |

---

## 🎨 Visual Style Guide

### Pixel 3D Aesthetic
- **Rendering:** Low-res render target upscaled (pixelated look)
- **Textures:** Pixel art textures with nearest filtering
- **Models:** Low-poly with sharp edges
- **Colors:** Vibrant, high contrast
- **Lighting:** Dynamic with hard shadows

### UI Style
- **Font:** Pixel/bitmap font
- **Elements:** Blocky, retro-futuristic
- **Colors:** Neon accents on dark backgrounds

---

## 📁 Implementation Priority

### Week 1-2: Foundation
1. Player controller with sprint/dodge
2. Basic weapon (blaster) with projectiles
3. Hitbox/hurtbox system
4. Simple enemy (Grunt) with basic AI
5. Health/damage system

### Week 3-4: Core Loop
1. Crystal collectible objective
2. Enemy wave spawning
3. 2-3 weapon types
4. Destructible props
5. Basic arena level

### Week 5-6: Content
1. 3+ enemy types
2. 2+ level layouts
3. Upgrade system
4. Score/combo system

### Week 7-8: Polish
1. VFX (particles, screen shake)
2. Audio (SFX, music)
3. UI polish
4. Menus
5. Save/load

---

## 🔧 Technical Recommendations

### Physics
- Consider **Godot Jolt** for better 3D physics stability
- Use `MultiMeshInstance3D` for debris optimization
- Limit simultaneous rigid bodies (cleanup old debris)

### Architecture
- Component-based design (HealthComponent, WeaponComponent, etc.)
- Autoloads: GameManager, AudioManager, SceneManager, EventBus
- Signals for loose coupling between systems

### Rendering
- SubViewport for pixel-perfect 3D rendering
- `rendering/textures/canvas_textures/default_texture_filter = Nearest`

---

## 📝 Notes

- Start simple: Get player movement + one enemy + one objective working first
- Focus on "feel" early: Screen shake, responsive controls, impact feedback
- Test destruction physics early - may need optimization
- Balance chaos with readability (too much debris = confusion)

---

*Last Updated: 2026-02-11*
