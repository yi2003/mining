extends "res://assets/scripts/rock.gd"

@export var diamond_chance = 0.5  # 50% chance to become diamond (testing)

const DIAMOND_SCENE = preload("res://scenes/diamond.tscn")
const AMETHYST_SCENE = preload("res://scenes/amethyst.tscn")

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
	if health <= 0:
		return
	health -= 1
	_play_flash_effect()
	if health > 0:
		_update_sprite_region()
	else:
		emit_signal("rock_destroyed", global_position, rock_type)
		if will_drop_diamond:
			spawn_diamond()
		else:
			spawn_amethyst()
		await get_tree().create_timer(0.15).timeout
		queue_free()

func spawn_diamond():
	var diamond = DIAMOND_SCENE.instantiate()
	diamond.name = "DiamondGem"  # Ensure cleanup finds it
	var spawn_pos = global_position
	diamond.position = spawn_pos
	diamond.modulate.a = 0
	# Add to the same parent as this gem (YSort)
	get_parent().add_child(diamond)
	# Connect diamond collected signal to level's handler
	var level = get_parent().get_parent()
	if level.has_method("_on_Ore_collected"):
		diamond.collected.connect(level._on_Ore_collected)
	# Drop animation
	diamond.position.y -= 50
	var tween = diamond.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(diamond, "position", spawn_pos, 0.4)
	tween.parallel().tween_property(diamond, "modulate:a", 1.0, 0.3)

func spawn_amethyst():
	var amethyst = AMETHYST_SCENE.instantiate()
	amethyst.name = "AmethystGem"  # Ensure cleanup finds it
	var spawn_pos = global_position
	amethyst.position = spawn_pos
	amethyst.modulate.a = 0
	# Add to the same parent as this gem (YSort)
	get_parent().add_child(amethyst)
	# Connect amethyst collected signal to level's handler
	var level = get_parent().get_parent()
	if level.has_method("_on_Ore_collected"):
		amethyst.collected.connect(level._on_Ore_collected)
	# Drop animation
	amethyst.position.y -= 50
	var tween = amethyst.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(amethyst, "position", spawn_pos, 0.4)
	tween.parallel().tween_property(amethyst, "modulate:a", 1.0, 0.3)
