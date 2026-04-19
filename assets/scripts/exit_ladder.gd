extends Area2D

signal player_entered_ladder(ladder)
signal player_exited_ladder()

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("player_entered_ladder", self)

func _on_body_exited(body):
	if body.name == "Player":
		emit_signal("player_exited_ladder")
