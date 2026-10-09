extends Window

@onready var input: LineEdit = $VerticalAlignment/TokenInput
@onready var secret_button: Button = $VerticalAlignment/SecretButton

func _on_confirmed() -> void:
	var token = input.text.strip_edges()
	
	if (token == ""):
		OS.alert("O campo do token não pode estar vazio!", "Atenção!")
		return
	if (token.length() < 59 || token.length() > 120):
		OS.alert("Este token parece ter um tamanho inválido, verifique-o!", "Atenção!")
		return
	
	var err = FileManager.write("Token", token)
	if err != OK:
		OS.alert("Não foi possível guardar o token.", "Alerta!")

func _on_canceled() -> void:
	input.text = ""
	
func _on_secret_button_pressed() -> void:
	match input.secret:
		true:
			input.secret = false
			secret_button.text = "Ocultar token"
		false:
			input.secret = true
			secret_button.text = "Ver token"
