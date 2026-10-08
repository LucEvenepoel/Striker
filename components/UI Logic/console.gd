extends Control

@onready var main: Node2D = $".."
@onready var console_screen: RichTextLabel = $VBoxContainer/Console
@onready var show_output_button: CheckBox = $VBoxContainer/HBoxContainer/ShowOutputLabel/ShowOutputButton

func _ready() -> void:
	SignalManager.console_log.connect(add_message)
	SignalManager.read_finshed.connect(change_output_button_state)

func change_output_button_state() -> void:
	show_output_button.button_pressed = FileManager.actual_dictionary["ShowAPIResponse"]

func add_message(message: String) -> void:
	console_screen.append_text(message + "\n")
	console_screen.scroll_to_line(console_screen.get_line_count() - 1)

func _on_clear_console_button_pressed() -> void:
	console_screen.text = ""

func _on_show_output_button_toggled(toggled_on: bool) -> void:
	SignalManager.new_data_inserted.emit("ShowAPIResponse", toggled_on)
