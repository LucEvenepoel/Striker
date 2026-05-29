extends Node

var documentsdir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
var mainfolderpath = documentsdir.path_join("Striker")
var mainfilepath = mainfolderpath.path_join("StrikerData.json")

var json_dictionary;
 
func _ready() -> void:
	# Chama a função para verificar a integridade do arquivo logo na inicialização.
	SignalManager.connect("AppStarted", verify_integrity)

func verify_integrity():
	if !(FileAccess.file_exists(mainfilepath)):
		var create_file = FileAccess.open(mainfilepath, FileAccess.WRITE)
		create_file.close()
	
	var read_file = FileAccess.open(mainfilepath, FileAccess.READ)
	var content = read_file.get_as_text()
	read_file.close()
	
	if (FileAccess.get_size(mainfilepath) >= 1024 or content.is_empty()):
		repair_file()
	else:
		read_json() # Executa a função de leitura pela primeira vez após a inicialização.

func repair_file():
	var file_write = FileAccess.open(mainfilepath, FileAccess.WRITE)
	var defaultdata = {
		"output": false,
		"token": ""
	}
	json_dictionary = defaultdata
	file_write.store_string(JSON.stringify(defaultdata, "\t"))
	file_write.close()
	
func read_json():
	var read_file = FileAccess.open(mainfilepath, FileAccess.READ)
	var content = read_file.get_as_text()

	if !content.is_empty():
		var json_object = JSON.new()
		var parsed_data = json_object.parse(content)

		if parsed_data == OK:
			json_dictionary = json_object.data
			read_file.close()

			for k in json_dictionary:
				if json_dictionary.has(k):
					var keyvalue = json_dictionary.get(k)
					if typeof(keyvalue) == TYPE_STRING or typeof(keyvalue) == TYPE_BOOL:
						json_dictionary[k] = keyvalue
					else: 
						write_json(k, json_dictionary[k])
			
			SignalManager.ReadComplete.emit()

func write_json(Ekey: Variant, Value: Variant):
	var file_write = FileAccess.open(mainfilepath, FileAccess.WRITE)
	
	if Value != null:
		json_dictionary[Ekey] = Value
	
	file_write.store_string(JSON.stringify(json_dictionary, "\t"))
	file_write.close()
