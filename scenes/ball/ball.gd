extends CharacterBody2D

signal scored(player: String)
signal paddle_hit(paddle: CharacterBody2D)

@export var initial_speed := 400.0
@export var speed_increment := 1.05
@export var max_speed := 2000.0
@export var reset_delay := 1.0

@export var max_bounce_angle := deg_to_rad(50.0)  # Steepest angle when hitting paddle edge
@export var debug_draw := true  # Toggle to show/hide predicted ball path

var speed: float
var direction: Vector2 = Vector2.ZERO
var _resetting := false  # Used to prevent multiple launches during reset.

@onready var paddle_hit_sound: AudioStreamPlayer2D = $PaddleHitSound
@onready var wall_hit_sound: AudioStreamPlayer2D = $WallHitSound
@onready var scored_sound: AudioStreamPlayer2D = $ScoredSound


# This is called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()


# Resets the ball to the center and launches it in a random direction after a short delay.
func reset() -> void:
	var vp := get_viewport_rect().size
	position = vp / 2.0
	speed = 0.0
	direction = Vector2.ZERO
	_launch_after_delay()  # fire-and-forget, reset() itself returns immediately


func _launch_after_delay() -> void:
	if _resetting:
		return  # already waiting to launch, do nothing
	_resetting = true
	await get_tree().create_timer(reset_delay).timeout  # delay before launching
	speed = initial_speed
	var angle := randf_range(-PI / 4, PI / 4)  # random angle between -45 and 45 degrees
	if randi() % 2 == 0:  # 50% chance to launch left or right
		angle += PI
	direction = Vector2.from_angle(angle).normalized()
	_resetting = false


# This is called every physics frame. It checks for collisions and scoring.
func _physics_process(delta: float) -> void:
	# move_and_collide() moves the ball and returns collision info if it hits
	# any physics body (paddle, wall, etc.) — no paddle-specific logic needed.
	var collision := move_and_collide(direction * speed * delta)
	if collision:
		var collider := collision.get_collider()

		# This means we hit a paddle.
		if collider is CharacterBody2D:
			var paddle_height: float = collider.get_node("CollisionShape2D").shape.size.y

			# Where the ball hit the paddle, normalized to -1 (top) to 1 (bottom)
			var offset := clampf(
				(position.y - collider.position.y) / (paddle_height / 2.0), -1.0, 1.0
			)

			# Calculate bounce angle based on hit location, with a maximum angle limit
			# Hitting the center of the paddle (offset=0) results in a straight horizontal bounce (0°),
			# while hitting the edge (offset=±1) results in the maximum bounce angle
			var bounce_angle := offset * max_bounce_angle

			# Reverse horizontal direction from the *incoming* direction (before any bounce)
			var x_dir := -signf(direction.x)
			# cos(45°) = 0.707, sin(45°) = 0.707 → ball goes at a 45° diagonal
			# cos(30°) = 0.866, sin(30°) = 0.5 → ball goes at a 30° diagonal
			direction = Vector2(x_dir * cos(bounce_angle), sin(bounce_angle)).normalized()

			paddle_hit_sound.play()
			paddle_hit.emit(collider)
		elif collider is StaticBody2D:
			direction = direction.bounce(collision.get_normal())
			wall_hit_sound.play()  # Hit the wall
		else:
			direction = direction.bounce(collision.get_normal())

		# Speed up slightly on each hit, capped at max_speed
		speed = minf(speed * speed_increment, max_speed)

	if debug_draw:
		queue_redraw()

	# Check for scoring
	var vp := get_viewport_rect().size
	if position.x < 0:
		scored.emit("right")
		reset()
	elif position.x > vp.x:
		scored.emit("left")
		reset()


## Debug: draws the predicted ball path, bouncing off walls, until it reaches a side.
func _draw() -> void:
	if not debug_draw or direction == Vector2.ZERO:
		return
	var target_x := get_viewport_rect().size.x if direction.x > 0 else 0.0
	var points := (
		BallPredictor
		. simulate_path(
			position,
			direction,
			target_x,
			$CollisionShape2D.shape.radius,
			get_viewport_rect().size,
		)
	)
	BallPredictor.draw_prediction(self, points)


## Predicts the Y coordinate where the ball will reach the given X.
## If include_bounces is true, simulates wall reflections; otherwise returns NAN
## when a wall would be hit before reaching target_x.
func predict_y(target_x: float, include_bounces: bool = true) -> float:
	return (
		BallPredictor
		. predict_y(
			position,
			direction,
			target_x,
			$CollisionShape2D.shape.radius,
			get_viewport_rect().size,
			include_bounces,
		)
	)
