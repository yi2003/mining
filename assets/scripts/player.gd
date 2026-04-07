extends CharacterBody2D

const SPEED = 100.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Start with idle animation
	animated_sprite.play("idle_down")

func _physics_process(_delta):
	# Get input direction
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	# Set velocity
	velocity = direction * SPEED

	# Move and slide
	move_and_slide()

	# Handle animations
	if direction.length() > 0:
		if abs(direction.x) > abs(direction.y):
			# Horizontal movement dominant
			if direction.x > 0:
				animated_sprite.play("run_right")
				animated_sprite.flip_h = false
			else:
				animated_sprite.play("run_right")
				animated_sprite.flip_h = true
		else:
			# Vertical movement dominant
			if direction.y > 0:
				animated_sprite.play("run_down")
			else:
				animated_sprite.play("run_up")
	else:
		# Idle - match the last facing direction
		if animated_sprite.flip_h:
			animated_sprite.play("idle_up")
		else:
			animated_sprite.play("idle_down")
