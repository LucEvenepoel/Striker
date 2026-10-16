extends Node

func show_an_error(Err: String) -> void:
	var err_dialog = AcceptDialog.new()
	var err_label = Label.new()
	
	err_label.text = Err
	err_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	err_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	err_dialog.title = tr("UI_ALERT")
	err_dialog.add_child(err_label)
	
	get_tree().root.add_child(err_dialog)
	
	err_dialog.popup_centered()
	err_dialog.confirmed.connect(func(): err_dialog.queue_free())
