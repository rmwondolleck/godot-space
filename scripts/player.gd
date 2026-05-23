extends CharacterBody2D
## Player character: 8-directional movement, three attack modes, health system.

# ---------- signals ----------
signal health_changed(current_hp: int, max_hp: int)

# ---------- constants ----------
const MOVE_SPEED: float = 220.0
const WORLD_LIMIT: float = 920.0

const BASE_MAX_HP: int = 100
const LIGHT_DAMAGE: int = 15
const HEAVY_DAMAGE: int = 35
const RANGED_DAMAGE: int = 20
const LIGHT_RANGE: float = 55.0
const HEAVY_RANGE: float = 65.0

const LIGHT_COOLDOWN: float = 0.40
const HEAVY_COOLDOWN: float = 0.90
const RANGED_COOLDOWN: float = 0.45
const INVINCIBLE_TIME: float = 0.60

# ---------- state ----------
var max_hp: int = BASE_MAX_HP
var current_hp: int = BASE_MAX_HP
var is_dead: bool = false
var invincible: bool = false
var inv_timer: float = 0.0

var light_cd: float = 0.0
var heavy_cd: float = 0.0
var ranged_cd: float = 0.0

var facing: Vector2 = Vector2.RIGHT

# ---------- nodes ----------
@onready var visual: Polygon2D = $Visual
@onready var camera: Camera2D = $Camera2D

var _projectile_scene: PackedScene


func _ready() -> void:
	add_to_group("player")
	_projectile_scene = load("res://scenes/projectile.tscn")
	# Broadcast initial health to the UI
	GameManager.health_changed.emit(current_hp, max_hp)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_tick(delta)
	_move()
	_handle_attacks()
	move_and_slide()
	# Hard boundary so the player cannot leave the drawn world
	position.x = clamp(position.x, -WORLD_LIMIT, WORLD_LIMIT)
	position.y = clamp(position.y, -WORLD_LIMIT, WORLD_LIMIT)


# ---------- per-frame helpers ----------

func _tick(delta: float) -> void:
	light_cd  = max(0.0, light_cd  - delta)
	heavy_cd  = max(0.0, heavy_cd  - delta)
	ranged_cd = max(0.0, ranged_cd - delta)
	if invincible:
		inv_timer -= delta
		if inv_timer <= 0.0:
			invincible = false
			visual.modulate = Color.WHITE


func _move() -> void:
	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up",   "move_down")
	)
	if dir != Vector2.ZERO:
		dir    = dir.normalized()
		facing = dir
	velocity = dir * MOVE_SPEED


func _handle_attacks() -> void:
	if Input.is_action_just_pressed("attack_light")  and light_cd  <= 0.0:
		_light_attack()
	if Input.is_action_just_pressed("attack_heavy")  and heavy_cd  <= 0.0:
		_heavy_attack()
	if Input.is_action_just_pressed("attack_ranged") and ranged_cd <= 0.0:
		_ranged_attack()


# ---------- attacks ----------

func _light_attack() -> void:
	light_cd = LIGHT_COOLDOWN
	visual.color = Color(1.0, 1.0, 0.2)
	_deal_melee(LIGHT_DAMAGE, LIGHT_RANGE)
	_reset_color_after(0.12)


func _heavy_attack() -> void:
	heavy_cd = HEAVY_COOLDOWN
	visual.color = Color(1.0, 0.5, 0.0)
	_deal_melee(HEAVY_DAMAGE, HEAVY_RANGE)
	_reset_color_after(0.20)


func _deal_melee(damage: int, range: float) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var diff: Vector2 = enemy.global_position - global_position
		# Must be in range AND in roughly the facing arc (dot > 0.2 = ~78° half-angle)
		if diff.length() <= range and facing.dot(diff.normalized()) > 0.2:
			enemy.take_damage(damage)


func _ranged_attack() -> void:
	ranged_cd = RANGED_COOLDOWN
	var proj: Node2D = _projectile_scene.instantiate()
	# Projectiles live in the World node (player's parent)
	get_parent().add_child(proj)
	proj.global_position = global_position + facing * 28.0
	proj.setup(facing, RANGED_DAMAGE, "enemies")


# ---------- public health API ----------

func take_damage(amount: int) -> void:
	if is_dead or invincible:
		return
	current_hp = max(0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)
	GameManager.health_changed.emit(current_hp, max_hp)
	invincible   = true
	inv_timer    = INVINCIBLE_TIME
	visual.modulate = Color(1.0, 0.35, 0.35)
	if current_hp <= 0:
		_die()


func heal(amount: int) -> void:
	if is_dead:
		return
	current_hp = min(current_hp + amount, max_hp)
	health_changed.emit(current_hp, max_hp)
	GameManager.health_changed.emit(current_hp, max_hp)


## Called by ui.gd whenever the player levels up.
func apply_level_bonus() -> void:
	max_hp    += 10
	current_hp = max_hp
	health_changed.emit(current_hp, max_hp)
	GameManager.health_changed.emit(current_hp, max_hp)


# ---------- private ----------

func _reset_color_after(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(self) and not is_dead:
		visual.color = Color(0.2, 0.8, 1.0)


func _die() -> void:
	is_dead = true
	visual.color    = Color(0.5, 0.0, 0.1)
	visual.modulate = Color.WHITE
	set_physics_process(false)
	GameManager.player_died.emit()
