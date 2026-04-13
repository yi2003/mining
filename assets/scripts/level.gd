extends Node2D

@onready var rock_scene = preload("res://scenes/rock.tscn")
@onready var amethyst_rock_scene = preload("res://scenes/amethyst_rock.tscn")
@onready var diamond_rock_scene = preload("res://scenes/diamond_rock.tscn")
@onready var map = $Map/TileMapLayer
@onready var score_label = $UILayer/ScoreLabel
var ore_scenes = {
	"coal": preload("res://scenes/coal.tscn"),
	"gold": preload("res://scenes/gold.tscn"),
	"iron": preload("res://scenes/iron.tscn"),
	"solar": preload("res://scenes/solar.tscn"),
	"tin": preload("res://scenes/tin.tscn"),
	"diamond": preload("res://scenes/diamond.tscn"),
	"amethyst": preload("res://scenes/amethyst.tscn")
}

var ore_names = ["gold", "iron", "tin", "diamond", "amethyst"]
var rocks_spawned = 0
var ore_drop_chance: float = 0.7  # 70% chance to spawn ore
var gem_chance: float = 0.5  # 50% chance to spawn gem rock, 50% for regular rock

# Ladder spawning
var ladder_scene = preload("res://scenes/ladder.tscn")
var ladder_spawned: bool = false
var last_rock_pos: Vector2 = Vector2.ZERO
var ladder_spawn_chance: float = 0.3  # 30% chance to spawn ladder

# Floor system
var current_floor: int = 0
var floor_height: int = 180  # viewport height
var world_offset_y: int = 0
var max_floor: int = 3
var is_transitioning: bool = false

@onready var fade_rect = $FadeRect
@onready var world_container = $YSort
@onready var player = $YSort/Player

func _ready():
	_clear_all_rocks()
	_spawn_rocks(5)
	_set_player_start_position()
	# Reorder player to be last in YSort so player renders in front when Y is equal
	var player_ref = $YSort/Player
	$YSort.remove_child(player_ref)
	$YSort.add_child(player_ref)

	# Initialize world container position for floor offset
	world_container.position.y = world_offset_y

func _set_player_start_position():
	var player_start = $Map/PlayerStart
	if player_start:
		player.position = player_start.position
		print("Player start position set to: ", player_start.position)
	else:
		print("Warning: PlayerStart node not found")

func _clear_all_rocks():
	var rocks_to_remove = []
	for child in $YSort.get_children():
		if child.name.begins_with("Rock"):
			rocks_to_remove.append(child)
	for rock in rocks_to_remove:
		rock.queue_free()
	rocks_spawned = 0

func _spawn_rocks(count: int):
	var used_cells = map.get_used_cells()
	var shuffled_cells = Array(used_cells)
	shuffled_cells.shuffle()

	# Filter cells: only place rocks where there's no prop tile (source != 1)
	# and CANWORK custom data is true
	var valid_cells = []
	for cell in shuffled_cells:
		var source_id = map.get_cell_source_id(cell)
		# Source 1 is props (no physics), skip those cells
		if source_id != 1:
			# Check CANWORK custom data
			var tile_data = map.get_cell_tile_data(cell)
			if tile_data != null and tile_data.get_custom_data("CANWORK") == true:
				valid_cells.append(cell)

	var placed = 0
	for cell in valid_cells:
		if placed >= count:
			break
		var cell_center = map.map_to_local(cell)
		var rock_scene_to_use
		if randf() < gem_chance:
			# Choose between amethyst and diamond rock
			rock_scene_to_use = amethyst_rock_scene if randf() < 0.5 else diamond_rock_scene
		else:
			rock_scene_to_use = rock_scene
		var rock = rock_scene_to_use.instantiate()
		rock.position = cell_center
		rock.name = "Rock_" + str(placed)
		$YSort.add_child(rock)
		rock.rock_destroyed.connect(_on_Rock_rock_destroyed)
		rocks_spawned += 1
		placed += 1
	print("Spawned ", rocks_spawned, " rocks")

func _on_Rock_rock_destroyed(spawn_pos: Vector2, type: String = "stone", rock: Node = null):
	print("Rock destroyed at: ", spawn_pos, " type: ", type)
	last_rock_pos = spawn_pos

	# Check if this was the last rock and ladder hasn't spawned
	rocks_spawned -= 1
	if rocks_spawned <= 0 and not ladder_spawned:
		# Force spawn ladder at last rock position
		_spawn_ladder(last_rock_pos)
		if rock:
			rock.skip_gem_spawn = true
		return

	# Random ladder spawn chance
	if not ladder_spawned and randf() <= ladder_spawn_chance:
		_spawn_ladder(spawn_pos)
		if rock:
			rock.skip_gem_spawn = true
		return

	# Only spawn ore if ladder didn't spawn
	if type == "stone":
		if randf() <= ore_drop_chance:
			spawn_random_ore(spawn_pos)
		else:
			print("No ore dropped")
	# For gem types, gem rocks handle their own gem spawning
	elif type == "gem" or type == "amethyst_rock" or type == "diamond_rock":
		print("Gem rock destroyed, spawning handled by gem rock script")

func _spawn_ladder(spawn_pos: Vector2):
	print("Spawning ladder at: ", spawn_pos)
	var ladder = ladder_scene.instantiate()
	ladder.position = spawn_pos
	ladder_spawned = true
	$YSort.add_child(ladder)
	ladder.player_entered_ladder.connect(_on_ladder_entered)
	ladder.player_exited_ladder.connect(_on_ladder_exited)
	# Keep player on top of YSort
	$YSort.remove_child(player)
	$YSort.add_child(player)

func spawn_random_ore(spawn_pos: Vector2):
	var ore_name = ore_names[randi() % ore_names.size()]
	print("Spawning: ", ore_name)
	var ore = ore_scenes[ore_name].instantiate()
	ore.position = spawn_pos
	ore.modulate.a = 0
	$YSort.add_child(ore)
	ore.collected.connect(_on_Ore_collected)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	# Start position above (drop from top)
	ore.position.y -= 50
	tween.tween_property(ore, "position", spawn_pos, 0.4)
	tween.parallel().tween_property(ore, "modulate:a", 1.0, 0.3)
	# Keep player on top of YSort
	$YSort.remove_child(player)
	$YSort.add_child(player)

func _on_Ore_collected(points: int):
	GameState.add_score(points)
	_update_score_label()

func _update_score_label():
	score_label.text = "Score: " + str(GameState.score)

func change_floor(direction: int):
	if is_transitioning:
		return
	var new_floor = current_floor + direction
	if new_floor < 0 or new_floor > max_floor:
		return

	is_transitioning = true

	# Fade out
	fade_rect.visible = true
	fade_rect.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.15)

	await tween.finished

	# Update floor
	current_floor = new_floor
	world_offset_y = -current_floor * floor_height

	# Apply offset to world container (player stays at same screen pos)
	world_container.position.y = world_offset_y

	# Wait a moment
	await get_tree().create_timer(0.05).timeout

	# Fade in
	tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.15)
	await tween.finished
	fade_rect.visible = false

	is_transitioning = false
	player.is_transitioning = false
	print("Changed to floor ", current_floor)

func _on_ladder_entered(ladder):
	player.enter_climbing(ladder)
	print("Player entered ladder on floor ", ladder.floor_number)

func _on_ladder_exited():
	player._exit_climbing()

func _physics_process(_delta):
	if player.is_climbing and not is_transitioning:
		var vertical = Input.get_axis("ui_up", "ui_down")
		if vertical != 0:
			change_floor(-vertical)
			is_transitioning = true  # Prevent multiple triggers
