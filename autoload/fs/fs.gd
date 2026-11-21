extends Node

const settingsfilepath: String = "user://properties.bin"

# Size in bytes
const MAX_FILE_SIZE: int = 8192

const default_dictionary: Dictionary = { 
	"ShowRequestRawData": false,
	"Token": ""
}
var actual_dictionary: Dictionary = default_dictionary.duplicate()

func _ready() -> void:
	SignalManager.app_started.connect(verify_integrity)

func verify_integrity():
	if not FileAccess.file_exists(settingsfilepath):
		return repair_or_construct_file()
	
	var file_size = FileAccess.get_size(settingsfilepath)
	# Accepts a file of up to 8 KB
	if file_size > MAX_FILE_SIZE:
		return repair_or_construct_file()
	else:
		return read()

func repair_or_construct_file():
	var file_write = FileAccess.open(settingsfilepath, FileAccess.WRITE)
	if file_write:
		file_write.store_var(default_dictionary)
		file_write.close()
		return FileAccess.get_open_error() 

func read():
	var read_file = FileAccess.open(settingsfilepath, FileAccess.READ)
	if !read_file:
		return repair_or_construct_file()

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
	
func validate(Dict: Variant):
	if typeof(Dict) != TYPE_DICTIONARY:
		return repair_or_construct_file()

	if Dict.keys().size() > default_dictionary.keys().size():
		return repair_or_construct_file()

	for k in Dict:
		if default_dictionary.has(k):
			if typeof(Dict[k]) == typeof(default_dictionary[k]):
				actual_dictionary[k] = Dict[k]
			else: 
				return repair_or_construct_file()

	SignalManager.read_finshed.emit()
	return OK
