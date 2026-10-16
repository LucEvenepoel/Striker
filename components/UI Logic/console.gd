extends Control

@onready var console_screen: RichTextLabel = $ConsoleVBox/Console
@onready var show_output_button: CheckBox = $ConsoleVBox/ConsoleButtonsHBox/OutputHBox/ShowOutputButton

func _ready() -> void:
	SignalManager.console_log.connect(add_message)
	SignalManager.console_show_link.connect(add_link)
	SignalManager.read_finshed.connect(
	func ():
		show_output_button.set_pressed_no_signal(FS.actual_dictionary["ShowRequestRawData"]) 
	)

func _on_show_output_button_toggled(toggled_on: bool) -> void:
	FS.save_data("ShowRequestRawData", toggled_on)

func add_link(Link: String, Message: String):
	var msg = tr("UI_OPEN_IN_BROWSER") % Message
	var bb_code_link = "[url=%s][color=#6ea8ff]%s[/color][/url] \n" % [Link, msg]
	console_screen.append_text(bb_code_link)
	console_screen.scroll_to_line(console_screen.get_line_count() - 1)

func add_message(Message: String) -> void:
	console_screen.add_text(Message + "\n")
	console_screen.scroll_to_line(console_screen.get_line_count() - 1)

func _on_console_meta_clicked(meta: String) -> void:
	if meta.begins_with("https://cdn.discordapp.com/"):
		OS.shell_open(meta)

func _on_clear_console_button_pressed() -> void:
	console_screen.text = ""
