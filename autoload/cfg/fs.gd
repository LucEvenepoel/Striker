extends Node

const settingsfilepath: String = "user://properties.bin"

# Size in bytes
const MIN_FILE_SIZE: int = 10
const MAX_FILE_SIZE: int = 8192

func verify_integrity():
	if not FileAccess.file_exists(settingsfilepath):
		return repair_or_construct_file()
	
	var file_size = FileAccess.get_size(settingsfilepath)
	# Accepts a file of up to 8 KB
	if file_size < MIN_FILE_SIZE || file_size > MAX_FILE_SIZE:
		return repair_or_construct_file()
	else:
		return read()

func repair_or_construct_file():
	if !(CFGMG.actual_dictionary == CFGMG.default_dictionary):
		CFGMG.actual_dictionary = CFGMG.default_dictionary.duplicate()
	write()

func read():
	var read_file = FileAccess.open(settingsfilepath, FileAccess.READ)
	if !read_file:
		return repair_or_construct_file()

	var temp_dictionary = read_file.get_var()
	CFGMG.validate(temp_dictionary)
	read_file.close()

func write():
	var file_write = FileAccess.open(settingsfilepath, FileAccess.WRITE)
	if file_write:
		file_write.store_var(CFGMG.actual_dictionary)
		file_write.close()
		return FileAccess.get_open_error() 
