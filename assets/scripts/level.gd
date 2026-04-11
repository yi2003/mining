extends Node2D

@onready var rock_scene = preload("res://scenes/rock.tscn")
@onready var map = $Map/TileMapLayer
@onready var score_label = $UILayer/ScoreLabel
var ore_scenes = {
	"coal": preload("res://scenes/coal.tscn"),
	"gold": preload("res://scenes/gold.tscn"),
	"iron": preload("res://scenes/iron.tscn"),
	"solar": preload("res://scenes/solar.tscn"),
	"tin": preload("res://scenes/tin.tscn")
}

var ore_names = ["gold", "iron", "tin"]
var rocks_spawned = 0
var ore_drop_chance: float = 0.7  # 70% chance to spawn ore

func _ready():
	clear_all_rocks()
	spawn_rocks(5)
	# Set player start position based on IS_START tile
	var player = $YSort/Player
	var start_pos = _find_start_position()
	if start_pos != Vector2.ZERO:
		player.position = start_pos
	# Reorder player to be last in YSort so player renders in front when Y is equal
	$YSort.remove_child(player)
	$YSort.add_child(player)

func _find_start_position() -> Vector2:
	var cells = map.get_used_cells()
	for cell in cells:
		var tile_data = map.get_cell_tile_data(cell)
		if tile_data != null and tile_data.get_custom_data("IS_START") == true:
			return map.map_to_local(cell)
	return Vector2.ZERO

func clear_all_rocks():
	var rocks_to_remove = []
	for child in $YSort.get_children():
		if child.name.begins_with("Rock"):
			rocks_to_remove.append(child)
	for rock in rocks_to_remove:
		rock.queue_free()
	rocks_spawned = 0

func spawn_rocks(count: int):
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
		var rock = rock_scene.instantiate()
		rock.position = cell_center
		rock.name = "Rock_" + str(placed)
		$YSort.add_child(rock)
		rock.rock_destroyed.connect(_on_Rock_rock_destroyed)
		rocks_spawned += 1
		placed += 1
	print("Spawned ", rocks_spawned, " rocks")

func _on_Rock_rock_destroyed(spawn_pos: Vector2):
	print("Rock destroyed at: ", spawn_pos)
	if randf() <= ore_drop_chance:
		spawn_random_ore(spawn_pos)
	else:
		print("No ore dropped")

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
