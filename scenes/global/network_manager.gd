extends Node

signal peer_connected
signal peer_disconnected
signal connection_failed

const DEFAULT_PORT := 7000
const CONNECT_TIMEOUT_MS := 5000

var peer: ENetMultiplayerPeer


func host_game(port: int = DEFAULT_PORT) -> Error:
	print("[Net] host_game() called, port=%d" % port)
	close()  # Clean up any previous session first
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_server(port, 1)  # max 1 client (1v1)
	if err != OK:
		print("[Net] create_server FAILED: ", err)
		return err
	print("[Net] create_server OK, assigning peer")
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	GameSettings.is_online = true
	GameSettings.is_host = true
	return OK


func join_game(address: String, port: int = DEFAULT_PORT) -> Error:
	print("[Net] join_game() called, address=%s port=%d" % [address, port])
	close()  # Clean up any previous session first
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		print("[Net] create_client FAILED: ", err)
		return err
	print("[Net] create_client OK, assigning peer")
	peer.get_peer(1).set_timeout(0, 0, CONNECT_TIMEOUT_MS)  # Instead of the default 30 seconds.
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	GameSettings.is_online = true
	GameSettings.is_host = false
	return OK


func close() -> void:
	print("[Net] close() called, peer=%s" % peer)
	# Disconnect all multiplayer signals to prevent stacking on re-host/re-join
	_disconnect_signals()
	if peer:
		print("[Net] closing peer, state=%d" % peer.get_connection_status())
		multiplayer.multiplayer_peer = null
		peer.close()
		peer = null
	GameSettings.is_online = false
	GameSettings.is_host = false


## Safely disconnects all multiplayer signal callbacks to avoid duplicates.
func _disconnect_signals() -> void:
	var mp := multiplayer
	if mp.peer_connected.is_connected(_on_peer_connected):
		mp.peer_connected.disconnect(_on_peer_connected)
	if mp.peer_disconnected.is_connected(_on_peer_disconnected):
		mp.peer_disconnected.disconnect(_on_peer_disconnected)
	if mp.connected_to_server.is_connected(_on_connected_to_server):
		mp.connected_to_server.disconnect(_on_connected_to_server)
	if mp.connection_failed.is_connected(_on_connection_failed):
		mp.connection_failed.disconnect(_on_connection_failed)
	if mp.server_disconnected.is_connected(_on_server_disconnected):
		mp.server_disconnected.disconnect(_on_server_disconnected)


# Host-side: fires when the client successfully joins the server.
func _on_peer_connected(_id: int) -> void:
	print("[Net] peer_connected id=%d" % _id)
	peer_connected.emit()


# Host-side: fires when the client leaves or loses connection.
func _on_peer_disconnected(_id: int) -> void:
	print("[Net] peer_disconnected id=%d" % _id)
	peer_disconnected.emit()


# Client-side: fires when we successfully connect to the host.
func _on_connected_to_server() -> void:
	print("[Net] connected_to_server")
	peer_connected.emit()


# Client-side: fires when the connection attempt to the host fails (timeout/refused).
func _on_connection_failed() -> void:
	print("[Net] connection_failed!")
	connection_failed.emit()


# Client-side: fires when the host closes or we lose connection to it.
func _on_server_disconnected() -> void:
	print("[Net] server_disconnected")
	peer_disconnected.emit()
