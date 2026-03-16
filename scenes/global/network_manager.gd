extends Node

signal peer_connected
signal peer_disconnected
signal connection_failed

const DEFAULT_PORT := 7000
const CONNECT_TIMEOUT_MS := 5000

var peer: ENetMultiplayerPeer


func host_game(port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_server(port, 1)  # max 1 client (1v1)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	GameSettings.is_online = true
	GameSettings.is_host = true
	return OK


func join_game(address: String, port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		return err
	peer.get_peer(1).set_timeout(0, 0, CONNECT_TIMEOUT_MS)  # Instead of the default 30 seconds.
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	GameSettings.is_online = true
	GameSettings.is_host = false
	return OK


func close() -> void:
	if peer:
		multiplayer.multiplayer_peer = null
		peer.close()
		peer = null
	GameSettings.is_online = false
	GameSettings.is_host = false


# Host-side: fires when the client successfully joins the server.
func _on_peer_connected(_id: int) -> void:
	peer_connected.emit()


# Host-side: fires when the client leaves or loses connection.
func _on_peer_disconnected(_id: int) -> void:
	peer_disconnected.emit()


# Client-side: fires when we successfully connect to the host.
func _on_connected_to_server() -> void:
	peer_connected.emit()


# Client-side: fires when the connection attempt to the host fails (timeout/refused).
func _on_connection_failed() -> void:
	connection_failed.emit()


# Client-side: fires when the host closes or we lose connection to it.
func _on_server_disconnected() -> void:
	peer_disconnected.emit()
