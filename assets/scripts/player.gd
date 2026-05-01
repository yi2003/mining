extends CharacterBody2D

const SPEED = 100.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var hitbox_shape = $Hitbox/CollisionShape2D

var facing_direction = "down"
var is_axe_swinging = false
var is_climbing: bool = false
var current_ladder: Node = null
var is_transitioning: bool = false
var can_move: bool = true
var is_dying: bool = false

signal death_animation_finished

# Original hitbox position for reference
var original_hitbox_pos = Vector2(5, -1)
var original_shape_pos = Vector2(4.5, 5)

func _ready():
	animated_sprite.play("idle_down")
	set_process_input(true)

func _unhandled_input(event):
	if event.is_action_pressed("attack") and not is_axe_swinging and can_move:
		is_axe_swinging = true
		_play_axe_animation()

func _play_axe_animation():
	# Always reset flip_h first, then set direction-specific values
	animated_sprite.flip_h = false
	match facing_direction:
		"up":
			animated_sprite.play("axe_up")
			# Hitbox above player for up attack
			hitbox.position = Vector2(0, -6)
			hitbox_shape.position = Vector2(0, -5)
			hitbox.scale.x = 1
		"down":
			animated_sprite.play("axe_down")
			# Hitbox below player for down attack
			hitbox.position = Vector2(0, 6)
			hitbox_shape.position = Vector2(0, 5)
			hitbox.scale.x = 1
		"left":
			animated_sprite.play("axe_right")
			animated_sprite.flip_h = true
			# Hitbox to the left, mirror the right attack via scale.x = -1
			hitbox.position = Vector2(-5, -1)
			hitbox_shape.position = Vector2(4.5, 5)
			hitbox.scale.x = -1
		"right":
			animated_sprite.play("axe_right")
			# flip_h already false from reset above
			# Hitbox to the right for right attack
			hitbox.position = Vector2(5, -1)
			hitbox_shape.position = Vector2(4.5, 5)
			hitbox.scale.x = 1

	# Check for overlapping bodies and deal damage
	# Wait one physics frame for hitbox position to update
	await get_tree().physics_frame
	await get_tree().physics_frame
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(GameState.get_pickaxe_damage())

	# Wait for animation to finish before allowing another swing
	await animated_sprite.animation_finished
	# Reset hitbox
	hitbox.position = original_hitbox_pos
	hitbox_shape.position = original_shape_pos
	hitbox.scale.x = 1
	is_axe_swinging = false

func _physics_process(_delta):
	# Check for axe swing via input as fallback
	if Input.is_action_just_pressed("attack") and not is_axe_swinging and can_move:
		is_axe_swinging = true
		_play_axe_animation()

	# Climbing mode - handle separately
	if is_climbing:
		_handle_climbing_input()
		return

	# Block all input when can_move is false
	if not can_move:
		velocity = Vector2.ZERO
		return

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

func _handle_climbing_input():
	var horizontal = Input.get_axis("ui_left", "ui_right")

	# Exit climbing on horizontal input or when movement is locked
	if abs(horizontal) > 0 or not can_move:
		_exit_climbing()

func enter_climbing(ladder):
	if not can_move:
		return
	is_climbing = true
	current_ladder = ladder
	velocity = Vector2.ZERO

func _exit_climbing():
	is_climbing = false
	current_ladder = null

func play_death():
	is_dying = true
	can_move = false
	velocity = Vector2.ZERO
	animated_sprite.play("die")
	await animated_sprite.animation_finished
	death_animation_finished.emit()
