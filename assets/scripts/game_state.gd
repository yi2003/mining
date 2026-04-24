extends Node

var score: int = 0
var total_earnings: int = 0

func add_score(points: int) -> void:
	score += points

func add_earnings(value: int) -> void:
	total_earnings += value

func reset_score() -> void:
	score = 0
