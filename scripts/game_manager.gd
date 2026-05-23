extends Node
## Central game-state singleton (registered as autoload "GameManager").
## All gameplay systems read/write through here and listen to its signals.

# ---------- signals ----------
signal score_changed(new_score: int)
signal health_changed(current_hp: int, max_hp: int)
signal xp_changed(current_xp: int, max_xp: int)
signal level_changed(new_level: int)
signal player_died
signal pickup_collected(type: String)

# ---------- state ----------
var score: int = 0
var player_level: int = 1
var player_xp: int = 0
var xp_to_next_level: int = 100
var enemy_kills: int = 0

var inventory: Dictionary = {
	"energy_cell": 0,
	"credits": 0,
	"upgrade_material": 0,
}


# ---------- public API ----------

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func on_enemy_killed(xp_reward: int, score_reward: int) -> void:
	enemy_kills += 1
	add_score(score_reward)
	_gain_xp(xp_reward)


## Called by pickup.gd when the player touches a pickup.
## heal_target should be the player node (or null).
func on_pickup_collected(type: String, heal_target: Node) -> void:
	if inventory.has(type):
		inventory[type] += 1
	pickup_collected.emit(type)
	match type:
		"energy_cell":
			add_score(50)
			if is_instance_valid(heal_target) and heal_target.has_method("heal"):
				heal_target.heal(30)
		"credits":
			add_score(25)
		"upgrade_material":
			add_score(100)


## Reset all persistent state (called before scene reload on restart).
func reset() -> void:
	score = 0
	player_level = 1
	player_xp = 0
	xp_to_next_level = 100
	enemy_kills = 0
	inventory = {"energy_cell": 0, "credits": 0, "upgrade_material": 0}


# ---------- private ----------

func _gain_xp(amount: int) -> void:
	player_xp += amount
	if player_xp >= xp_to_next_level:
		player_xp -= xp_to_next_level
		player_level += 1
		xp_to_next_level = int(xp_to_next_level * 1.5)
		level_changed.emit(player_level)
	xp_changed.emit(player_xp, xp_to_next_level)
