extends CharacterBody2D

## If true, uses W/S keys. If false, uses Up/Down arrows.
@export var is_left_player := true
@export var speed := 400.0

var _clamp_height: float


func _ready() -> void:
	var shape: RectangleShape2D = $CollisionShape2D.shape
	_clamp_height = shape.size.y


func _physics_process(delta: float) -> void:
	var direction := 0.0

	if is_left_player:
		if Input.is_key_pressed(KEY_W):
			direction -= 1.0
		if Input.is_key_pressed(KEY_S):
			direction += 1.0

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
