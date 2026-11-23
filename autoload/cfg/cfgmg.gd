extends Node

const default_dictionary: Dictionary = { 
	"ShowRequestRawData": false,
	"Token": ""
}
var actual_dictionary: Dictionary = default_dictionary.duplicate()

func _ready() -> void:
	FS.verify_integrity()
	
func get_settings():
	return actual_dictionary
	
func save_data(Ekey: String, Value: Variant):
	if Value != null:
		actual_dictionary[Ekey] = Value
		if FS.write() != OK:
			return ERR_CANT_RESOLVE
	else:
		return ERR_INVALID_DATA
	
	return OK
	
func validate(Dict: Variant):
	if typeof(Dict) != TYPE_DICTIONARY:
		return FS.repair_or_construct_file()

	if Dict.keys().size() > default_dictionary.keys().size():
		return FS.repair_or_construct_file()

	for k in Dict:
		if default_dictionary.has(k):
			if typeof(Dict[k]) == typeof(default_dictionary[k]):
				actual_dictionary[k] = Dict[k]
			else: 
				return FS.repair_or_construct_file()
				
	return OK
