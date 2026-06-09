# Godot Space

A top-down isometric space action RPG prototype built in **Godot 4.2+**.

Explore a derelict alien moon base, fight hostile drones, collect loot, level up, and survive as long as you can.

---

## How to Run

1. **Install Godot 4.2+** from https://godotengine.org/download  
   (the standard/non-Mono build is fine).
2. Open Godot and choose **Import Project**.
3. Navigate to the cloned `godot-space/` folder and select `project.godot`.
4. Click **Import & Edit**, then press **F5** (or the ▶ Play button) to run.

No extra plugins or assets are needed – the prototype uses procedurally drawn shapes.

---

## Controls

| Action | Keyboard | Mouse |
|---|---|---|
| Move | **WASD** or **Arrow Keys** | – |
| Light Attack | **Z** | Left click |
| Heavy Attack | **X** | Right click |
| Ranged Blast | **Space** or **C** | – |
| Interact (future) | **E** or **F** | – |

---

## Gameplay Loop

* **Move** around the isometric arena.
* **Enemies** (red diamonds) chase you once you are in range and deal melee damage on contact.
* Use **Light Attack** (fast, low damage) or **Heavy Attack** (slow, high damage) to hit enemies in melee range in the direction you are facing.
* Fire an **Energy Blast** as a ranged attack that travels in your facing direction.
* Killed enemies drop **loot** (60 % chance):
  * 🟢 **Energy Cell** – restores 30 HP and adds 50 score.
  * 🟡 **Credits** – adds 25 score.
  * 🟣 **Upgrade Material** – adds 100 score.
* Each kill earns **XP**. Filling the XP bar triggers a **Level Up**, increasing max HP and fully healing you.
* If your HP reaches 0 a **Game Over** screen shows your final score, level, and kill count. Press **RESTART** to play again.

---

## Project Structure

```
godot-space/
├── project.godot           – Godot project settings, input map, autoload
├── scripts/
│   ├── game_manager.gd     – Autoload singleton: score, XP, level, signals
│   ├── player.gd           – Movement, attacks, health, death
│   ├── enemy.gd            – Chase AI, melee attack, loot drop
│   ├── projectile.gd       – Ranged energy blast
│   ├── pickup.gd           – Collectible loot item
│   ├── ui.gd               – HUD (health, XP, level, score, inventory)
│   ├── world.gd            – Isometric floor draw, enemy/pickup spawning
│   ├── game_over.gd        – Game-over overlay & restart
│   └── main.gd             – Root scene coordinator
└── scenes/
    ├── main.tscn           – Root scene (assembles everything)
    ├── world.tscn          – World node with Enemies/Pickups containers
    ├── player.tscn         – CharacterBody2D + hexagon placeholder
    ├── enemy.tscn          – CharacterBody2D + diamond placeholder
    ├── projectile.tscn     – Area2D + yellow elongated diamond
    ├── pickup.tscn         – Area2D + coloured diamond
    ├── ui.tscn             – CanvasLayer HUD
    └── game_over.tscn      – CanvasLayer game-over screen
```

### Signal flow

```
player.gd ──► GameManager.health_changed ──► ui.gd
enemy.gd  ──► GameManager.on_enemy_killed ──► (score + XP) ──► ui.gd
pickup.gd ──► GameManager.on_pickup_collected ──► (heal/score) ──► ui.gd
player.gd ──► GameManager.player_died ──► game_over.gd
```

---

## Collision Layers

| Layer | Bit | Used by |
|---|---|---|
| World | 1 | (reserved for static walls in future) |
| Player | 2 | `Player` CharacterBody2D |
| Enemies | 4 | `Enemy` CharacterBody2D |
| Player attacks | 8 | `Projectile` Area2D |
| Pickups | 32 | `Pickup` Area2D |

Melee attacks use group queries (`get_nodes_in_group("enemies")`) with distance + facing-direction checks instead of separate hit-box nodes.

---

## Swapping In Real Assets

All visuals are `Polygon2D` placeholder shapes.  To replace with real sprites:

1. Add a `Sprite2D` node alongside or instead of the `Polygon2D` child.
2. Drag your texture into `Sprite2D.texture`.
3. Adjust `offset` so the sprite is centred over the `CollisionShape2D`.
4. Remove or hide the `Polygon2D`.

For proper isometric tiles, replace `world.gd`'s `_draw()` with a `TileMap` node configured for isometric tiles (Project Settings → General → Use Isometric tiles).

---

## Epics / Roadmap

- [x] **Epic 1** – Project setup, input map, main scene, autoload
- [x] **Epic 2** – Player movement, camera, isometric floor
- [x] **Epic 3** – Combat, enemy AI, health system
- [x] **Epic 4** – Loot, UI, XP progression
- [ ] **Epic 5** – Procedural room/level generation, locked doors
- [ ] **Epic 6** – Polish: VFX particles, audio, real sprite assets, abilities