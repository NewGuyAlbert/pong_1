extends Node
## Added as a child of Game in AI mode.
## Drives the AI paddle each physics frame using PaddleAI strategies.

var _paddle: CharacterBody2D
var _ball: CharacterBody2D

# AI error margin: random offset so the paddle doesn't perfectly track the ball
var _ai_error_offset := 0.0
# Reaction delay state for Easy AI
var _ai_reaction_timer := 0.0
var _ai_ball_was_approaching := false
# Medium AI: whether to fall back to chasing instead of predicting (rolled per rally)
var _ai_medium_chase_fallback := false


## Call from game.gd to wire this AI controller to a paddle and ball.
## Takes over the paddle's movement via set_external_control(true).
func setup(paddle: CharacterBody2D, ball: CharacterBody2D) -> void:
	_paddle = paddle
	_ball = ball
	_paddle.set_external_control(true)
	# Re-randomize error offset each time the ball hits this paddle
	_ball.paddle_hit.connect(_on_ball_paddle_hit)


func _physics_process(delta: float) -> void:
	if not _paddle or not _ball:
		return

	var motion := Vector2.ZERO

	if GameSettings.ai_difficulty == 0:
		motion = _process_easy(delta)
	elif GameSettings.ai_difficulty == 1:
		motion = _process_medium(delta)
	elif GameSettings.ai_difficulty == 2:
		motion = _process_hard(delta)

	_paddle.move_and_collide(motion)
	_paddle.clamp_to_screen()


# Easy: chases ball's Y with a reaction delay when ball first approaches
func _process_easy(delta: float) -> Vector2:
	var approaching := PaddleAI._is_approaching(_paddle, _ball)
	if approaching and not _ai_ball_was_approaching:
		_ai_reaction_timer = PaddleAI.REACTION_DELAY_EASY
	_ai_ball_was_approaching = approaching

	if _ai_reaction_timer > 0.0:
		_ai_reaction_timer -= delta
		return Vector2.ZERO
	return PaddleAI.get_motion_easy(_paddle, _ball, _ai_error_offset, delta)


# Medium: predicts straight-line shots, falls back to chasing ~20% of rallies
func _process_medium(delta: float) -> Vector2:
	var approaching := PaddleAI._is_approaching(_paddle, _ball)
	if approaching and not _ai_ball_was_approaching:
		_ai_medium_chase_fallback = randf() < 0.2
	_ai_ball_was_approaching = approaching
	return PaddleAI.get_motion_medium(
		_paddle, _ball, _ai_error_offset, delta, _ai_medium_chase_fallback
	)


# Hard: predicts with wall bounces, moves faster, returns to center promptly
func _process_hard(delta: float) -> Vector2:
	return PaddleAI.get_motion_hard(_paddle, _ball, _ai_error_offset, delta)


func _on_ball_paddle_hit(paddle: CharacterBody2D) -> void:
	if paddle == _paddle:
		_ai_error_offset = randf_range(-PaddleAI.get_error_range(), PaddleAI.get_error_range())
