extends Window

@onready var input: LineEdit = $VerticalAlignment/TokenInput
@onready var secret_button: Button = $VerticalAlignment/SecretButton

func _on_confirmed() -> void:
	var token = input.text.strip_edges()
	
	if (token == ""):
		VisualErrorHandler.show_an_error(tr("ERR_EMPTY_TOKEN"))
		return
	if (token.length() < 59 || token.length() > 120):
		VisualErrorHandler.show_an_error(tr("ERR_INVALID_TOKEN_SIZE"))
		return
	
	var err = FS.save_data("Token", token)
	if err != OK:
		VisualErrorHandler.show_an_error(tr("ERR_CANT_SAVE_THE_TOKEN"))
	
	clean_input_line()

func clean_input_line() -> void: 
	input.text = ""
	
func _on_secret_button_pressed() -> void:
	match input.secret:
		true:
			input.secret = false
			secret_button.text = tr("UI_HIDE_TOKEN")
		false:
			input.secret = true
			secret_button.text = tr("UI_SHOW_TOKEN")
