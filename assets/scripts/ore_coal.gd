extends Area2D

signal collected(points: int)

const POINT_VALUE: int = 1

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        collected.emit(POINT_VALUE)
        queue_free()
