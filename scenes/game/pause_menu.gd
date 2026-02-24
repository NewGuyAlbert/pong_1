extends Control

@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	# Start hidden — hide() sets the built-in 'visible' property to false.
	# show() sets it back to true. We use 'visible' later to check if the
	# pause menu is currently open or closed when Escape is pressed.
	hide()

	resume_button.pressed.connect(_resume)
	restart_button.pressed.connect(_restart)
	main_menu_button.pressed.connect(_main_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_resume()
		else:
			_pause()
		# Prevent the event from propagating further
		get_viewport().set_input_as_handled()


func _pause() -> void:
	get_tree().paused = true
	show()


func _resume() -> void:
	get_tree().paused = false
	hide()


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(Routes.MAIN_MENU)
