@tool
extends Node3D

signal wedge_rotate

@export var color: Globals.WedgeColor
var current_color: Globals.WedgeColor
var mesh: MeshInstance3D
var rot_speed = 1.0
var hovering = false
var turns = 0
var index


var rotating = false
var rot_dir: Globals.WedgeRotation
var rot_deg = 0.0
var rot_goal = 0.0
var rot_start = 0.0
var rot_prog = 0.0

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
		if hovering and not rotating:
			if Input.is_action_just_pressed("rotate_clockwise"):
				emit_signal("wedge_rotate", index, Globals.WedgeRotation.CLOCKWISE)
			elif Input.is_action_just_pressed("rotate_counter_clockwise"):
				emit_signal("wedge_rotate", index, Globals.WedgeRotation.COUNTER_CLOCKWISE)
		
		if hovering:
			if Input.is_action_just_pressed("select"):
				# set cam orbit around selected wedge
				print('select')


func _physics_process(delta):
	if rotating:
		rotation_degrees.x = lerp(rotation_degrees.x, rot_goal, rot_prog)
		rot_prog += delta * rot_speed
		
		if abs(rotation_degrees.x - rot_goal) < 0.5:
			rotation_degrees.x = rot_goal
			rotating = false
			rot_prog = 0.0


func set_color(color):
	# Sets the 'primary' color of the wedge. White means white prism with orange sticker.
	match color:
		Globals.WedgeColor.ORANGE:
			mesh.set_surface_override_material(0, load("res://resources/mat_orange.tres"))
			mesh.set_surface_override_material(1, load("res://resources/mat_white.tres"))
		Globals.WedgeColor.WHITE:
			mesh.set_surface_override_material(0, null)
			mesh.set_surface_override_material(1, null)


func rotate_wedge(dir: Globals.WedgeRotation):
	match dir:
		Globals.WedgeRotation.CLOCKWISE:
			#print('rotating wedge %s clockwise' % index)
			if turns == 0:
				turns = 3
			else:
				turns -= 1
			
		Globals.WedgeRotation.COUNTER_CLOCKWISE:
			#print('rotating wedge %s counter clockwise' % index)
			turns = (turns + 1) % 4
	
	rotating = true
	rot_dir = dir
	rot_start = rotation_degrees.x
	rot_goal = get_rotation_goal(dir)


func get_rotation_goal(dir: Globals.WedgeRotation):
	var r = rotation_degrees.x
	match dir:
		Globals.WedgeRotation.CLOCKWISE:
			return (int(r/90)-1) * 90.0
		Globals.WedgeRotation.COUNTER_CLOCKWISE:
			return (int(r/90)+1) * 90.0


func _on_area_3d_mouse_entered():
	hovering = true
	$Mesh/Highlight.show()

func _on_area_3d_mouse_exited():
	hovering = false
	$Mesh/Highlight.hide()
