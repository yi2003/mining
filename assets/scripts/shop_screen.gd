extends CanvasLayer

signal shop_closed

var gold_label: Label
var upgrade_rows: Array = []

const UPGRADES = [
	{
		"name": "Pickaxe",
		"max_level": 3,
		"cost": 200,
		"key": "pickaxe_level",
	},
	{
		"name": "Oxygen Tank",
		"max_level": 3,
		"cost": 250,
		"key": "oxygen_tank_level",
	},
	{
		"name": "Inventory",
		"max_level": 2,
		"cost": 500,
		"key": "inventory_level",
	},
]

func _ready():
	visible = false
	_build_ui()

func _build_ui():
	# Dark overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# Panel
	var panel = Panel.new()
	panel.offset_left = 20
	panel.offset_top = 8
	panel.offset_right = 300
	panel.offset_bottom = 172
	add_child(panel)

	# VBox inside panel
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 4
	vbox.offset_top = 4
	vbox.offset_right = -4
	vbox.offset_bottom = -4
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "SHOP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	vbox.add_child(title)

	# Gold label
	gold_label = Label.new()
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_label.add_theme_font_size_override("font_size", 9)
	vbox.add_child(gold_label)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(spacer)

	# Upgrade rows
	for upgrade in UPGRADES:
		var row = _create_upgrade_row(upgrade)
		vbox.add_child(row.container)

	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(spacer2)

	# Close button
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.add_theme_font_size_override("font_size", 11)
	close_btn.custom_minimum_size = Vector2(60, 16)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(close_btn)
	close_btn.pressed.connect(_on_close_pressed)

func _create_upgrade_row(upgrade: Dictionary) -> Dictionary:
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 14)
	container.add_theme_constant_override("separation", 4)

	# Name label
	var name_label = Label.new()
	name_label.text = upgrade.name
	name_label.custom_minimum_size = Vector2(70, 0)
	name_label.add_theme_font_size_override("font_size", 9)
	container.add_child(name_label)

	# Level label
	var level_label = Label.new()
	level_label.custom_minimum_size = Vector2(30, 0)
	level_label.add_theme_font_size_override("font_size", 9)
	container.add_child(level_label)

	# Cost label
	var cost_label = Label.new()
	cost_label.custom_minimum_size = Vector2(30, 0)
	cost_label.add_theme_font_size_override("font_size", 9)
	container.add_child(cost_label)

	# Buy button
	var buy_btn = Button.new()
	buy_btn.text = "Buy"
	buy_btn.add_theme_font_size_override("font_size", 9)
	buy_btn.custom_minimum_size = Vector2(35, 14)
	container.add_child(buy_btn)

	var row_data = {
		"container": container,
		"level_label": level_label,
		"cost_label": cost_label,
		"buy_btn": buy_btn,
		"upgrade": upgrade,
	}
	upgrade_rows.append(row_data)

	buy_btn.pressed.connect(_on_buy_pressed.bind(row_data))

	return row_data

func show_shop():
	visible = true
	_refresh_ui()

func _get_upgrade_level(key: String) -> int:
	match key:
		"pickaxe_level": return GameState.pickaxe_level
		"oxygen_tank_level": return GameState.oxygen_tank_level
		"inventory_level": return GameState.inventory_level
	return 0

func _set_upgrade_level(key: String, value: int) -> void:
	match key:
		"pickaxe_level": GameState.pickaxe_level = value
		"oxygen_tank_level": GameState.oxygen_tank_level = value
		"inventory_level": GameState.inventory_level = value

func _refresh_ui():
	gold_label.text = "Gold: " + str(GameState.total_earnings)

	for row in upgrade_rows:
		var upgrade = row.upgrade
		var current_level = _get_upgrade_level(upgrade.key)
		var max_level = upgrade.max_level

		row.level_label.text = "Lv " + str(current_level) + "/" + str(max_level)

		if current_level >= max_level:
			row.cost_label.text = "MAX"
			row.buy_btn.disabled = true
		else:
			var cost = upgrade.cost
			row.cost_label.text = str(cost) + "g"
			row.buy_btn.disabled = GameState.total_earnings < cost

func _on_buy_pressed(row: Dictionary):
	var upgrade = row.upgrade
	var current_level = _get_upgrade_level(upgrade.key)
	var max_level = upgrade.max_level

	if current_level >= max_level:
		return

	var cost = upgrade.cost
	if GameState.total_earnings < cost:
		return

	GameState.total_earnings -= cost
	_set_upgrade_level(upgrade.key, current_level + 1)
	GameState.apply_upgrade_effects()
	_refresh_ui()

func _on_close_pressed():
	shop_closed.emit()
	queue_free()
