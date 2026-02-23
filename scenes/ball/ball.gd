extends CharacterBody2D

signal scored(player: String)

@export var initial_speed := 300.0

var speed: float
var direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	reset()


func reset() -> void:
	var vp := get_viewport_rect().size
	position = vp / 2.0
	speed = 0.0
	direction = Vector2.ZERO

	# Wait 1 second before launching the ball
	await get_tree().create_timer(1.0).timeout

	# Launch the ball in a random direction
	speed = initial_speed
	var angle := randf_range(-PI / 4, PI / 4)  # Random angle between -45 and 45 degrees
	if randi() % 2 == 0:
		angle += PI  # Flip direction for the second player
	direction = Vector2.from_angle(angle).normalized()


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(direction * speed * delta)
	if collision:
		direction = direction.bounce(collision.get_normal())
		# Speed up slightly on each hit, capped at 2000
		speed = minf(speed * 1.05, 2000.0)

	# Check for scoring
	var vp := get_viewport_rect().size
	if position.x < 0:
		emit_signal("scored", "left")  # left Player scores
		reset()
	elif position.x > vp.x:
		emit_signal("scored", "right")  # right Player scores
		reset()
