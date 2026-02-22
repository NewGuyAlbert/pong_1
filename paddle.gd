extends CharacterBody2D

## If true, uses W/S keys. If false, uses Up/Down arrows.
@export var is_left_player := true
@export var speed := 400.0


func _physics_process(_delta: float) -> void:
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

	velocity = Vector2(0, direction * speed)
	move_and_slide()

	# Keep paddle within screen bounds
	position.y = clampf(position.y, 50.0, get_viewport_rect().size.y - 50.0)
