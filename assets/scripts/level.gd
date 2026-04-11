extends Node2D

@onready var rock_scene = preload("res://scenes/rock.tscn")
var ore_scenes = {
	"coal": preload("res://scenes/coal.tscn"),
	"gold": preload("res://scenes/gold.tscn"),
	"iron": preload("res://scenes/iron.tscn"),
	"solar": preload("res://scenes/solar.tscn"),
	"tin": preload("res://scenes/tin.tscn")
}

var ore_names = ["coal", "gold", "iron", "solar", "tin"]

func _ready():
	# Connect rock destroyed signals for all rocks in the level
	for child in get_children():
		if child.name == "Rock":
			child.rock_destroyed.connect(_on_Rock_rock_destroyed)

func _on_Rock_rock_destroyed(spawn_pos: Vector2):
	print("Rock destroyed at: ", spawn_pos, " - spawning random ore")
	spawn_random_ore(spawn_pos)

func spawn_random_ore(spawn_pos: Vector2):
	var ore_name = ore_names[randi() % ore_names.size()]
	print("Spawning: ", ore_name)
	var ore = ore_scenes[ore_name].instantiate()
	ore.position = spawn_pos
	ore.modulate.a = 0
	add_child(ore)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	# Start position above (drop from top)
	ore.position.y -= 50
	tween.tween_property(ore, "position", spawn_pos, 0.4)
	tween.parallel().tween_property(ore, "modulate:a", 1.0, 0.3)
