extends CanvasLayer
## Game-over overlay shown when the player dies.
## process_mode = ALWAYS so the Restart button works while the tree is paused.

@onready var score_label:  Label  = $Center/VBox/ScoreLabel
@onready var level_label:  Label  = $Center/VBox/LevelLabel
@onready var kill_label:   Label  = $Center/VBox/KillLabel
@onready var restart_btn:  Button = $Center/VBox/RestartButton


func _ready() -> void:
	visible = false
	GameManager.player_died.connect(_on_player_died)
	restart_btn.pressed.connect(_on_restart)


func _on_player_died() -> void:
	score_label.text = "SCORE  %d" % GameManager.score
	level_label.text = "LEVEL  %d" % GameManager.player_level
	kill_label.text  = "KILLS  %d" % GameManager.enemy_kills
	visible = true
	# Pause the world; the game-over CanvasLayer keeps running (ALWAYS mode)
	get_tree().paused = true


func _on_restart() -> void:
	get_tree().paused = false
	GameManager.reset()
	get_tree().call_deferred("reload_current_scene")
