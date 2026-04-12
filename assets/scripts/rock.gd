extends CharacterBody2D

var health = 3
var max_health = 3
@export var rock_type = "stone"

signal rock_destroyed(position: Vector2, type: String)

func take_damage():
	health -= 1
	if health <= 0:
		emit_signal("rock_destroyed", global_position, rock_type)
		queue_free()
