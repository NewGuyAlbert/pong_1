extends Node2D

var score := {"left": 0, "right": 0}

@onready var ball: CharacterBody2D = $Ball
@onready var score_label: Label = $ScoreLabel


# TODO:
# Add audio on ball hit and score
# Add restart button for new game or even during a game.
# Ask ai what it would refactor from this code and why
# Make the game work for multiple screen sizes. Also some pixel values are hardcoded
# Add pause menu
# Add menu between pvp and pve
# Add AI opponent (easy, medium, hard)
func _ready() -> void:
	ball.scored.connect(_on_ball_scored)


func _on_ball_scored(player: String) -> void:
	score[player] += 1
	score_label.text = "%d : %d" % [score["left"], score["right"]]

	# Win condition: first to 3 points
	if score["left"] >= 3:
		score_label.text = "Player 1 Wins! %d : %d" % [score["left"], score["right"]]
		ball.set_physics_process(false)  # Stop the ball
	elif score["right"] >= 3:
		score_label.text = "Player 2 Wins! %d : %d" % [score["left"], score["right"]]
		ball.set_physics_process(false)  # Stop the ball


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
