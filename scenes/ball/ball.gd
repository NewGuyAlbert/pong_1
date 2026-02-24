extends CharacterBody2D

signal scored(player: String)

@export var initial_speed := 300.0
@export var speed_increment := 1.05
@export var max_speed := 2000.0
@export var reset_delay := 1.0

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
		# bounce() reflects the direction across the surface normal of whatever
		# was hit, simulating a realistic bounce off any collider.
		direction = direction.bounce(collision.get_normal())
		# Speed up slightly on each hit, capped at max_speed
		speed = minf(speed * speed_increment, max_speed)

		var collider := collision.get_collider()
		if collider is CharacterBody2D:
			paddle_hit_sound.play()  # Hit the paddle
		elif collider is StaticBody2D:
			wall_hit_sound.play()  # Hit the wall

	# Check for scoring
	var vp := get_viewport_rect().size
	if position.x < 0:
		scored.emit("right")
		scored_sound.play()
		reset()
	elif position.x > vp.x:
		scored.emit("left")
		scored_sound.play()
		reset()
