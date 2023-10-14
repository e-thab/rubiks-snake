extends Node3D

signal rotate_selection
signal wedge_select

var color: Globals.WedgeColor
var mesh: MeshInstance3D
var rotation_indicator: MeshInstance3D
var highlight_material: Material
var select_material: Material
var hovering = false
var selected = false

var turns = 0
var index = 0
var selection_index = -1
var inv_selection_index = -1

var rotating = false
var rot_dir: Globals.WedgeRotation
var rot_axis: Globals.Axis
var rot_deg = 0.0
var rot_goal = 0.0
var rot_start = 0.0
var rot_prog = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	highlight_material = load("res://resources/highlight_material.tres")
	select_material = load("res://resources/select_material.tres")
	mesh = $Mesh
	rotation_indicator = $RotationIndicator


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.hover_mode and hovering and not rotating:
		if Input.is_action_just_pressed("rotate_clockwise"):
			rotate_wedge(Globals.WedgeRotation.CLOCKWISE)
		elif Input.is_action_just_pressed("rotate_counter_clockwise"):
			rotate_wedge(Globals.WedgeRotation.COUNTER_CLOCKWISE)
	
	if Globals.select_mode and selected and Globals.no_wedges_rotating():
		if Input.is_action_just_pressed("rotate_clockwise"):
			emit_signal("rotate_selection", Globals.WedgeRotation.CLOCKWISE)
		elif Input.is_action_just_pressed("rotate_counter_clockwise"):
			emit_signal("rotate_selection", Globals.WedgeRotation.COUNTER_CLOCKWISE)
	
	if hovering:
		if Input.is_action_just_pressed("select"):
			if selected:
				deselect()
			else:
				select()


func _physics_process(delta):
	if Globals.animated and rotating:
		rotation_degrees.x = lerp(rotation_degrees.x, rot_goal, rot_prog)

		if Globals.select_mode and selected:
			#rot_prog += delta * (Globals.rotation_speed / (selection_index + 1))
			rot_prog += delta * (Globals.rotation_speed / (inv_selection_index + 1))
		else:
			rot_prog += delta * Globals.rotation_speed
		
		var tolerance = 0.15 * Globals.rotation_speed
		if abs(rotation_degrees.x - rot_goal) < tolerance: 
			end_rotation()
	elif rotating:
		end_rotation()


func end_rotation():
	if int(rot_goal) % 360 == 0:
		rotation_degrees.x = 0
	else:
		rotation_degrees.x = rot_goal
	#print("local: ", rotation_degrees.x)
	#print("global: ", global_rotation_degrees.x)
	rot_prog = 0.0
	rotating = false
	Globals.report_wedge_rotating(false)


func set_color(col):
	# Sets the 'primary' color of the wedge. White means white prism with orange sticker.
	match col:
		Globals.WedgeColor.ORANGE:
			mesh.set_surface_override_material(0, load("res://resources/mat_orange.tres"))
			mesh.set_surface_override_material(1, load("res://resources/mat_white.tres"))
		Globals.WedgeColor.WHITE:
			mesh.set_surface_override_material(0, null)
			mesh.set_surface_override_material(1, null)


func set_index_color(n):
	if n % 2 == 0:
		set_color(Globals.WedgeColor.WHITE)
	else:
		set_color(Globals.WedgeColor.ORANGE)
	index = n


func select():
	selected = true
	mesh.material_overlay = select_material
	rotation_indicator.show()
	emit_signal("wedge_select", self, true)


func deselect():
	selected = false
	mesh.material_overlay = highlight_material
	rotation_indicator.hide()
	emit_signal("wedge_select", self, false)


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
	#print('rotating wedge %d at speed %f' % [index, Globals.rotation_speed/ (inv_selection_index + 1)])
	#print('rotating from %f to %f deg' % [rot_start, rot_goal]) 
	if Globals.hover_mode:
		Globals.report_wedge_rotating(true)


func get_rotation_goal(dir: Globals.WedgeRotation):
	var r = rotation_degrees.x
	match dir:
		Globals.WedgeRotation.CLOCKWISE:
			return (int(r/90)-1) * 90.0
		Globals.WedgeRotation.COUNTER_CLOCKWISE:
			return (int(r/90)+1) * 90.0


func highlight(highlight: bool):
	if highlight:
		mesh.material_overlay = highlight_material
	else:
		mesh.material_overlay = null


func _on_area_3d_mouse_entered():
	hovering = true
	if not selected:
		highlight(true)
	#rotation_indicator.show()

func _on_area_3d_mouse_exited():
	hovering = false
	if not selected:
		highlight(false)
	#rotation_indicator.hide()
