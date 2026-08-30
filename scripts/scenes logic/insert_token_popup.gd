extends Window

@onready var token_input: LineEdit = $TokenInput
@onready var main_app: Node2D = $".."

func _on_confirmed() -> void:
	var token = token_input.text
	
	if (token == ""):
		OS.alert("O campo do token não pode estar vazio!", "Atenção!")
		return
	if (token.length() < 59):
		OS.alert("Este token parece curto demais, verifique-o!", "Atenção!")
		return
		
	main_app.main_dictionary["Token"] = token
	FileManager.write("Token", "%s" % token)
