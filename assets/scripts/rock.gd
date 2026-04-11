extends CharacterBody2D

var health = 3
var max_health = 3

signal rock_destroyed

func take_damage():
	health -= 1
	print("Rock hit! Health: ", health)
	if health <= 0:
		print("Rock destroyed!")
		emit_signal("rock_destroyed")
		queue_free()
