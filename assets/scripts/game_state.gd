extends Node

var max_oxygen: float = 100.0

var score: int = 0
var total_earnings: int = 0
var oxygen: float = max_oxygen

var pickaxe_level: int = 0
var oxygen_tank_level: int = 0
var inventory_level: int = 0

func add_score(points: int) -> void:
	score += points

func add_earnings(value: int) -> void:
	total_earnings += value

func reset_score() -> void:
	score = 0
	reset_upgrades()

func reset_oxygen() -> void:
	oxygen = max_oxygen

func get_pickaxe_damage() -> int:
	return 1 + pickaxe_level

func apply_upgrade_effects() -> void:
	max_oxygen = 100.0 + (oxygen_tank_level * 25.0)
	PlayerInventory.resize_slots(4 + inventory_level)

func reset_upgrades() -> void:
	pickaxe_level = 0
	oxygen_tank_level = 0
	inventory_level = 0
	max_oxygen = 100.0
