extends Node2D

const MAIN_PATH = "user://"

@onready var IDline = $Control/VBoxContainer/IDArea/ROW1/ID 
@onready var run_button: Button = $Control/VBoxContainer/IDArea/ROW2/RunButton
@onready var token_insert_popup: ConfirmationDialog = $InsertTokenPopup

func _ready() -> void:
	SignalManager.search_finshed.connect(
		func (): run_button.disabled = false 
	)
	SignalManager.app_started.emit()

func _on_open_main_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(MAIN_PATH))

func _on_add_token_button_pressed() -> void:
	token_insert_popup.visible = true

func _on_run_button_pressed() -> void:
	var input: String = IDline.text.strip_edges()
	
	if input == "":
		OS.alert("O campo de ID não pode estar vazio.", "Alerta!")
		return
	if !(input.is_valid_int()):
		OS.alert("O ID só pode conter números.", "Alerta!")
		return
	elif (int(input) < 0):
		OS.alert("ID inválido, um ID nunca pode ser negativo.", "Alerta!")
		return

	run_button.disabled = true
	Fetch.fetch(input)
