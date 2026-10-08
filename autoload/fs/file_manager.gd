extends Node

const settingsfilepath: String = "user://properties.bin"

const default_dictionary: Dictionary = { 
	"ShowAPIResponse": true,
	"Token": ""
}
var actual_dictionary: Dictionary = default_dictionary.duplicate()

func _ready() -> void:
	SignalManager.app_started.connect(
		func ():
			if verify_integrity() == OK:
				read_and_validate()
			else:
				repair_file()
	)

func verify_integrity():
	if not FileAccess.file_exists(settingsfilepath):
		return repair_file()
	
	var file_size = FileAccess.get_size(settingsfilepath)
	if file_size > 0 and file_size < 1024:
		return OK
	else:
		return ERR_FILE_CORRUPT

func repair_file():
	var file_write = FileAccess.open(settingsfilepath, FileAccess.WRITE)
	if file_write:
		file_write.store_var(default_dictionary)
		file_write.close()
		return FileAccess.get_open_error() 
	
func read_and_validate():
	var read_file = FileAccess.open(settingsfilepath, FileAccess.READ)
	if !read_file:
		return repair_file()

	var temp_dictionary = read_file.get_var()
	read_file.close()

	if typeof(temp_dictionary) != TYPE_DICTIONARY:
		return repair_file()

	if temp_dictionary.keys().size() > default_dictionary.keys().size():
		return repair_file()

	for k in temp_dictionary:
		if default_dictionary.has(k):
			if typeof(temp_dictionary[k]) == typeof(default_dictionary[k]):
				actual_dictionary[k] = temp_dictionary[k]
			else: 
				return repair_file()

	SignalManager.read_finshed.emit()

func write(Ekey: Variant, Value: Variant):
	if Value != null:
		actual_dictionary[Ekey] = Value
	
	var file_write = FileAccess.open(settingsfilepath, FileAccess.WRITE)
	if file_write:
		file_write.store_var(actual_dictionary)
		file_write.close()
		return FileAccess.get_open_error() 
