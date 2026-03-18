extends Node2D

const PADDLE_MARGIN := 40.0
const WALL_THICKNESS := 20.0

var score_left := 0
var score_right := 0
var winner := ""
var _network: Node = null

@onready var ball: CharacterBody2D = %Ball
@onready var left_paddle: CharacterBody2D = %LeftPaddle
@onready var right_paddle: CharacterBody2D = %RightPaddle
@onready var score_label: Label = %ScoreLabel
@onready var winner_label: Label = %WinnerLabel
@onready var restart_label: Label = %RestartLabel
@onready var victory_sound: AudioStreamPlayer = %VictorySound
@onready var top_wall: StaticBody2D = %TopWall
@onready var bottom_wall: StaticBody2D = %BottomWall
@onready var center_line: ColorRect = %CenterLine
@onready var pause_menu: Control = %PauseMenu


func _ready() -> void:
	_layout_game_elements()
	ball.scored.connect(_on_ball_scored)

	if GameSettings.is_online:
		_setup_online()
	elif GameSettings.ai_enabled:
		_setup_ai()
	else:
		_setup_coop()


## PvP local: P1 = W/S + left stick + d-pad, P2 = arrows + right stick
func _setup_coop() -> void:
	left_paddle.configure("p1_up", "p1_down")
	right_paddle.configure("p2_up", "p2_down")


## PvE: left player gets both P1 and P2 input actions (WASD + arrows + both sticks).
## Adds a GameAI child node that takes over the right paddle.
func _setup_ai() -> void:
	left_paddle.configure("p1_up", "p1_down", "p2_up", "p2_down")

	var ai := preload("res://scenes/game/game_ai.gd").new()
	ai.name = "GameAI"
	add_child(ai)
	ai.setup(right_paddle, ball)


## Online: adds a GameNetwork child node that handles all RPC sync.
## Host controls the left paddle; client controls the right paddle.
## Both players use P1 input actions (W/S) for their own paddle.
func _setup_online() -> void:
	var net := preload("res://scenes/game/game_network.gd").new()
	net.name = "GameNetwork"
	add_child(net)
	_network = net
	net.score_updated.connect(_on_network_score)

	if GameSettings.is_host:
		left_paddle.configure("p1_up", "p1_down")
		net.setup(ball, left_paddle, right_paddle, pause_menu)
	else:
		right_paddle.configure("p1_up", "p1_down")
		net.setup(ball, right_paddle, left_paddle, pause_menu)


func _on_ball_scored(player: String) -> void:
	# In online mode, only the host processes scoring and syncs to the client
	if GameSettings.is_online and not GameSettings.is_host:
		return

	if player == "left":
		score_left += 1
	else:
		score_right += 1

	# Sync scores and ball reset to the client
	if _network:
		_network.sync_score(score_left, score_right)
		_network.sync_ball_reset()

	_apply_score()


## Called by game_network.gd when the client receives a score update from the host.
func _on_network_score(left: int, right: int) -> void:
	score_left = left
	score_right = right
	_apply_score()


## Updates the score display and checks for a winner.
## Called by both _on_ball_scored (host/offline) and _on_network_score (client).
func _apply_score() -> void:
	score_label.text = "%d   %d" % [score_left, score_right]

	# Win condition: first to win_score points
	if score_left >= GameSettings.win_score:
		if GameSettings.is_online:
			winner = "Host" if GameSettings.is_host else "Opponent"
		else:
			winner = "Player 1"
	elif score_right >= GameSettings.win_score:
		if GameSettings.is_online:
			winner = "Opponent" if GameSettings.is_host else "Host"
		elif GameSettings.ai_enabled:
			winner = "CPU"
		else:
			winner = "Player 2"

	if winner != "":
		winner_label.text = "%s Wins!" % winner
		restart_label.text = _get_restart_text()
		winner_label.show()
		restart_label.show()
		ball.set_physics_process(false)
		left_paddle.set_physics_process(false)
		right_paddle.set_physics_process(false)
		victory_sound.play()
	else:
		ball.scored_sound.play()


func _process(_delta: float) -> void:
	# Keep the restart prompt in sync with the current input device.
	if winner != "":
		restart_label.text = _get_restart_text()


func _unhandled_input(event: InputEvent) -> void:
	# Restart game (after a win)
	if event.is_action_pressed("ui_restart") and winner != "":
		if GameSettings.is_online and not GameSettings.is_host:
			return  # Only the host can restart in online mode
		if _network:
			pause_menu.restart_requested.emit()
		get_tree().reload_current_scene()


func _get_restart_text() -> String:
	if GameSettings.is_online and not GameSettings.is_host:
		if GameSettings.last_input_is_controller:
			return "Press \u25CB to Disconnect"
		return "Press Esc to Disconnect"
	if GameSettings.last_input_is_controller:
		if GameSettings.is_online:
			return "Press \u25B3 to Restart \u00b7 \u25CB to Disconnect"
		return "Press \u25B3 to Restart \u00b7 \u25CB for Menu"
	if GameSettings.is_online:
		return "Press R to Restart \u00b7 Esc to Disconnect"
	return "Press R to Restart \u00b7 Esc for Menu"


## Positions all game elements based on the current viewport size.
## This replaces the hardcoded pixel values that were set in the .tscn file.
func _layout_game_elements() -> void:
	var vp := get_viewport_rect().size

	# Walls span the full width, placed just outside the visible area
	top_wall.position = Vector2(vp.x / 2.0, -WALL_THICKNESS / 2.0)
	bottom_wall.position = Vector2(vp.x / 2.0, vp.y + WALL_THICKNESS / 2.0)
	var wall_shape := RectangleShape2D.new()
	wall_shape.size = Vector2(vp.x, WALL_THICKNESS)
	top_wall.get_node("CollisionShape2D").shape = wall_shape
	bottom_wall.get_node("CollisionShape2D").shape = wall_shape

	# Paddles centered vertically, offset from edges
	left_paddle.position = Vector2(PADDLE_MARGIN, vp.y / 2.0)
	right_paddle.position = Vector2(vp.x - PADDLE_MARGIN, vp.y / 2.0)

	# Score label spans the full width
	score_label.offset_left = 0.0
	score_label.offset_right = vp.x
	score_label.offset_top = 10.0

	# Center line
	center_line.offset_left = vp.x / 2.0 - 1.0
	center_line.offset_right = vp.x / 2.0 + 1.0
	center_line.offset_top = 0.0
	center_line.offset_bottom = vp.y
