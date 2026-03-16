extends Node

var ai_enabled := false
var ai_difficulty := 0  # 0 = easy, 1 = medium, 2 = hard

# Multiplayer
var is_online := false
var is_host := false

# Settings with defaults
var fullscreen := false
var win_score := 3
var ball_speed := 400.0
var master_volume := 0.5  # 0.0 to 1.0

# Tracks whether the most recent input came from a controller.
# Used to display the correct button prompts (e.g. "Press R" vs "Press Y").
var last_input_is_controller := false


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		last_input_is_controller = true
	elif event is InputEventJoypadMotion:
		# Ignore stick drift / idle noise — only count deliberate movement.
		if absf(event.axis_value) > 0.5:
			last_input_is_controller = true
	elif event is InputEventKey or event is InputEventMouseButton:
		last_input_is_controller = false


func apply_fullscreen() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func apply_volume() -> void:
	# Convert 0.0–1.0 to dB. AudioServer uses linear_to_db.
	var bus_index := AudioServer.get_bus_index("Master")
	if master_volume <= 0.0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(master_volume))
