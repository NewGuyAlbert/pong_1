extends Control

@onready var easy_button: Button = %EasyButton
@onready var medium_button: Button = %MediumButton
@onready var hard_button: Button = %HardButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	easy_button.pressed.connect(_on_difficulty.bind(0))
	medium_button.pressed.connect(_on_difficulty.bind(1))
	hard_button.pressed.connect(_on_difficulty.bind(2))
	back_button.pressed.connect(func(): get_tree().change_scene_to_file(Routes.MAIN_MENU))


func _on_difficulty(level: int) -> void:
	GameSettings.ai_enabled = true
	GameSettings.ai_difficulty = level
	get_tree().change_scene_to_file(Routes.GAME)


func _unhandled_input(event: InputEvent) -> void:
	# Go back to main menu
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(Routes.MAIN_MENU)
