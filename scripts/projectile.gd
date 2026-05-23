extends Area2D
## Ranged energy blast fired by the player (and potentially enemies).
## Call setup() immediately after instantiating.

const SPEED: float = 500.0

var direction: Vector2   = Vector2.RIGHT
var damage: int          = 20
var target_group: String = "enemies"

@onready var visual: Polygon2D = $Visual
@onready var life_timer: Timer = $LifeTimer


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	life_timer.timeout.connect(queue_free)
	life_timer.start()


## dir     – normalised travel direction
## dmg     – damage dealt on impact
## group   – group name of valid targets (e.g. "enemies" or "player")
func setup(dir: Vector2, dmg: int, group: String) -> void:
	direction    = dir.normalized()
	damage       = dmg
	target_group = group
	# Rotate the visual to face travel direction
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(damage)
	queue_free()
