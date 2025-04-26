extends Node2D

@onready var fop: FileOperationsComponent = %FileOperationsComponent
@onready var view_menu_button_component: ViewMenuButtonComponent = %ViewMenuButtonComponent
@onready var sl_component: SaveLoadComponent = %SaveLoadComponent


func _ready() -> void:
	get_viewport().gui_embed_subwindows = false
	get_tree().set_auto_accept_quit(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		sl_component.save_info()
		get_tree().quit()


func _input(event):
	if event.is_action_pressed("save"):
		if fop.prev_path != "":
			fop.save_file(fop.prev_path)
		else:
			fop._on_file_menu_button_pressed(fop.ButtonID.NEW_FILE)
