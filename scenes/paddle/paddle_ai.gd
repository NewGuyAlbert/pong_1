class_name PaddleAI
## Contains all AI difficulty strategies for the paddle.
## Each method returns a motion Vector2 that paddle.gd applies directly.

const ERROR_EASY := 50.0
const ERROR_MEDIUM := 30.0
const ERROR_HARD := 15.0


## Returns the error range for the current difficulty.
static func get_error_range() -> float:
	match GameSettings.ai_difficulty:
		0:
			return ERROR_EASY
		1:
			return ERROR_MEDIUM
		2:
			return ERROR_HARD
		_:
			return ERROR_EASY


# ── Strategies ───────────────────────────────────────────────────────────────


## Easy: chases the ball's Y. Tracks slower when the ball moves away.
static func get_motion_easy(
	paddle: CharacterBody2D,
	ball: CharacterBody2D,
	error_offset: float,
	delta: float,
) -> Vector2:
	var target_y := ball.position.y + error_offset
	var tracking_speed: float = (
		paddle.speed if _is_approaching(paddle, ball) else paddle.speed / 4.0
	)
	return _move_toward(paddle, target_y, tracking_speed, delta)


## Medium: predicts straight-line shots. Falls back to chasing if a wall
## bounce would occur. Drifts to center when the ball moves away.
static func get_motion_medium(
	paddle: CharacterBody2D,
	ball: CharacterBody2D,
	error_offset: float,
	delta: float,
) -> Vector2:
	if not _is_approaching(paddle, ball):
		return _move_toward(paddle, _center_y(paddle), paddle.speed / 3.0, delta)

	var predicted: float = ball.predict_y(paddle.position.x, false)
	var target_y := predicted if not is_nan(predicted) else ball.position.y
	return _move_toward(paddle, target_y + error_offset, paddle.speed, delta)


## Hard: predicts with wall bounces. Moves faster and returns to center
## promptly when the ball heads away.
static func get_motion_hard(
	paddle: CharacterBody2D,
	ball: CharacterBody2D,
	error_offset: float,
	delta: float,
) -> Vector2:
	if not _is_approaching(paddle, ball):
		return _move_toward(paddle, _center_y(paddle), paddle.speed / 2.0, delta)

	var predicted: float = ball.predict_y(paddle.position.x, true)
	var target_y := predicted if not is_nan(predicted) else ball.position.y
	return _move_toward(paddle, target_y + error_offset, paddle.speed * 1.2, delta)


# ── Helpers ──────────────────────────────────────────────────────────────────


static func _is_approaching(paddle: CharacterBody2D, ball: CharacterBody2D) -> bool:
	if ball.direction == Vector2.ZERO:
		return false
	return (
		(ball.position.x < paddle.position.x and ball.direction.x > 0)
		or (ball.position.x > paddle.position.x and ball.direction.x < 0)
	)


static func _move_toward(
	paddle: CharacterBody2D,
	target_y: float,
	tracking_speed: float,
	delta: float,
) -> Vector2:
	var new_y := move_toward(paddle.position.y, target_y, tracking_speed * delta)
	return Vector2(0, new_y - paddle.position.y)


static func _center_y(paddle: CharacterBody2D) -> float:
	return paddle.get_viewport_rect().size.y / 2.0
