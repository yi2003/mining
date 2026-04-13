extends CharacterBody2D

@export var floor_number: int = 0

signal player_entered_ladder(ladder)
signal player_exited_ladder()

func _ready():
	add_to_group("ladder")
	$Area2D.body_entered.connect(_on_Area2D_body_entered)
	$Area2D.body_exited.connect(_on_Area2D_body_exited)

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		emit_signal("player_entered_ladder", self)

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		emit_signal("player_exited_ladder")
