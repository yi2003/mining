extends "res://assets/scripts/rock.gd"

const DIAMOND_SCENE = preload("res://scenes/diamond.tscn")

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	rock_type = "diamond_rock"
	# Set sprite region to always show diamond gem rock (x=0, y=16)
	if sprite:
		sprite.region_rect = Rect2(0, 16, 16, 16)


func take_damage():
	health -= 1
	if health <= 0:
		emit_signal("rock_destroyed", global_position, rock_type)
		spawn_diamond()
		queue_free()

func spawn_diamond():
	var diamond = DIAMOND_SCENE.instantiate()
	diamond.position = global_position
	# Add to the same parent as this gem rock (YSort)
	get_parent().add_child(diamond)
	# Connect diamond collected signal to level's handler
	var level = get_parent().get_parent()
	if level.has_method("_on_Ore_collected"):
		diamond.collected.connect(level._on_Ore_collected)
