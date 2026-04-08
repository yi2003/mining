extends CharacterBody2D

const SPEED = 100.0

@onready var animated_sprite = $AnimatedSprite2D

var facing_direction = "down"  # Track facing: "up", "down", "left", "right"
var is_axe_swinging = false

func _ready():
	# Start with idle animation
	animated_sprite.play("idle_down")
	# Enable input processing for CharacterBody2D
	set_process_input(true)

func _unhandled_input(event):
	# Handle axe swing on Space/attack press
	if event.is_action_pressed("attack") and not is_axe_swinging:
		print("Attack pressed! Facing: ", facing_direction)
		is_axe_swinging = true
		_play_axe_animation()

func _play_axe_animation():
	print("Playing axe animation for: ", facing_direction)
	match facing_direction:
		"up":
			animated_sprite.play("axe_up")
		"down":
			animated_sprite.play("axe_down")
		"left", "right":
			animated_sprite.play("axe_right")

	# Wait for animation to finish before allowing another swing
	await animated_sprite.animation_finished
	print("Axe animation finished")
	is_axe_swinging = false

func _physics_process(_delta):
	# Check for axe swing via input as fallback
	if Input.is_action_just_pressed("attack") and not is_axe_swinging:
		is_axe_swinging = true
		_play_axe_animation()

	# Get input direction
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	# Set velocity
	velocity = direction * SPEED

	# Move and slide
	move_and_slide()

	# Update facing direction and handle animations (skip if axe swinging)
	if not is_axe_swinging:
		if direction.length() > 0:
			if abs(direction.x) > abs(direction.y):
				# Horizontal movement dominant
				if direction.x > 0:
					facing_direction = "right"
					animated_sprite.play("run_right")
					animated_sprite.flip_h = false
				else:
					facing_direction = "left"
					animated_sprite.play("run_right")
					animated_sprite.flip_h = true
			else:
				# Vertical movement dominant
				if direction.y > 0:
					facing_direction = "down"
					animated_sprite.play("run_down")
				else:
					facing_direction = "up"
					animated_sprite.play("run_up")
		else:
			# Idle - match the last facing direction
			match facing_direction:
				"left":
					animated_sprite.play("idle_down")
					animated_sprite.flip_h = true
				"right":
					animated_sprite.play("idle_down")
					animated_sprite.flip_h = false
				"up":
					animated_sprite.play("idle_up")
				"down":
					animated_sprite.play("idle_down")
