extends Node
## Added as a child of Game in online mode.
## Handles all network sync: paddle positions, ball state, scores, pause, disconnect.

signal score_updated(left: int, right: int)

var _ball: CharacterBody2D
var _local_paddle: CharacterBody2D
var _remote_paddle: CharacterBody2D
var _pause_menu: Control

var _net_ball_target := Vector2.ZERO  # Client-side interpolation target for ball position


## Call from game.gd to wire this network controller.
## local_paddle = the paddle this player controls with input.
## remote_paddle = the other player's paddle (position received via RPC).
func setup(
	ball: CharacterBody2D,
	local_paddle: CharacterBody2D,
	remote_paddle: CharacterBody2D,
	pause_menu: Control
) -> void:
	_ball = ball
	_local_paddle = local_paddle
	_remote_paddle = remote_paddle
	_pause_menu = pause_menu
	_remote_paddle.set_external_control(true)  # Remote paddle is driven by network, not local input
	_net_ball_target = _ball.position

	# Client doesn't run ball physics — it receives state from the host
	if not GameSettings.is_host:
		_ball.set_physics_process(false)

	# Keep processing while paused so pause/disconnect RPCs still arrive
	process_mode = Node.PROCESS_MODE_ALWAYS

	_pause_menu.pause_toggled.connect(_on_pause_toggled)
	_pause_menu.restart_requested.connect(_on_restart_requested)
	NetworkManager.peer_disconnected.connect(_on_peer_disconnected)


func _physics_process(delta: float) -> void:
	# Don't sync positions while the game is paused
	if get_tree().paused:
		return

	# Send local paddle position
	_sync_paddle.rpc(_local_paddle.position.y)

	# Host sends ball state
	if GameSettings.is_host:
		_sync_ball.rpc(_ball.position, _ball.direction, _ball.speed)
	else:
		# Client interpolates ball
		_ball.position = _ball.position.lerp(_net_ball_target, 20.0 * delta)


# Receives the other player's paddle Y position. "any_peer" because both host
# and client send their own paddle position to each other.
@rpc("any_peer", "unreliable")
func _sync_paddle(y: float) -> void:
	_remote_paddle.position.y = y


# Host sends ball state to client every physics frame. "unreliable" because
# a dropped packet is replaced by the next one ~16ms later.
@rpc("authority", "unreliable")
func _sync_ball(pos: Vector2, dir: Vector2, spd: float) -> void:
	_net_ball_target = pos
	_ball.direction = dir
	_ball.speed = spd


# Host sends a reliable reset so the client snaps the ball to center.
@rpc("authority", "reliable")
func _sync_ball_reset(pos: Vector2) -> void:
	_ball.position = pos
	_net_ball_target = pos
	_ball.speed = 0.0
	_ball.direction = Vector2.ZERO


## Called by game.gd when a point is scored (host only).
func sync_score(left: int, right: int) -> void:
	_sync_score.rpc(left, right)


## Called by game.gd after a goal to sync the ball reset to the client.
func sync_ball_reset() -> void:
	_sync_ball_reset.rpc(_ball.position)


# Host sends updated scores to the client. "reliable" because missing a
# score update would desync the game permanently.
@rpc("authority", "reliable")
func _sync_score(left: int, right: int) -> void:
	score_updated.emit(left, right)


# --- Pause sync ---


## Host pressed pause or resume — relay to the client.
func _on_pause_toggled(paused: bool) -> void:
	_sync_pause.rpc(paused)


## Host pressed restart — tell the client to reload too.
func _on_restart_requested() -> void:
	_sync_restart.rpc()


## Client receives the host's pause/resume state.
@rpc("authority", "reliable")
func _sync_pause(paused: bool) -> void:
	if paused:
		_pause_menu.show_remote_pause()
	else:
		_pause_menu.hide_remote_pause()


## Client receives a restart command from the host.
@rpc("authority", "reliable")
func _sync_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


# --- Disconnect ---


## The other player left — freeze the game and show the disconnect screen.
func _on_peer_disconnected() -> void:
	NetworkManager.close()
	_pause_menu.show_opponent_left()
