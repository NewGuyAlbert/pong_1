extends Control

@onready var play_coop_button: Button = %PlayCoopButton
@onready var play_ai_button: Button = %PlayAIButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	play_coop_button.pressed.connect(_on_play_coop)
	play_ai_button.pressed.connect(_on_play_ai)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)


func _on_play_coop() -> void:
	get_tree().change_scene_to_file(Routes.GAME)


func _on_play_ai() -> void:
	get_tree().change_scene_to_file(Routes.PLACEHOLDER_SCREEN)


func _on_settings() -> void:
	get_tree().change_scene_to_file(Routes.PLACEHOLDER_SCREEN)


func _on_quit() -> void:
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	# Quit game
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
