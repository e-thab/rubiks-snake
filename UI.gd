extends Control

var wedge_count_edit: LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	wedge_count_edit = $MarginContainer/VBoxContainer/WedgeCountContainer/WedgeCountEdit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_wedge_count_edit_text_changed(new_text):
	var good_text = ""
	for c in new_text:
		if c in "0123456789":
			good_text += c
#		else:
#			print('non-digit entered')
	
	wedge_count_edit.text = good_text
	wedge_count_edit.caret_column = len(good_text)


func _on_wedge_count_edit_text_submitted(new_text):
	wedge_count_edit.release_focus()
