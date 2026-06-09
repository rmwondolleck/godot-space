extends Area2D
## Collectible loot item. Set pickup_type before adding to the scene tree.
## Supported types: "energy_cell", "credits", "upgrade_material"

var pickup_type: String = "credits"

@onready var visual: Polygon2D = $Visual


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_visual()
	# Gentle pulse so the player notices pickups
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(visual, "scale", Vector2(1.25, 1.25), 0.55)
	tween.tween_property(visual, "scale", Vector2(1.0,  1.0),  0.55)


func _apply_visual() -> void:
	match pickup_type:
		"energy_cell":
			visual.color = Color(0.2, 1.0, 0.45)   # bright green
		"credits":
			visual.color = Color(1.0, 0.85, 0.1)   # gold
		"upgrade_material":
			visual.color = Color(0.65, 0.3, 1.0)   # purple
		_:
			visual.color = Color(0.8, 0.8, 0.8)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameManager.on_pickup_collected(pickup_type, body)
		queue_free()
