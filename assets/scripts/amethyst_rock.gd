extends "res://assets/scripts/rock.gd"

const AMETHYST_SCENE = preload("res://scenes/amethyst.tscn")

func _ready():
	rock_type = "amethyst_rock"
	# Set sprite region to always show amethyst gem rock (x=0, y=16)
	if sprite:
		sprite.region_rect = Rect2(0, 16, 16, 16)


func take_damage():
	if health <= 0 or is_dying:
		return
	health -= 1
	_play_flash_effect()
	if health <= 0:
		is_dying = true
		emit_signal("rock_destroyed", global_position, rock_type, self)
		if skip_gem_spawn:
			await get_tree().create_timer(0.15).timeout
			queue_free()
			return
		spawn_amethyst()
		await get_tree().create_timer(0.15).timeout
		queue_free()

func spawn_amethyst():
	var amethyst = AMETHYST_SCENE.instantiate()
	var spawn_pos = global_position
	amethyst.position = spawn_pos
	amethyst.modulate.a = 0
	# Add to the same parent as this gem rock (YSort)
	get_parent().add_child(amethyst)
	# Connect amethyst collected signal to level's handler
	var level = get_parent().get_parent()
	if level.has_method("_on_Ore_collected"):
		amethyst.collected.connect(level._on_Ore_collected)
	# Drop animation: start 50px above and fade in, matching spawn_random_ore behavior
	amethyst.position.y -= 50
	var tween = amethyst.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(amethyst, "position", spawn_pos, 0.4)
	tween.parallel().tween_property(amethyst, "modulate:a", 1.0, 0.3)
