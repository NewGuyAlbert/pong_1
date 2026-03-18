extends Control

## Emitted when the host pauses or resumes so game_network can sync to the client.
signal pause_toggled(paused: bool)
## Emitted when the host restarts so game_network can tell the client to reload.
signal restart_requested

var _is_online := false
var _is_host := false
var _remote_paused := false  # Client-side: the host has paused
var _opponent_left := false  # The other player disconnected

@onready var paused_label: Label = %PausedLabel
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	hide()

	resume_button.pressed.connect(_resume)
	restart_button.pressed.connect(_restart)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	_is_online = GameSettings.is_online
	_is_host = GameSettings.is_host

	if _is_online:
		main_menu_button.text = "Disconnect"
		if not _is_host:
			# Client can only disconnect — no resume or restart
			resume_button.hide()
			restart_button.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			if _opponent_left or _remote_paused:
				pass  # Cannot dismiss these screens with Escape
			elif _is_online and not _is_host:
				hide()  # Client closes their overlay
			else:
				_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()


func _pause() -> void:
	if _is_online and not _is_host:
		# Client opens an overlay without actually pausing the game
		show()
		main_menu_button.grab_focus()
	else:
		get_tree().paused = true
		show()
		resume_button.grab_focus()
		if _is_online:
			pause_toggled.emit(true)


func _resume() -> void:
	get_tree().paused = false
	hide()
	if _is_online:
		pause_toggled.emit(false)


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	if _is_online:
		NetworkManager.close()
	get_tree().change_scene_to_file(Routes.MAIN_MENU)


func _restart() -> void:
	get_tree().paused = false
	if _is_online:
		restart_requested.emit()
	get_tree().reload_current_scene()


## Called by game_network when the host pauses the game.
## Shows the pause screen on the client (cannot be dismissed by the client).
func show_remote_pause() -> void:
	_remote_paused = true
	get_tree().paused = true
	show()
	main_menu_button.grab_focus()


## Called by game_network when the host resumes.
func hide_remote_pause() -> void:
	_remote_paused = false
	get_tree().paused = false
	hide()


## Shows "Opponent left the game" with a Main Menu button. Non-dismissable.
func show_opponent_left() -> void:
	_opponent_left = true
	paused_label.text = "Opponent left the game"
	resume_button.hide()
	restart_button.hide()
	main_menu_button.text = "Main Menu"
	get_tree().paused = true
	show()
	main_menu_button.grab_focus()
