extends CharacterBody2D

@export var speed := 400.0

var _is_ai := false
var _up_key: Key = KEY_W
var _down_key: Key = KEY_S
var _alt_up_key: Key = KEY_NONE
var _alt_down_key: Key = KEY_NONE
var _ball: CharacterBody2D  # Only used by AI paddle
var _clamp_height: float  # Needed to keep paddle within screen bounds

# AI error margin: random offset so the paddle doesn't perfectly track the ball
var _ai_error_offset := 0.0


## Call this after adding the paddle to the scene tree to set up controls.
## For AI paddle, pass the ball reference; for player paddles pass null.
## Optional alt keys allow a second set of controls (e.g. arrow keys + WASD in PvE).
func configure(
	up_key: Key,
	down_key: Key,
	ball: CharacterBody2D = null,
	alt_up_key: Key = KEY_NONE,
	alt_down_key: Key = KEY_NONE
) -> void:
	_up_key = up_key
	_down_key = down_key
	_alt_up_key = alt_up_key
	_alt_down_key = alt_down_key
	if ball:
		_ball = ball
		_is_ai = true


func _ready() -> void:
	var shape: RectangleShape2D = $CollisionShape2D.shape
	_clamp_height = shape.size.y


func _physics_process(delta: float) -> void:
	var motion := Vector2.ZERO

	if _is_ai and GameSettings.ai_enabled:
		if GameSettings.ai_difficulty == 0:
			motion = PaddleAI.get_motion_easy(self, _ball, _ai_error_offset, delta)
		elif GameSettings.ai_difficulty == 1:
			motion = PaddleAI.get_motion_medium(self, _ball, _ai_error_offset, delta)
		elif GameSettings.ai_difficulty == 2:
			motion = PaddleAI.get_motion_hard(self, _ball, _ai_error_offset, delta)
	else:
		var direction := 0.0
		if (
			Input.is_key_pressed(_up_key)
			or (_alt_up_key != KEY_NONE and Input.is_key_pressed(_alt_up_key))
		):
			direction -= 1.0
		if (
			Input.is_key_pressed(_down_key)
			or (_alt_down_key != KEY_NONE and Input.is_key_pressed(_alt_down_key))
		):
			direction += 1.0
		motion = Vector2(0, direction * speed * delta)

	move_and_collide(motion)

	# Keep paddle within screen bounds
	position.y = clampf(
		position.y, _clamp_height / 2.0, get_viewport_rect().size.y - _clamp_height / 2.0
	)


# Called by the ball when it collides with this paddle.
func randomize_ai_error() -> void:
	_ai_error_offset = randf_range(-PaddleAI.get_error_range(), PaddleAI.get_error_range())
