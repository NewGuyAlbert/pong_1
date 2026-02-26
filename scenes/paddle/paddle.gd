extends CharacterBody2D

const AI_ERROR_RANGE := 50.0  # Max pixels of offset in either direction

@export var speed := 400.0

var _is_ai := false  # Value set by game.gd
var _is_left_player := false  # Value set by game.gd
var _ball: CharacterBody2D  # Value set by game.gd
var _clamp_height: float  # Needed to keep paddle within screen bounds

# AI error margin: random offset so the paddle doesn't perfectly track the ball
var _ai_error_offset := 0.0


func _ready() -> void:
	var shape: RectangleShape2D = $CollisionShape2D.shape
	_clamp_height = shape.size.y


func _physics_process(delta: float) -> void:
	var direction := 0.0

	# AI input and mode is pve
	if _is_ai and GameSettings.ai_enabled:
		if GameSettings.ai_difficulty == 0:
			_ai_move_easy(delta)
		elif GameSettings.ai_difficulty == 1:
			_ai_move_easy(delta)  # WIP
		elif GameSettings.ai_difficulty == 2:
			_ai_move_easy(delta)  # WIP
	else:
		# Player input and mode is pve
		if _is_left_player and GameSettings.ai_enabled:
			if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
				direction -= 1.0
			if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
				direction += 1.0
		# Left player input and mode is pvp
		elif _is_left_player:
			if Input.is_key_pressed(KEY_W):
				direction -= 1.0
			if Input.is_key_pressed(KEY_S):
				direction += 1.0
		# Right player input and mode is pvp
		else:
			if Input.is_key_pressed(KEY_UP):
				direction -= 1.0
			if Input.is_key_pressed(KEY_DOWN):
				direction += 1.0

		var motion := Vector2(0, direction * speed * delta)
		move_and_collide(motion)

	# Keep paddle within screen bounds
	position.y = clampf(
		position.y, _clamp_height / 2.0, get_viewport_rect().size.y - _clamp_height / 2.0
	)


# Called by the ball when it collides with this paddle.
func randomize_ai_error() -> void:
	_ai_error_offset = randf_range(-AI_ERROR_RANGE, AI_ERROR_RANGE)


func _ai_move_easy(delta: float) -> void:
	# If ball reference is not set, do nothing.
	if _ball == null:
		return

	var target_y = _ball.position.y + _ai_error_offset

	# Track the ball 4 times slower when it's moving away from the paddle.
	if _ball.direction.x < 0:
		position.y = move_toward(position.y, target_y, speed / 4 * delta)

	# Track the ball at normal speed when it's moving towards the paddle.
	else:
		position.y = move_toward(position.y, target_y, speed * delta)

# TODO: Implement medium and hard AI modes.
