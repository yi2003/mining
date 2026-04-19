extends CanvasLayer

@onready var table_container = $Panel/VBox/TableContainer
@onready var total_label = $Panel/VBox/TotalLabel

const ORE_TEXTURES = {
	PlayerInventory.OreType.IRON: preload("res://assets/images/ores/iron.png"),
	PlayerInventory.OreType.GOLD: preload("res://assets/images/ores/gold.png"),
	PlayerInventory.OreType.COAL: preload("res://assets/images/ores/stone.png"),
	PlayerInventory.OreType.SOLAR: preload("res://assets/images/ores/silver.png"),
	PlayerInventory.OreType.DIAMOND: preload("res://assets/images/gems/diamond.png"),
	PlayerInventory.OreType.AMETHYST: preload("res://assets/images/gems/amethyst.png"),
	PlayerInventory.OreType.TIN: preload("res://assets/images/ores/tin.png")
}

const ORE_REGIONS = {
	PlayerInventory.OreType.IRON: Rect2(32, 16, 16, 16),
	PlayerInventory.OreType.GOLD: Rect2(32, 0, 16, 16),
	PlayerInventory.OreType.COAL: Rect2(16, 48, 16, 16),
	PlayerInventory.OreType.SOLAR: Rect2(32, 0, 16, 16),
	PlayerInventory.OreType.DIAMOND: Rect2(32, 16, 16, 16),
	PlayerInventory.OreType.AMETHYST: Rect2(32, 16, 16, 16),
	PlayerInventory.OreType.TIN: Rect2(32, 0, 16, 16)
}

func _ready():
	visible = false

func show_summary():
	visible = true
	get_tree().paused = true

	# Clear old rows
	for child in table_container.get_children():
		child.queue_free()
	table_container.visible = true
	_create_header_row()

	var summary = PlayerInventory.get_ore_summary()
	var grand_total = 0

	for ore_type in summary:
		var qty = summary[ore_type]
		var value = PlayerInventory.get_ore_value(ore_type)
		var total = qty * value
		grand_total += total
		_create_ore_row(ore_type, qty, value, total)

	total_label.text = "Grand Total: " + str(grand_total)

func _create_header_row():
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 14)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(18, 0)
	row.add_child(spacer)

	var label_qty = _label_pad_left("Qty", 8)
	row.add_child(label_qty)

	var label_val = _label_pad_left("Value", 10)
	row.add_child(label_val)

	var label_total = _label_pad_left("Total", 10)
	row.add_child(label_total)

	table_container.add_child(row)

func _create_ore_row(ore_type, qty: int, value: int, total: int):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 14)

	# Texture icon
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(12, 12)
	icon.stretch_mode = TextureRect.STRETCH_KEEP
	var base_texture = ORE_TEXTURES.get(ore_type)
	var region = ORE_REGIONS.get(ore_type, Rect2(0, 0, 16, 16))
	if base_texture:
		var atlas = AtlasTexture.new()
		atlas.atlas = base_texture
		atlas.region = region
		icon.texture = atlas
	row.add_child(icon)

	# Qty
	var label_qty = _label_pad_left(str(qty), 8)
	row.add_child(label_qty)

	# Value
	var label_val = _label_pad_left(str(value), 10)
	row.add_child(label_val)

	# Total
	var label_total = _label_pad_left(str(total), 10)
	row.add_child(label_total)

	table_container.add_child(row)

func _label(text: String) -> Label:
	var l = Label.new()
	l.text = text
	l.custom_minimum_size = Vector2(0, 14)
	return l

func _label_pad_left(text: String, width: int) -> Label:
	var l = Label.new()
	l.custom_minimum_size = Vector2(0, 14)
	var result = text
	while result.length() < width - text.length():
		result = " " + result
	l.text = result
	return l

func _on_exit_pressed():
	get_tree().quit()

func _on_restart_pressed():
	get_tree().paused = false
	GameState.reset_score()
	get_tree().reload_current_scene()
