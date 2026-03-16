# class_name registers a global name for this script, so any other script
# can use Routes.MAIN_MENU etc. without needing to preload or import anything.
# This is NOT an Autoload — no instance is created. It just makes the name
# available project-wide. Works great for static constants like scene paths.
class_name Routes

const MAIN_MENU := "res://scenes/menu/main/main_menu.tscn"
const DIFFICULTY_MENU := "res://scenes/menu/difficulty/difficulty_menu.tscn"
const MULTIPLAYER_MENU := "res://scenes/menu/multiplayer/multiplayer_menu.tscn"
const SETTINGS_MENU := "res://scenes/menu/settings/settings_menu.tscn"
const PLACEHOLDER_SCREEN := "res://scenes/menu/placeholder/placeholder_screen.tscn"
const GAME := "res://scenes/game/game.tscn"
