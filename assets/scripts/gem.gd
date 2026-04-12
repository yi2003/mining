extends "res://assets/scripts/rock.gd"

@export var diamond_chance = 0.3  # 30% chance to become diamond

const DIAMOND_SCENE = preload("res://scenes/diamond.tscn")

func _ready():
	rock_type = "gem"

func take_damage():
	health -= 1
	if health <= 0:
		emit_signal("rock_destroyed", global_position, rock_type)
		if randf() < diamond_chance:
			spawn_diamond()
		queue_free()

func spawn_diamond():
	var diamond = DIAMOND_SCENE.instantiate()
	diamond.position = global_position
	# Add to the same parent as this gem (YSort)
	get_parent().add_child(diamond)
	# Connect diamond collected signal to level's handler
	var level = get_parent().get_parent()
	if level.has_method("_on_Ore_collected"):
		diamond.collected.connect(level._on_Ore_collected)