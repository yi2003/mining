extends CanvasLayer

@onready var labels = [
	$Slots/Slot0/Label0,
	$Slots/Slot1/Label1,
	$Slots/Slot2/Label2,
	$Slots/Slot3/Label3
]

const ORE_ICONS = {
	PlayerInventory.OreType.IRON: "Ir:",
	PlayerInventory.OreType.GOLD: "Au:",
	PlayerInventory.OreType.COAL: "C:",
	PlayerInventory.OreType.SOLAR: "S:",
	PlayerInventory.OreType.DIAMOND: "D:",
	PlayerInventory.OreType.AMETHYST: "A:",
	PlayerInventory.OreType.TIN: "Tn:"
}

func _ready():
	PlayerInventory.inventory_changed.connect(_update_all)
	_update_all()

func _update_all():
	for i in labels.size():
		var slot = PlayerInventory.slots[i]
		var label = labels[i]
		if slot.locked:
			var icon = ""
			if ORE_ICONS.has(slot.ore_type):
				icon = ORE_ICONS[slot.ore_type]
			label.text = icon + str(slot.count) + "/" + str(PlayerInventory.MAX_STACK)
		else:
			label.text = ""
