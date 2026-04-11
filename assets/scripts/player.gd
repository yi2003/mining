extends CharacterBody2D

const SPEED = 100.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var hitbox_shape = $Hitbox/CollisionShape2D

var facing_direction = "down"  # Track facing: "up", "down", "left", "right"
var is_axe_swinging = false

# Original hitbox position for reference
var original_hitbox_pos = Vector2(5, -1)
var original_shape_pos = Vector2(4.5, 5)

func _ready():
	animated_sprite.play("idle_down")
	set_process_input(true)

func _unhandled_input(event):
	if event.is_action_pressed("attack") and not is_axe_swinging:
		is_axe_swinging = true
		_play_axe_animation()

func _play_axe_animation():
	# Check for overlapping bodies and deal damage
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage()
	match facing_direction:
		"up":
			animated_sprite.play("axe_up")
			# Hitbox above player for up attack
			hitbox.position = Vector2(0, -12)
			hitbox_shape.position = Vector2(0.5, -5)
			hitbox.scale.x = 1
		"down":
			animated_sprite.play("axe_down")
			# Hitbox below player for down attack
			hitbox.position = Vector2(0, 10)
			hitbox_shape.position = Vector2(0.5, 0)
			hitbox.scale.x = 1
		"left":
			animated_sprite.play("axe_right")
			animated_sprite.flip_h = true
			# Hitbox to the left for left attack (no flip, just position left)
			hitbox.position = Vector2(-7, -1)
			hitbox_shape.position = Vector2(-1.5, 5)
			hitbox.scale.x = 1
		"right":
			animated_sprite.play("axe_right")
			animated_sprite.flip_h = false
			# Hitbox to the right for right attack
			hitbox.position = Vector2(5, -1)
			hitbox_shape.position = Vector2(4.5, 5)
			hitbox.scale.x = 1

	# Wait for animation to finish before allowing another swing
	await animated_sprite.animation_finished
	# Reset hitbox
	hitbox.position = original_hitbox_pos
	hitbox_shape.position = original_shape_pos
	hitbox.scale.x = 1
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
