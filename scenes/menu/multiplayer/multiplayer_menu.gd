extends Control

@onready var back_button: Button = %BackButton

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton

@onready var multiplayer_screen: Control = %MultiplayerScreen
@onready var host_screen: Control = %HostScreen
@onready var join_screen: Control = %JoinScreen

@onready var cancel_host_button: Button = %HostScreen/CancelButton
@onready var cancel_join_button: Button = %JoinScreen/CancelButton

@onready var address_input_field: LineEdit = %AddressInputField
@onready var join_game_button: Button = %JoinGameButton
@onready var error_label: Label = %ErrorLabel


func _ready() -> void:
	host_button.pressed.connect(_on_host)
	join_button.pressed.connect(_on_join_screen)
	join_game_button.pressed.connect(_on_connect)
	back_button.pressed.connect(_on_back)
	cancel_host_button.pressed.connect(_on_cancel)
	cancel_join_button.pressed.connect(_on_cancel)

	NetworkManager.peer_connected.connect(_on_peer_connected)
	NetworkManager.connection_failed.connect(_on_connection_failed)

	host_screen.visible = false
	join_screen.visible = false
	error_label.visible = false

	host_button.grab_focus()


func _on_host() -> void:
	var err := NetworkManager.host_game()
	if err != OK:
		return
	host_screen.visible = true
	join_screen.visible = false
	multiplayer_screen.visible = false
	cancel_host_button.grab_focus()


func _on_join_screen() -> void:
	join_screen.visible = true
	host_screen.visible = false
	multiplayer_screen.visible = false
	address_input_field.grab_focus()


func _on_connect() -> void:
	error_label.visible = false
	var address := address_input_field.text.strip_edges()
	if address == "":
		address = "127.0.0.1:7000"

	var ip := "127.0.0.1"
	var port := NetworkManager.DEFAULT_PORT
	if ":" in address:
		var parts := address.split(":")
		if parts.size() != 2 or parts[1].to_int() == 0:
			error_label.text = "Invalid format. Use IP:Port (e.g. 127.0.0.1:7000)"
			error_label.visible = true
			return
		ip = parts[0]
		port = parts[1].to_int()
	else:
		ip = address

	if not _is_valid_ip(ip) and not _is_valid_hostname(ip):
		error_label.text = "Invalid IP address or hostname"
		error_label.visible = true
		return

	if port < 1 or port > 65535:
		error_label.text = "Port must be between 1 and 65535"
		error_label.visible = true
		return

	var err := NetworkManager.join_game(ip, port)
	if err != OK:
		error_label.text = "Failed to connect"
		error_label.visible = true
		return
	join_game_button.disabled = true
	join_game_button.text = "Joining..."


func _is_valid_ip(ip: String) -> bool:
	var parts := ip.split(".")
	if parts.size() != 4:
		return false
	for part in parts:
		if not part.is_valid_int():
			return false
		var num := part.to_int()
		if num < 0 or num > 255:
			return false
	return true


func _is_valid_hostname(host: String) -> bool:
	if host.is_empty() or host.length() > 253:
		return false
	var regex := RegEx.new()
	regex.compile("^[a-zA-Z0-9]([a-zA-Z0-9\\-\\.]*[a-zA-Z0-9])?$")
	return regex.search(host) != null


func _on_peer_connected() -> void:
	GameSettings.ai_enabled = false
	get_tree().change_scene_to_file(Routes.GAME)


func _on_connection_failed() -> void:
	join_game_button.disabled = false
	join_game_button.text = "Join"
	error_label.text = "Connection failed"
	error_label.visible = true


func _on_cancel() -> void:
	NetworkManager.close()
	join_game_button.disabled = false
	join_game_button.text = "Join"
	error_label.visible = false
	host_screen.visible = false
	join_screen.visible = false
	multiplayer_screen.visible = true
	host_button.grab_focus()


func _on_back() -> void:
	NetworkManager.close()
	get_tree().change_scene_to_file(Routes.MAIN_MENU)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if host_screen.visible or join_screen.visible:
			_on_cancel()
		else:
			_on_back()
