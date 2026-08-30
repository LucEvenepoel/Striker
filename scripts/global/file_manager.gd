extends Node

const settingsfilepath: String = "user://properties.bin"
const NUM_SIGNATURE: int = 2077
var main_app;

const default_dictionary: Dictionary = { 
	"ShowAPIResponse": true,
	"Token": ""
}

var actual_dictionary = default_dictionary.duplicate()

func _ready() -> void:
	SignalManager.connect("app_started", verify_file_integrity)
	main_app = get_tree().current_scene

func verify_file_integrity() -> void:
	if not FileAccess.file_exists(settingsfilepath):
		repair_file()
		return
	
	var file_size = FileAccess.get_size(settingsfilepath)

	if file_size > 0 and file_size < 1024:
		read_and_validate()
	else:
		repair_file()

func repair_file() -> void:
	var file_write = FileAccess.open(settingsfilepath, FileAccess.WRITE)
	if file_write:
		file_write.store_32(NUM_SIGNATURE)
		file_write.store_var(default_dictionary)
		file_write.close()
	
func read_and_validate() -> void:
	var read_file = FileAccess.open(settingsfilepath, FileAccess.READ)
	if not read_file:
		repair_file()
		return

	var sign_number = read_file.get_32()
	
	if sign_number != NUM_SIGNATURE:
		read_file.close()
		repair_file() 
		return

	var temp_dictionary: Dictionary = read_file.get_var()
	read_file.close()

	if typeof(temp_dictionary) != TYPE_DICTIONARY:
		repair_file()
		return

	if temp_dictionary.keys().size() > default_dictionary.keys().size():
		repair_file()
		return

	for k in temp_dictionary:
		if default_dictionary.has(k):
			if typeof(temp_dictionary[k]) == typeof(default_dictionary[k]):
				actual_dictionary[k] = temp_dictionary[k]
			else: 
				write(k, default_dictionary[k])
		else:
			repair_file()
			return
			
	main_app.main_dictionary = actual_dictionary
	SignalManager.read_finshed.emit()

func write(Ekey: Variant, Value: Variant) -> void:
	if Value != null:
		actual_dictionary[Ekey] = Value
	
	var file_write = FileAccess.open(settingsfilepath, FileAccess.WRITE)
	if file_write:
		file_write.store_32(NUM_SIGNATURE)
		file_write.store_var(actual_dictionary)
		file_write.close()
