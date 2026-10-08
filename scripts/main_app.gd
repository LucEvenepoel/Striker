extends Node2D

const MAIN_PATH = "user://"

@onready var IDline = $Control/VBoxContainer/IDArea/ROW1/ID 
@onready var run_button: Button = $Control/VBoxContainer/IDArea/ROW2/RunButton
@onready var token_insert_popup: ConfirmationDialog = $InsertTokenPopup


func _ready() -> void:
	SignalManager.app_started.emit()
	SignalManager.new_data_inserted.connect(FileManager.write)
	SignalManager.search_finshed.connect(
		func (): run_button.disabled = false 
	)

func _on_open_main_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(MAIN_PATH))

func _on_add_token_button_pressed() -> void:
	token_insert_popup.visible = true

func _on_run_button_pressed() -> void:
	if IDline.text == "":
		OS.alert("O campo de ID não pode estar vazio.", "Alerta!")
		return
	elif not IDline.text.is_valid_int():
		OS.alert("O ID só pode conter números.", "Alerta!")
		return
	else:
		SignalManager.search_user.emit(IDline.text)
		run_button.disabled = true
