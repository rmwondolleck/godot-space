extends CanvasLayer
## Heads-up display: health bar, XP bar, level, score, kill count, inventory.

@onready var health_bar:   ProgressBar = $TopLeft/HealthRow/HealthBar
@onready var health_label: Label       = $TopLeft/HealthRow/HealthLabel
@onready var xp_bar:       ProgressBar = $TopLeft/XPRow/XPBar
@onready var level_label:  Label       = $TopLeft/LevelLabel
@onready var score_label:  Label       = $TopRight/ScoreLabel
@onready var kill_label:   Label       = $TopRight/KillLabel
@onready var inv_energy:   Label       = $BottomLeft/InvRow/EnergyLabel
@onready var inv_credits:  Label       = $BottomLeft/InvRow/CreditsLabel
@onready var inv_mats:     Label       = $BottomLeft/InvRow/MatsLabel


func _ready() -> void:
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.pickup_collected.connect(_on_pickup_collected)

	# Set initial display values
	health_bar.max_value = 100
	health_bar.value     = 100
	health_label.text    = "100 / 100"
	xp_bar.max_value     = 100
	xp_bar.value         = 0
	level_label.text     = "LV 1"
	score_label.text     = "SCORE  0"
	kill_label.text      = "KILLS  0"
	_refresh_inventory()


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value     = current
	health_label.text    = "%d / %d" % [current, maximum]


func _on_xp_changed(current: int, maximum: int) -> void:
	xp_bar.max_value = maximum
	xp_bar.value     = current


func _on_level_changed(new_level: int) -> void:
	level_label.text = "LV %d" % new_level
	# Grant the player a stat bonus on level-up
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("apply_level_bonus"):
		players[0].apply_level_bonus()


func _on_score_changed(new_score: int) -> void:
	score_label.text = "SCORE  %d" % new_score
	kill_label.text  = "KILLS  %d" % GameManager.enemy_kills


func _on_pickup_collected(_type: String) -> void:
	_refresh_inventory()


func _refresh_inventory() -> void:
	inv_energy.text  = "* %d" % GameManager.inventory.get("energy_cell",     0)
	inv_credits.text = "$ %d" % GameManager.inventory.get("credits",         0)
	inv_mats.text    = "+ %d" % GameManager.inventory.get("upgrade_material", 0)
