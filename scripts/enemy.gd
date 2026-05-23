extends CharacterBody2D
## Enemy AI: chases the player, attacks on contact, drops loot on death.

const MOVE_SPEED: float    = 80.0
const DETECTION_RANGE: float = 600.0
const ATTACK_RANGE: float  = 38.0
const ATTACK_DAMAGE: int   = 12
const MAX_HP: int           = 40
const XP_REWARD: int        = 20
const SCORE_REWARD: int     = 50
const WORLD_LIMIT: float    = 950.0

var current_hp: int  = MAX_HP
var is_dead: bool    = false
var player_ref: Node2D = null   # set by world.gd at spawn time

@onready var visual: Polygon2D = $Visual
@onready var attack_timer: Timer = $AttackTimer

var _pickup_scene: PackedScene


func _ready() -> void:
	add_to_group("enemies")
	_pickup_scene = load("res://scenes/pickup.tscn")
	attack_timer.timeout.connect(_on_attack_timer)
	attack_timer.start()


func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	if not is_instance_valid(player_ref):
		velocity = Vector2.ZERO
		return

	var to_player: Vector2 = player_ref.global_position - global_position
	var dist: float        = to_player.length()

	velocity = to_player.normalized() * MOVE_SPEED if dist < DETECTION_RANGE else Vector2.ZERO

	move_and_slide()
	position.x = clamp(position.x, -WORLD_LIMIT, WORLD_LIMIT)
	position.y = clamp(position.y, -WORLD_LIMIT, WORLD_LIMIT)


func _on_attack_timer() -> void:
	if is_dead or not is_instance_valid(player_ref):
		return
	if global_position.distance_to(player_ref.global_position) <= ATTACK_RANGE:
		if player_ref.has_method("take_damage"):
			player_ref.take_damage(ATTACK_DAMAGE)


func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_hp -= amount
	visual.modulate = Color(1.5, 0.5, 0.5)
	if current_hp <= 0:
		_die()
	else:
		_recover_flash()


func _recover_flash() -> void:
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(self) and not is_dead:
		visual.modulate = Color.WHITE


func _die() -> void:
	is_dead = true
	set_physics_process(false)
	visual.color    = Color(0.35, 0.07, 0.07)
	visual.modulate = Color.WHITE
	GameManager.on_enemy_killed(XP_REWARD, SCORE_REWARD)
	_drop_loot()
	await get_tree().create_timer(0.4).timeout
	if is_instance_valid(self):
		queue_free()


func _drop_loot() -> void:
	# 60 % chance to drop something
	if randf() > 0.6:
		return
	var types   := ["energy_cell", "credits", "upgrade_material"]
	var weights := [0.50,           0.35,      0.15]
	var roll    := randf()
	var cumulative := 0.0
	var chosen := "credits"
	for i in range(types.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			chosen = types[i]
			break

	var pickup: Node2D = _pickup_scene.instantiate()
	get_parent().add_child(pickup)
	pickup.global_position = global_position + Vector2(
		randf_range(-20.0, 20.0), randf_range(-20.0, 20.0)
	)
	pickup.pickup_type = chosen
