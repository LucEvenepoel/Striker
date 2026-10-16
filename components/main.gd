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
	set_lang()

func set_lang() -> void:
	var lang = OS.get_locale_language()

	if lang in TranslationServer.get_loaded_locales():
		TranslationServer.set_locale(lang)
	else:
		TranslationServer.set_locale("en")
	
func clean_input() -> void:
	IDline.text = ""

func _on_open_main_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(MAIN_PATH))

func _on_add_token_button_pressed() -> void:
	token_insert_popup.visible = true

func _on_run_button_pressed() -> void:
	var input: String = IDline.text.strip_edges()
	
	if (input != ""):
		var regex = RegEx.create_from_string("^\\d+$")
		var result = regex.search(input)
		
		if (result != null):
			var processed_input = result.get_string()
			run_button.disabled = true
			Fetch.fetch(processed_input)
		else:
			VisualErrorHandler.show_an_error(tr("ERR_INVALID_INPUT"))
	else:
		VisualErrorHandler.show_an_error(tr("ERR_EMPTY_ID"))

	clean_input()
