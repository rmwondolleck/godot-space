extends Node2D
## Game world: draws the isometric floor, spawns the player, enemies, and pickups.

const WORLD_SIZE:   float = 1900.0
const HALF:         float = WORLD_SIZE * 0.5
const ENEMY_COUNT:  int   = 12
const PICKUP_COUNT: int   = 8

# Isometric tile dimensions
const ISO_W: int = 80
const ISO_H: int = 40
const COLS:  int = 24   # tiles to each side of centre
const ROWS:  int = 24

@onready var enemies_node: Node2D = $Enemies
@onready var pickups_node: Node2D = $Pickups

var _player_scene: PackedScene = preload("res://scenes/player.tscn")
var _enemy_scene:  PackedScene = preload("res://scenes/enemy.tscn")
var _pickup_scene: PackedScene = preload("res://scenes/pickup.tscn")

var player: Node2D


func _ready() -> void:
	_spawn_player()
	_spawn_enemies()
	_spawn_pickups()
	queue_redraw()


func _draw() -> void:
	# ---- isometric floor ----
	for col in range(-COLS, COLS + 1):
		for row in range(-ROWS, ROWS + 1):
			var cx: float = (col - row) * ISO_W * 0.5
			var cy: float = (col + row) * ISO_H * 0.5
			var pts := PackedVector2Array([
				Vector2(cx,               cy - ISO_H * 0.5),  # top
				Vector2(cx + ISO_W * 0.5, cy),                # right
				Vector2(cx,               cy + ISO_H * 0.5),  # bottom
				Vector2(cx - ISO_W * 0.5, cy),                # left
			])
			# Cycle through three shades to create a readable grid pattern
			var tile_shade_index: int = (absi(col) + absi(row)) % 3
			var tile_color: Color
			match tile_shade_index:
				0: tile_color = Color(0.07, 0.09, 0.14)
				1: tile_color = Color(0.09, 0.11, 0.17)
				_: tile_color = Color(0.06, 0.08, 0.12)
			draw_polygon(pts, PackedColorArray([tile_color]))
			draw_polyline(
				PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]),
				Color(0.18, 0.22, 0.32, 0.45), 1.0
			)

	# ---- border wall ----
	draw_rect(
		Rect2(-HALF, -HALF, WORLD_SIZE, WORLD_SIZE),
		Color(0.3, 0.6, 1.0, 0.7), false, 4.0
	)
	# Corner accent marks
	var corners := [
		Vector2(-HALF, -HALF), Vector2(HALF, -HALF),
		Vector2(HALF,  HALF),  Vector2(-HALF, HALF),
	]
	for c in corners:
		draw_circle(c, 8.0, Color(0.5, 0.8, 1.0))


# ---------- spawn helpers ----------

func _spawn_player() -> void:
	player = _player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2.ZERO


func _spawn_enemies() -> void:
	for _i in range(ENEMY_COUNT):
		var pos  := _rand_pos(150.0, 860.0)
		var enemy: Node2D = _enemy_scene.instantiate()
		enemies_node.add_child(enemy)
		enemy.global_position = pos
		enemy.player_ref      = player


func _spawn_pickups() -> void:
	var types := [
		"energy_cell", "credits", "upgrade_material",
		"credits",     "energy_cell", "credits",
		"upgrade_material", "energy_cell",
	]
	for i in range(PICKUP_COUNT):
		var pos    := _rand_pos(100.0, 800.0)
		var pickup: Node2D = _pickup_scene.instantiate()
		pickups_node.add_child(pickup)
		pickup.global_position = pos
		pickup.pickup_type     = types[i % types.size()]


func _rand_pos(min_dist: float, max_dist: float) -> Vector2:
	var angle := randf() * TAU
	var dist  := randf_range(min_dist, max_dist)
	return Vector2(cos(angle), sin(angle)) * dist
