extends CharacterBody2D

@export var speed := 400.0  # AI base speed
@export var player_speed := 600.0  # Player base speed

var _is_ai := false
var _is_remote := false
var _up_action: String = ""
var _down_action: String = ""
var _alt_up_action: String = ""
var _alt_down_action: String = ""
var _ball: CharacterBody2D  # Only used by AI paddle
var _clamp_height: float  # Needed to keep paddle within screen bounds

# AI error margin: random offset so the paddle doesn't perfectly track the ball
var _ai_error_offset := 0.0

# Reaction delay state for Easy AI
var _ai_reaction_timer := 0.0
var _ai_ball_was_approaching := false

# Medium AI: whether to fall back to chasing instead of predicting (rolled per rally)
var _ai_medium_chase_fallback := false


## Call this after adding the paddle to the scene tree to set up controls.
## For AI paddle, pass the ball reference; for player paddles pass null.
## Optional alt action allows a second set of controls (e.g. both sticks in PvE).
func configure(
	up_action: String,
	down_action: String,
	ball: CharacterBody2D = null,
	alt_up_action: String = "",
	alt_down_action: String = ""
) -> void:
	_up_action = up_action
	_down_action = down_action
	_alt_up_action = alt_up_action
	_alt_down_action = alt_down_action
	if ball:
		_ball = ball
		_is_ai = true


func configure_remote() -> void:
	_is_remote = true


func _ready() -> void:
	var shape: RectangleShape2D = $CollisionShape2D.shape
	_clamp_height = shape.size.y


func _physics_process(delta: float) -> void:
	if _is_remote:
		return

	var motion := Vector2.ZERO

	if _is_ai and GameSettings.ai_enabled:
		if GameSettings.ai_difficulty == 0:
			# Reaction delay: pause briefly when ball first starts approaching
			var approaching := PaddleAI._is_approaching(self, _ball)
			if approaching and not _ai_ball_was_approaching:
				_ai_reaction_timer = PaddleAI.REACTION_DELAY_EASY
			_ai_ball_was_approaching = approaching

			if _ai_reaction_timer > 0.0:
				_ai_reaction_timer -= delta
			else:
				motion = PaddleAI.get_motion_easy(self, _ball, _ai_error_offset, delta)
		elif GameSettings.ai_difficulty == 1:
			# Roll chase-fallback once per rally (when ball first approaches)
			var approaching_m := PaddleAI._is_approaching(self, _ball)
			if approaching_m and not _ai_ball_was_approaching:
				_ai_medium_chase_fallback = randf() < 0.2
			_ai_ball_was_approaching = approaching_m
			motion = PaddleAI.get_motion_medium(
				self, _ball, _ai_error_offset, delta, _ai_medium_chase_fallback
			)
		elif GameSettings.ai_difficulty == 2:
			motion = PaddleAI.get_motion_hard(self, _ball, _ai_error_offset, delta)
	else:
		var direction := 0.0
		if (
			Input.is_action_pressed(_up_action)
			or (_alt_up_action != "" and Input.is_action_pressed(_alt_up_action))
		):
			direction -= 1.0
		if (
			Input.is_action_pressed(_down_action)
			or (_alt_down_action != "" and Input.is_action_pressed(_alt_down_action))
		):
			direction += 1.0
		motion = Vector2(0, direction * player_speed * delta)

	move_and_collide(motion)

	# Keep paddle within screen bounds
	position.y = clampf(
		position.y, _clamp_height / 2.0, get_viewport_rect().size.y - _clamp_height / 2.0
	)

	if GameSettings.is_online and not _is_remote:
		_sync_position.rpc(position.y)


@rpc("any_peer", "unreliable")
func _sync_position(y: float) -> void:
	position.y = y


# Called by the ball when it collides with this paddle.
func randomize_ai_error() -> void:
	_ai_error_offset = randf_range(-PaddleAI.get_error_range(), PaddleAI.get_error_range())
