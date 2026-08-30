extends Control

@onready var main_app: Node2D = $".."
@onready var console_screen: RichTextLabel = $VBoxContainer/Console
@onready var show_output_button: CheckBox = $VBoxContainer/HBoxContainer/ShowOutputLabel/ShowOutputButton

func _ready() -> void:
	SignalManager.connect("log", add_message)
	SignalManager.connect("read_finshed", change_output_button_state)

func change_output_button_state() -> void:
	show_output_button.button_pressed = main_app.main_dictionary["ShowAPIResponse"]

func add_message(message: String) -> void:
	console_screen.text += (message + "\n")
	console_screen.scroll_to_line(console_screen.get_line_count() - 1)

func _on_clear_console_button_pressed() -> void:
	console_screen.text = ""

func _on_show_output_button_toggled(toggled_on: bool) -> void:
		main_app.main_dictionary["ShowAPIResponse"] = toggled_on
		FileManager.write("ShowAPIResponse", toggled_on)
