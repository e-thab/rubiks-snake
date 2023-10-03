extends Control

class_name UI

var wedge_count_edit: LineEdit
var rot_speed_container: HBoxContainer
var rot_speed_slider: HSlider
var rot_speed_label: Label


# Called when the node enters the scene tree for the first time.
func _ready():
	wedge_count_edit = $MarginContainer/VBoxContainer/WedgeCountContainer/WedgeCountEdit
	rot_speed_container = $MarginContainer/VBoxContainer/RotSpeedContainer
	rot_speed_slider = $MarginContainer/VBoxContainer/RotSpeedContainer/RotSpeedSlider
	rot_speed_label = $MarginContainer/VBoxContainer/RotSpeedContainer/ValueLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#func _input(event):
#	if event.is_action("rotate_clockwise") or event.is_action("rotate_counter_clockwise"):\
#		# Without this, pressing 'e' when focused on rot speed spinbox messes with decimal values
#		accept_event()


#func ui_has_focus():
#	for edit in edits:
#		if edit.has_focus():
#			return true
#	return false


func _on_wedge_count_edit_text_changed(new_text):
	var good_text = ""
	for c in new_text:
		if c in "0123456789":
			good_text += c
#		else:
#			print('non-digit entered')
	
	wedge_count_edit.text = good_text
	wedge_count_edit.caret_column = len(good_text)


func _on_speed_slider_value_changed(value):
	rot_speed_label.text = "%.1f" % value


func _on_animate_button_toggled(button_pressed):
	# Disable rotation/animation speed slider
	rot_speed_slider.editable = button_pressed
	if button_pressed:
		rot_speed_container.modulate = Color.WHITE
	else:
		rot_speed_container.modulate = Color.DIM_GRAY
