extends Control

@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(Routes.MAIN_MENU)


func _unhandled_input(event: InputEvent) -> void:
	# Go back to main menu
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(Routes.MAIN_MENU)
