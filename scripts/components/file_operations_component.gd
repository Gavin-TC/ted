class_name FileOperationsComponent
extends Node

# All file operations (Including FileMenuButton)

@onready var editor: TextEdit = %TextEdit
@onready var file_menu_button: MenuButton = %FileMenuButton
@onready var file_tab_bar: TabBar = %FileTabBar

enum ButtonID {
	NEW_FILE,
	OPEN_FILE,
	SAVE_FILE,
	SAVE_AS_FILE,
	SETTINGS,
	BUTTON_ID_COUNT
}

var prev_path: String = ""

signal file_opened(path: String)
signal file_closed(path: String)


func _ready() -> void:
	file_menu_button.get_popup().add_item("New", ButtonID.NEW_FILE)
	file_menu_button.get_popup().add_item("Open", ButtonID.OPEN_FILE)
	file_menu_button.get_popup().add_item("Save", ButtonID.SAVE_FILE)
	file_menu_button.get_popup().add_item("Save As", ButtonID.SAVE_AS_FILE)
	file_menu_button.get_popup().add_item("Settings (Soon)", ButtonID.SETTINGS)
	file_menu_button.get_popup().id_pressed.connect(_on_file_menu_button_pressed)

	# Setting up shortcuts (in order by button id)
	var shortcut: Shortcut = Shortcut.new()
	var iek: InputEventKey = InputEventKey.new()

	iek.ctrl_pressed = true
	iek.keycode = KEY_N
	shortcut.events = [iek]
	file_menu_button.get_popup().set_item_shortcut(0, shortcut)

	shortcut = Shortcut.new()
	iek = InputEventKey.new()
	iek.ctrl_pressed = true
	iek.keycode = KEY_O
	shortcut.events = [iek]
	file_menu_button.get_popup().set_item_shortcut(1, shortcut)

	shortcut = Shortcut.new()
	iek = InputEventKey.new()
	iek.ctrl_pressed = true
	iek.keycode = KEY_S
	shortcut.events = [iek]
	file_menu_button.get_popup().set_item_shortcut(2, shortcut)

	_on_file_tab_bar_tab_close_pressed(0)


func _on_file_menu_button_pressed(id: int) -> void:
	var dialog: FileDialog = FileDialog.new()

	dialog.position = Vector2(300, 300)
	dialog.size = Vector2(800, 500)
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.connect("file_selected", Callable(self, "_on_file_selected"))

	if prev_path != "":
		dialog.current_path = prev_path

	match id:
		ButtonID.OPEN_FILE:
			dialog.file_mode = FileDialog.FILE_MODE_OPEN_ANY
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.visible = true
			
		ButtonID.SAVE_AS_FILE, ButtonID.NEW_FILE:
			dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			dialog.visible = true
				
		ButtonID.SAVE_FILE:
			dialog.queue_free() # Not needed for this operation
			save_file(prev_path)
		
		# We need to maybe instantiate an options menu scene?
		ButtonID.SETTINGS:
			dialog.queue_free()

	if dialog:	
		add_child(dialog)


func save_file(path: String) -> void:
	print("Saving file...")

	if path == "":
		return

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)

	var tab: int = file_tab_bar.current_tab
	var title: String = file_tab_bar.get_tab_title(tab)
	if title[-1] == "*": file_tab_bar.set_tab_title(tab, title.substr(0, title.length() - 1))

	if file:
		var content: String = editor.text
		file.store_string(content)
	else:
		push_error("Failed to save file at path: \"%s\"" % path)


## Opens the file and puts the contents into the text editor.
func _on_file_selected(path: String) -> void:
	if path == "":
		return
	
	# If we've opened the file before, we can just read it.
	# If we've never opened the file before, we can create it.
	var file: FileAccess
	# if prev_path:
	# 	file = FileAccess.open(path, FileAccess.READ)
	# else:
	# 	file = FileAccess.open(path, FileAccess.WRITE)

	file = FileAccess.open(path, FileAccess.READ)
	prev_path = path

	if file:
		var content: String = file.get_as_text()
		editor.text = content

		print("path: ", path)
		print("content: ", content)

		emit_signal("file_opened", path)

		# If the tab doesn't exist yet, add the tab
		# with file name as the title and path as the tooltip.
		if get_tab_by_title(path.get_file()) == -1:
			print("adding tab")
			file_tab_bar.add_tab(path.get_file())
			var idx: int = get_tab_by_title(path.get_file())
			file_tab_bar.set_tab_tooltip(idx, path)
			file_tab_bar.current_tab = idx
			file_tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ALWAYS
	else:
		push_error("Failed to open file at path: %s" % path)


func _on_file_tab_bar_tab_close_pressed(tab: int) -> void:
	if tab < 0:
		return

	# Return if user attempts to close "New File" tab
	if file_tab_bar.tab_count > 0 and file_tab_bar.get_tab_title(tab) == "New File":
		return

	if file_tab_bar.tab_count != 0:
		emit_signal("file_closed", file_tab_bar.get_tab_tooltip(tab))
		file_tab_bar.remove_tab(tab)

	# If there are no tabs, add the "New File" tab
	if file_tab_bar.tab_count == 0:
		editor.text = ""
		file_tab_bar.add_tab("New File")
		file_tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_NEVER

	

## Called when the user focuses/clicks another tab
func _on_file_tab_bar_tab_changed(tab: int) -> void:
	if tab < 0:
		return
	
	# Removes the "New File" tab when another tab has been opened
	if file_tab_bar.get_tab_title(0) == "New File" and file_tab_bar.tab_count > 1:
		file_tab_bar.remove_tab(0)
	
	_on_file_selected(file_tab_bar.get_tab_tooltip(file_tab_bar.current_tab))


## Returns the `index` of the tab who's tooltip matches the file path, otherwise returns `-1`.
func get_tab_by_file_path(path: String) -> int:
	for x in range(file_tab_bar.tab_count):
		if file_tab_bar.get_tab_tooltip(x) == path:
			return x
	return -1


## Returns the `index` of the tab who's title matches the file name, otherwise returns `-1`.
func get_tab_by_title(title: String) -> int:
	for x in range(file_tab_bar.tab_count):
		if file_tab_bar.get_tab_title(x) == title:
			return x
	return -1


func _on_text_edit_text_changed() -> void:
	var tab: int = file_tab_bar.current_tab
	var title: String = file_tab_bar.get_tab_title(tab)

	if title[-1] != "*":
		file_tab_bar.set_tab_title(tab, title + "*")
