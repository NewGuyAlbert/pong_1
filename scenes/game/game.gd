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
	ball.paddle_hit.connect(_on_ball_paddle_hit)

	if GameSettings.ai_enabled:
		# PvE: left player gets W/S + arrow keys, right paddle is AI
		left_paddle.configure(KEY_W, KEY_S, null, KEY_UP, KEY_DOWN)
		right_paddle.configure(KEY_UP, KEY_DOWN, ball)
	else:
		# PvP: left player W/S, right player arrow keys
		left_paddle.configure(KEY_W, KEY_S)
		right_paddle.configure(KEY_UP, KEY_DOWN)


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
		winner = "CPU" if GameSettings.ai_enabled else "Player 2"

	if winner != "":
		score_label.text = "%s Wins! %d - %d" % [winner, score_left, score_right]
		ball.set_physics_process(false)
		left_paddle.set_physics_process(false)
		right_paddle.set_physics_process(false)
		victory_sound.play()
	else:
		ball.scored_sound.play()


func _on_ball_paddle_hit(paddle: CharacterBody2D) -> void:
	if GameSettings.ai_enabled and paddle == right_paddle:
		right_paddle.randomize_ai_error()


func _unhandled_input(event: InputEvent) -> void:
	# Restart game (after a win)
	if event.is_action_pressed("ui_restart") and winner != "":
		get_tree().reload_current_scene()
