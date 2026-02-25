extends Node

var hover_sound: AudioStreamPlayer


func _ready() -> void:
	hover_sound = AudioStreamPlayer.new()
	hover_sound.stream = preload("res://assets/sounds/menu_button.mp3")
	hover_sound.volume_db = -20.0
	add_child(hover_sound)

	# Connect to any Button already in the tree and any added in the future.
	get_tree().node_added.connect(_on_node_added)
	_connect_existing_buttons(get_tree().root)


func _connect_existing_buttons(node: Node) -> void:
	if node is BaseButton:
		node.mouse_entered.connect(_on_button_hovered)
		node.focus_entered.connect(_on_button_hovered)
	for child in node.get_children():
		_connect_existing_buttons(child)


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		# Defer so the node is fully in the tree before connecting.
		node.mouse_entered.connect(_on_button_hovered)
		node.focus_entered.connect(_on_button_hovered)


func _on_button_hovered() -> void:
	hover_sound.play()
