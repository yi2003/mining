extends Area2D

signal collected(points: int)

const POINT_VALUE: int = 5
const ORE_TYPE: int = PlayerInventory.OreType.SOLAR

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player" and body.can_move:
        if PlayerInventory.try_add_ore(ORE_TYPE):
            collected.emit(POINT_VALUE)
            queue_free()
