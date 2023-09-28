@tool
extends Node3D

@export var color: Globals.WedgeColor
var current_color: Globals.WedgeColor
var mesh: MeshInstance3D
var rot = 0
var hovering = false

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = $Mesh


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		if color != current_color:
			set_color(color)
			current_color = color
	else:
		if hovering:
			if Input.is_action_just_pressed("rotate_clockwise"):
				print('rotate cl')
			elif Input.is_action_just_pressed("rotate_counter_clockwise"):
				print('rotate cc')


func set_color(color):
	# Sets the 'primary' color of the wedge. White means white prism with orange sticker.
	match color:
		Globals.WedgeColor.ORANGE:
			mesh.set_surface_override_material(0, load("res://resources/mat_orange.tres"))
			mesh.set_surface_override_material(1, load("res://resources/mat_white.tres"))
		Globals.WedgeColor.WHITE:
			mesh.set_surface_override_material(0, null)
			mesh.set_surface_override_material(1, null)


func _on_area_3d_mouse_entered():
	hovering = true
	$Mesh/Highlight.show()
	print(position)

func _on_area_3d_mouse_exited():
	hovering = false
	$Mesh/Highlight.hide()
