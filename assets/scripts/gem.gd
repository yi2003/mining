extends "res://assets/scripts/rock.gd"

@export var diamond_chance = 0.5  # 50% chance to become diamond (testing)

const DIAMOND_SCENE = preload("res://scenes/diamond.tscn")
const AMETHYST_SCENE = preload("res://scenes/amethyst.tscn")

@onready var sprite: Sprite2D = $Sprite2D

var will_drop_diamond = false  # Determined at creation

func _ready():
	rock_type = "gem"
	# Determine what this gem will drop when destroyed
	will_drop_diamond = randf() < diamond_chance
	# Initialize sprite region based on initial health and drop type
	_update_sprite_region()

func _update_sprite_region():
	# Update sprite region based on current health
	# health: 3 = full (x=0, y=16), damaged = x=32, y=16
	# All gem rocks use y=16 (row 1)
	# Texture is 48x32 (3 frames wide, 2 rows high)
	if sprite and health > 0:
		# Healthy: x=0, Damaged: x=32
		var x_offset = 0 if health == 3 else 32
		var y_offset = 16  # Always use row 1 for gem rocks
		sprite.region_rect = Rect2(x_offset, y_offset, 16, 16)

func take_damage():
	health -= 1
	if health > 0:
		_update_sprite_region()
	else:
		emit_signal("rock_destroyed", global_position, rock_type)
		if will_drop_diamond:
			spawn_diamond()
		else:
			spawn_amethyst()
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

func spawn_amethyst():
	var amethyst = AMETHYST_SCENE.instantiate()
	amethyst.position = global_position
	# Add to the same parent as this gem (YSort)
	get_parent().add_child(amethyst)
	# Connect amethyst collected signal to level's handler
	var level = get_parent().get_parent()
	if level.has_method("_on_Ore_collected"):
		amethyst.collected.connect(level._on_Ore_collected)
