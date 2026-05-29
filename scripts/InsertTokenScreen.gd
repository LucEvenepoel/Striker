extends Node2D

@onready var inputtoken = $InsertTokenLine
var data;
var tokentext;

func _on_close_insert_token_screen_pressed() -> void:
	self.visible = false
	
func _on_ready_button_pressed() -> void:
	tokentext = inputtoken.text
	
	if tokentext == "":
		OS.alert("O campo não pode estar vazio, insira o token!", "Alerta!")
		return
	else:
		FileManager.write_json("token", "%s" % tokentext)
