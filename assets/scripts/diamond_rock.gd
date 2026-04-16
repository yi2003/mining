extends "res://assets/scripts/rock.gd"

const DIAMOND_SCENE = preload("res://scenes/diamond.tscn")

func _ready():
	rock_type = "diamond_rock"
	# Set sprite region to always show diamond gem rock (x=0, y=16)
	if sprite:
		sprite.region_rect = Rect2(0, 16, 16, 16)


func take_damage():
	if health <= 0 or is_dying:
		return
	health -= 1
	_play_flash_effect()
	if health <= 0:
		is_dying = true
		print("DIAMOND ROCK: emitting rock_destroyed with type=", rock_type, " self=", self)
		emit_signal("rock_destroyed", global_position, rock_type, self)
		if skip_gem_spawn:
			await get_tree().create_timer(0.15).timeout
			queue_free()
			return
		spawn_diamond()
		await get_tree().create_timer(0.15).timeout
		queue_free()

func spawn_diamond():
	var diamond = DIAMOND_SCENE.instantiate()
	diamond.name = "DiamondGem"  # Ensure cleanup finds it
	var spawn_pos = global_position
	diamond.position = spawn_pos
	diamond.modulate.a = 0
	# Add to the same parent as this gem rock (YSort)
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
