class_name SaveLoadComponent
extends Node

@onready var fop: FileOperationsComponent = %FileOperationsComponent

var open_files: Array = []
var user_info_path: String = "user://user_info.json"


func _ready() -> void:
	load_info()

	fop.connect("file_opened", _on_file_opened)
	fop.connect("file_closed", _on_file_closed)


func save_info() -> void:
	# print("Saving user info...")
	# print("Last opened files: ", open_files)
	var file: FileAccess = FileAccess.open(user_info_path, FileAccess.WRITE)

	if not file:
		# print("File was not valid.")
		return 

	var data = JSON.stringify(open_files, "\t")
	if not file.store_string(data):
		# print("There was an error storing the data...")
		return
	file.close()

	# print("Saved info: ", data)


func load_info() -> void:
	# print("Loading user info...")
	var file: FileAccess = FileAccess.open(user_info_path, FileAccess.READ)
	var data: String = file.get_as_text()

	if file and data == "":
		# print("Nothing retrieved from user info...")
		return

	open_files = JSON.parse_string(data)
	# print("Last opened files: ", open_files)

	for path in open_files:
		fop._on_file_selected(path)
	
	file.close()



func _on_file_opened(path: String) -> void:
	if not open_files.has(path):
		open_files.append(path)
		# print("File opened: ", path)
	# print("Files open: ", open_files)


func _on_file_closed(path: String) -> void:
	if open_files.has(path):
		open_files.erase(path)
		# print("File closed: ", path)
	# print("Files open: ", open_files)
