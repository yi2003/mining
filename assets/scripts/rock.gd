extends CharacterBody2D

var health = 3
var max_health = 3
@export var rock_type = "stone"
var is_dying: bool = false
var skip_gem_spawn: bool = false

signal rock_destroyed(position: Vector2, type: String, rock: Node)

@onready var sprite = $Sprite2D

func take_damage():
	if health <= 0 or is_dying:
		return
	health -= 1
	_play_flash_effect()
	if health <= 0:
		is_dying = true
		emit_signal("rock_destroyed", global_position, rock_type, self)
		await get_tree().create_timer(0.15).timeout
		queue_free()

func _play_flash_effect():
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(2, 2, 2), 0.08)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.12)
		tween.play()
