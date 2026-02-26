extends CharacterBody2D

@export var speed := 400.0

var _is_ai := false  # Value set by game.gd
var _is_left_player := false  # Value set by game.gd
var _ball: CharacterBody2D  # Value set by game.gd
var _clamp_height: float  # Needed to keep paddle within screen bounds


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


# TODO: add more fun stuff.
# For example it shoulnd't adjust when the the ball goes towards the player.
# Add some human like delay. Add error margin when tracking the ball.
func _ai_move_easy(delta: float) -> void:
	if _ball == null:
		return
	var target_y := _ball.position.y
	position.y = move_toward(position.y, target_y, speed * delta)
