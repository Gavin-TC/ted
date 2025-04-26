class_name ViewMenuButtonComponent
extends Node

@onready var view_menu_button: MenuButton = %ViewMenuButton
@onready var editor: TextEdit = %TextEdit

enum ButtonID {
	ZOOM_IN,
	ZOOM_OUT,
	DEF_ZOOM,
	BUTTON_ID_COUNT
}
# This is basically just font size.
var def_zoom: int = -1
var cur_zoom: int = -1
var zoom_inc: int = 1


func _ready() -> void:
	view_menu_button.get_popup().add_item("Zoom In", ButtonID.ZOOM_IN)
	view_menu_button.get_popup().add_item("Zoom Out", ButtonID.ZOOM_OUT)
	view_menu_button.get_popup().add_item("Default Zoom", ButtonID.DEF_ZOOM)
	view_menu_button.get_popup().id_pressed.connect(_on_view_menu_button_pressed)

	# Setting up shortcuts
	var shortcut: Shortcut = Shortcut.new()
	var iek: InputEventKey = InputEventKey.new()

	iek.ctrl_pressed = true
	iek.keycode = KEY_EQUAL
	shortcut.events = [iek]
	view_menu_button.get_popup().set_item_shortcut(0, shortcut)

	shortcut = Shortcut.new()
	iek = InputEventKey.new()
	iek.ctrl_pressed = true
	iek.keycode = KEY_MINUS
	shortcut.events = [iek]
	view_menu_button.get_popup().set_item_shortcut(1, shortcut)

	shortcut = Shortcut.new()
	iek = InputEventKey.new()
	iek.ctrl_pressed = true
	iek.keycode = KEY_0
	shortcut.events = [iek]
	view_menu_button.get_popup().set_item_shortcut(2, shortcut)

	def_zoom = editor.get_theme_default_font_size()
	cur_zoom = def_zoom


func _input(event):
	if event.is_action_pressed("zoom_in"):
		_on_view_menu_button_pressed(ButtonID.ZOOM_IN)
	elif event.is_action_pressed("zoom_out"):
		_on_view_menu_button_pressed(ButtonID.ZOOM_OUT)
	elif event.is_action_pressed("def_zoom"):
		_on_view_menu_button_pressed(ButtonID.DEF_ZOOM)


func _on_view_menu_button_pressed(id: int) -> void:
	match id:
		ButtonID.ZOOM_IN: 		cur_zoom += zoom_inc
		ButtonID.ZOOM_OUT: 		cur_zoom -= zoom_inc
		ButtonID.DEF_ZOOM:  	cur_zoom = 	def_zoom
	
	editor.add_theme_font_size_override("font_size", cur_zoom)
