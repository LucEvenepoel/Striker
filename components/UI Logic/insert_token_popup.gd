extends Window

@onready var input: LineEdit = $TokenInput

func _on_confirmed() -> void:
	var token = input.text
	
	if (token == ""):
		OS.alert("O campo do token não pode estar vazio!", "Atenção!")
		return
	if (token.length() < 59):
		OS.alert("Este token parece curto demais, verifique-o!", "Atenção!")
		return
	
	SignalManager.new_data_inserted.emit("Token", token)

func _on_canceled() -> void:
	input.text = ""
