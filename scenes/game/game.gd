extends Node2D

const PADDLE_MARGIN := 40.0
const WALL_THICKNESS := 20.0

var score_left := 0
var score_right := 0
var winner := ""

@onready var ball: CharacterBody2D = $Ball
@onready var left_paddle: CharacterBody2D = $LeftPaddle
@onready var right_paddle: CharacterBody2D = $RightPaddle
@onready var score_label: Label = $ScoreLabel
@onready var winner_label: Label = %WinnerLabel
@onready var restart_label: Label = %RestartLabel
@onready var victory_sound: AudioStreamPlayer = $VictorySound
@onready var top_wall: StaticBody2D = $TopWall
@onready var bottom_wall: StaticBody2D = $BottomWall
@onready var center_line: ColorRect = $CenterLine


func _ready() -> void:
	_layout_game_elements()

	ball.scored.connect(_on_ball_scored)
	ball.paddle_hit.connect(_on_ball_paddle_hit)

	if GameSettings.ai_enabled:
		# PvE: left player gets both P1 and P2 actions (WASD + arrows + both sticks)
		left_paddle.configure("p1_up", "p1_down", null, "p2_up", "p2_down")
		right_paddle.configure("p2_up", "p2_down", ball)
	else:
		# PvP: P1 = W/S + left stick + d-pad, P2 = arrows + right stick
		left_paddle.configure("p1_up", "p1_down")
		right_paddle.configure("p2_up", "p2_down")


func _on_ball_scored(player: String) -> void:
	if player == "left":
		score_left += 1
	else:
		score_right += 1

	score_label.text = "%d   %d" % [score_left, score_right]

	# Win condition: first to win_score points
	if score_left >= GameSettings.win_score:
		winner = "Player 1"
	elif score_right >= GameSettings.win_score:
		winner = "CPU" if GameSettings.ai_enabled else "Player 2"

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


func _on_ball_paddle_hit(paddle: CharacterBody2D) -> void:
	if GameSettings.ai_enabled and paddle == right_paddle:
		right_paddle.randomize_ai_error()


func _process(_delta: float) -> void:
	# Keep the restart prompt in sync with the current input device.
	if winner != "":
		restart_label.text = _get_restart_text()


func _unhandled_input(event: InputEvent) -> void:
	# Restart game (after a win)
	if event.is_action_pressed("ui_restart") and winner != "":
		get_tree().reload_current_scene()


func _get_restart_text() -> String:
	if GameSettings.last_input_is_controller:
		return "Press \u25B3 to Restart \u00b7 \u25CB for Menu"
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
