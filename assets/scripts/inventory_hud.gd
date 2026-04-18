extends CanvasLayer

@onready var slot_icons: Array = [
	$Panel/Slots/Slot0/Contents/Icon0,
	$Panel/Slots/Slot1/Contents/Icon1,
	$Panel/Slots/Slot2/Contents/Icon2,
	$Panel/Slots/Slot3/Contents/Icon3
]

@onready var slot_labels: Array = [
	$Panel/Slots/Slot0/Contents/Label0,
	$Panel/Slots/Slot1/Contents/Label1,
	$Panel/Slots/Slot2/Contents/Label2,
	$Panel/Slots/Slot3/Contents/Label3
]

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
	PlayerInventory.inventory_changed.connect(UpdateInventoryUI)
	_update_all()
	visible = false
	set_process_unhandled_input(true)

func ToggleInventory():
	visible = not visible
	if visible:
		_update_all()

func _unhandled_input(event):
	if event.is_action_pressed("toggle_inventory"):
		ToggleInventory()
		get_viewport().set_input_as_handled()

func UpdateInventoryUI():
	_update_all()

func _update_all():
	for i in PlayerInventory.MAX_SLOTS:
		var slot = PlayerInventory.slots[i]
		var icon_node = slot_icons[i]
		var label_node = slot_labels[i]

		if slot.locked:
			var base_texture = ORE_TEXTURES.get(slot.ore_type)
			var region = ORE_REGIONS.get(slot.ore_type, Rect2(0, 0, 16, 16))
			if base_texture:
				var atlas = AtlasTexture.new()
				atlas.atlas = base_texture
				atlas.region = region
				icon_node.texture = atlas
				icon_node.visible = true
			label_node.text = "x " + str(slot.count)
		else:
			icon_node.texture = null
			icon_node.visible = false
			label_node.text = "x 0"
