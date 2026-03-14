extends Control

@onready var fullscreen_toggle: CheckButton = %FullscreenToggle
@onready var win_score_slider: HSlider = %WinScoreSlider
@onready var win_score_value: Label = %WinScoreValue
@onready var ball_speed_slider: HSlider = %BallSpeedSlider
@onready var ball_speed_value: Label = %BallSpeedValue
@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_value: Label = %VolumeValue
@onready var back_button: Button = %BackButton


func _ready() -> void:
	# Initialize controls from current settings
	fullscreen_toggle.button_pressed = GameSettings.fullscreen

	win_score_slider.min_value = 1
	win_score_slider.max_value = 15
	win_score_slider.step = 1
	win_score_slider.value = GameSettings.win_score
	win_score_value.text = str(GameSettings.win_score)

	ball_speed_slider.min_value = 200
	ball_speed_slider.max_value = 800
	ball_speed_slider.step = 50
	ball_speed_slider.value = GameSettings.ball_speed
	ball_speed_value.text = str(int(GameSettings.ball_speed))

	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.step = 5
	volume_slider.value = int(GameSettings.master_volume * 100)
	volume_value.text = "%d%%" % int(GameSettings.master_volume * 100)

	# Connect signals
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	win_score_slider.value_changed.connect(_on_win_score_changed)
	ball_speed_slider.value_changed.connect(_on_ball_speed_changed)
	volume_slider.value_changed.connect(_on_volume_changed)
	back_button.pressed.connect(_on_back_pressed)

	fullscreen_toggle.grab_focus()


func _on_fullscreen_toggled(enabled: bool) -> void:
	GameSettings.fullscreen = enabled
	GameSettings.apply_fullscreen()


func _on_win_score_changed(value: float) -> void:
	GameSettings.win_score = int(value)
	win_score_value.text = str(int(value))


func _on_ball_speed_changed(value: float) -> void:
	GameSettings.ball_speed = value
	ball_speed_value.text = str(int(value))


func _on_volume_changed(value: float) -> void:
	GameSettings.master_volume = value / 100.0
	volume_value.text = "%d%%" % int(value)
	GameSettings.apply_volume()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(Routes.MAIN_MENU)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(Routes.MAIN_MENU)
