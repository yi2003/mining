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
var gem_chance: float = 1.0  # 100% chance to spawn gem instead of rock (testing)

func _ready():
	_clear_all_rocks()
	_spawn_rocks(5)
	_set_player_start_position()
	# Reorder player to be last in YSort so player renders in front when Y is equal
	var player = $YSort/Player
	$YSort.remove_child(player)
	$YSort.add_child(player)

func _set_player_start_position():
	var player_start = $Map/PlayerStart
	if player_start:
		var player = $YSort/Player
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

func _on_Rock_rock_destroyed(spawn_pos: Vector2, type: String = "stone"):
	print("Rock destroyed at: ", spawn_pos, " type: ", type)
	if type == "stone":
		if randf() <= ore_drop_chance:
			spawn_random_ore(spawn_pos)
		else:
			print("No ore dropped")
	# For gem types, gem rocks handle their own gem spawning
	elif type == "gem" or type == "amethyst_rock" or type == "diamond_rock":
		print("Gem rock destroyed, spawning handled by gem rock script")

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
	var player = $YSort/Player
	$YSort.remove_child(player)
	$YSort.add_child(player)

func _on_Ore_collected(points: int):
	GameState.add_score(points)
	_update_score_label()

func _update_score_label():
	score_label.text = "Score: " + str(GameState.score)
