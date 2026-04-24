extends Node

enum OreType { IRON, GOLD, COAL, SOLAR, DIAMOND, AMETHYST, TIN }

const MAX_SLOTS = 4
const MAX_STACK = 5

class OreSlot:
	var ore_type: OreType = OreType.IRON
	var count: int = 0
	var locked: bool = false

	func is_empty() -> bool:
		return not locked

	func can_accept(type: OreType) -> bool:
		if not locked:
			return true
		return ore_type == type and count < MAX_STACK

	func add(type: OreType) -> bool:
		if not locked:
			ore_type = type
			count = 1
			locked = true
			return true
		if ore_type == type and count < MAX_STACK:
			count += 1
			return true
		return false

var ore_values = {
	OreType.IRON: 10,
	OreType.GOLD: 50,
	OreType.COAL: 5,
	OreType.SOLAR: 75,
	OreType.DIAMOND: 100,
	OreType.AMETHYST: 80,
	OreType.TIN: 8,
}

var slots: Array = []

func _ready():
	for i in MAX_SLOTS:
		var slot = OreSlot.new()
		slots.append(slot)

signal inventory_changed

func try_add_ore(ore_type: OreType) -> bool:
	# First pass: try matching existing slot
	for i in slots.size():
		var slot = slots[i]
		if slot.locked and slot.ore_type == ore_type and slot.count < MAX_STACK:
			slot.count += 1
			print("Added ", _ore_name(ore_type), " to slot ", i, ". Slot now has ", slot.count, "/", MAX_STACK, ".")
			inventory_changed.emit()
			return true

	# Second pass: try empty slot
	for i in slots.size():
		var slot = slots[i]
		if not slot.locked:
			slot.ore_type = ore_type
			slot.count = 1
			slot.locked = true
			print("Added ", _ore_name(ore_type), " to slot ", i, ". Slot now has ", slot.count, "/", MAX_STACK, ".")
			inventory_changed.emit()
			return true

	print("Cannot add ", _ore_name(ore_type), ". Inventory full or no matching slot available.")
	return false

func clear_all():
	for slot in slots:
		slot.locked = false
		slot.count = 0
		slot.ore_type = OreType.IRON
	inventory_changed.emit()

func _ore_name(type: OreType) -> String:
	match type:
		OreType.IRON: return "Iron"
		OreType.GOLD: return "Gold"
		OreType.COAL: return "Coal"
		OreType.SOLAR: return "Solar"
		OreType.DIAMOND: return "Diamond"
		OreType.AMETHYST: return "Amethyst"
		OreType.TIN: return "Tin"
	return "Unknown"

func get_ore_summary() -> Dictionary:
	var summary = {}
	for slot in slots:
		if slot.locked and slot.count > 0:
			if not summary.has(slot.ore_type):
				summary[slot.ore_type] = 0
			summary[slot.ore_type] += slot.count
	return summary

func get_ore_value(type: OreType) -> int:
	if ore_values.has(type):
		return ore_values[type]
	return 0
