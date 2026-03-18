extends CharacterBody2D

@export var speed := 400.0  # Base speed (used by AI via game_ai.gd)
@export var player_speed := 600.0  # Player input speed

var _up_action: String = ""
var _down_action: String = ""
var _alt_up_action: String = ""
var _alt_down_action: String = ""
var _clamp_height: float  # Half the paddle height, used for screen clamping
var _external_control := false  # When true, _physics_process is skipped (AI or network drives this paddle)


## Sets up input actions for this paddle.
## Optional alt actions allow a second set of controls (e.g. both sticks in PvE).
func configure(
	up_action: String,
	down_action: String,
	alt_up_action: String = "",
	alt_down_action: String = "",
) -> void:
	_up_action = up_action
	_down_action = down_action
	_alt_up_action = alt_up_action
	_alt_down_action = alt_down_action


## Disables local input so an external system (game_ai.gd or game_network.gd)
## can move the paddle directly via move_and_collide().
func set_external_control(enabled: bool) -> void:
	_external_control = enabled


func _ready() -> void:
	var shape: RectangleShape2D = $CollisionShape2D.shape
	_clamp_height = shape.size.y


func _physics_process(delta: float) -> void:
	# Skip local input when controlled externally (AI or network)
	if _external_control:
		return

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

	var motion := Vector2(0, direction * player_speed * delta)
	move_and_collide(motion)
	clamp_to_screen()


## Keeps the paddle within screen bounds. Called by paddle itself and by
## external controllers (game_ai.gd, game_network.gd) after moving the paddle.
func clamp_to_screen() -> void:
	position.y = clampf(
		position.y, _clamp_height / 2.0, get_viewport_rect().size.y - _clamp_height / 2.0
	)
