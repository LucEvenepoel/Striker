extends Node

const settingsfilepath: String = "user://properties.bin"

const default_dictionary: Dictionary = { 
	"ShowRequestRawData": true,
	"Token": ""
}
var actual_dictionary: Dictionary = default_dictionary.duplicate()

func _ready() -> void:
	SignalManager.app_started.connect(
		func ():
			if verify_integrity() == OK:
				read()
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

func read():
	var read_file = FileAccess.open(settingsfilepath, FileAccess.READ)
	if !read_file:
		return repair_file()

	var temp_dictionary = read_file.get_var()
	validate(temp_dictionary)
	read_file.close()

func write():
	var file_write = FileAccess.open(settingsfilepath, FileAccess.WRITE)
	if file_write:
		file_write.store_var(actual_dictionary)
		file_write.close()
		return FileAccess.get_open_error() 

func save_data(Ekey: String, Value: Variant):
	if Value != null:
		actual_dictionary[Ekey] = Value
		if write() != OK:
			return ERR_CANT_RESOLVE
	else:
		return ERR_INVALID_DATA
	
	return OK
	
func validate(dict: Variant):
	if typeof(dict) != TYPE_DICTIONARY:
		return repair_file()

	if dict.keys().size() > default_dictionary.keys().size():
		return repair_file()

	for k in dict:
		if default_dictionary.has(k):
			if typeof(dict[k]) == typeof(default_dictionary[k]):
				actual_dictionary[k] = dict[k]
			else: 
				return repair_file()

	SignalManager.read_finshed.emit()
	return OK
