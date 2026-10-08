extends Window

@onready var input: LineEdit = $TokenInput

func _on_confirmed() -> void:
	var token = input.text.strip_edges()
	
	if (token == ""):
		OS.alert("O campo do token não pode estar vazio!", "Atenção!")
		return
	if (token.length() < 59 || token.length() > 120):
		OS.alert("Este token parece ter um tamanho inválido, verifique-o!", "Atenção!")
		return
	
	SignalManager.new_data_inserted.emit("Token", token)

func _on_canceled() -> void:
	input.text = ""
