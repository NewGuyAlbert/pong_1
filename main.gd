extends Node2D

var score := [{"left": 0, "right": 0}, 0]

@onready var ball: CharacterBody2D = $Ball
@onready var score_label: Label = $ScoreLabel


# TODO:
# Add audio on ball hit and score
# Add pause menu
# Add menu between pvp and pve
# Add AI opponent (easy, medium, hard)
func _ready() -> void:
	ball.scored.connect(_on_ball_scored)


func _on_ball_scored(player: String) -> void:
	if player == "left":
		score[0]["left"] += 1
	elif player == "right":
		score[0]["right"] += 1
	score_label.text = "%d : %d" % [score[0]["left"], score[0]["right"]]

	# Win condition: first to 3 points
	if score[0]["left"] >= 3:
		score_label.text = "Player 1 Wins! %d : %d" % [score[0]["left"], score[0]["right"]]
		ball.set_physics_process(false)  # Stop the ball
	elif score[0]["right"] >= 3:
		score_label.text = "Player 2 Wins! %d : %d" % [score[0]["left"], score[0]["right"]]
		ball.set_physics_process(false)  # Stop the ball


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
