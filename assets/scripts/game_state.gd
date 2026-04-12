extends Node

var score: int = 0

func add_score(points: int) -> void:
	score += points

func reset_score() -> void:
	score = 0
