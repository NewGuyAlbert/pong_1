extends Node2D

@export var win_score := 3
var score_left := 0
var score_right := 0
var winner := ""

@onready var ball: CharacterBody2D = $Ball
@onready var left_paddle: CharacterBody2D = $LeftPaddle
@onready var right_paddle: CharacterBody2D = $RightPaddle
@onready var score_label: Label = $ScoreLabel
@onready var victory_sound: AudioStreamPlayer = $VictorySound


func _ready() -> void:
	ball.scored.connect(_on_ball_scored)


func _on_ball_scored(player: String) -> void:
	if player == "left":
		score_left += 1
	else:
		score_right += 1

	score_label.text = "%d   %d" % [score_left, score_right]

	# Win condition: first to win_score points
	if score_left >= win_score:
		winner = "Player 1"
	elif score_right >= win_score:
		winner = "Player 2"

	if winner != "":
		score_label.text = "%s Wins! %d - %d" % [winner, score_left, score_right]
		ball.set_physics_process(false)
		left_paddle.set_physics_process(false)
		right_paddle.set_physics_process(false)
		victory_sound.play()
	else:
		ball.scored_sound.play()


func _unhandled_input(event: InputEvent) -> void:
	# Restart game (after a win)
	if event.is_action_pressed("ui_restart") and winner != "":
		get_tree().reload_current_scene()
