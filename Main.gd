extends Node3D

@export var wedge_count: int = 24
@export var cam_orthogonal = false

var camera: Camera3D
var camera_spatial: Node3D
var ui = UI
var cam_rotating = false
var cam_panning = false
var cam_following = true
var initial_cam_rot
var initial_cam_pos

var pan_sensitivity = 1.0
var rot_sensitivity = 1.0
var zoom_sensitivity = 0.5
var SENS_MULTI = 0.01	# Pan and rotate need small numbers. This maps the values to a more readable range

var wedges = []
var last_wedge


# Called when the node enters the scene tree for the first time.
func _ready():
	ui = $UI
	camera = $CameraSpatial/Camera3D
	camera_spatial = $CameraSpatial
	set_cam_orthogonal(cam_orthogonal)
	instantiate_initial_wedge()
	instantiate_wedges(wedge_count - 1)
	
	camera_spatial.position = wedges[wedge_count/2].global_position
	initial_cam_rot = camera_spatial.rotation
	initial_cam_pos = camera_spatial.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	if cam_following:
		camera_spatial.set_position(get_center())


func _unhandled_input(event):	
	if event.is_action("cam_pan"):
		cam_panning = event.is_pressed()
	if event.is_action("cam_rotate"):
		cam_rotating = event.is_pressed()
	if event.is_action("cam_zoom_in"):
		zoom_in()
	if event.is_action("cam_zoom_out"):
		zoom_out()
	if event.is_action("cam_reset"):
		reset_cam()

	if event is InputEventMouseMotion:
		if cam_panning and not cam_following:
			var mvmt = Vector3(-event.relative.x, event.relative.y, 0.0) * pan_sensitivity * SENS_MULTI
			camera_spatial.translate(mvmt)
		elif cam_rotating:
			camera_spatial.rotation.y -= event.relative.x * rot_sensitivity * SENS_MULTI
			camera_spatial.rotation.x -= event.relative.y * rot_sensitivity * SENS_MULTI
			camera_spatial.rotation.x = clamp(camera_spatial.rotation.x, -PI/2.0, PI/2.0)
	#else:
		#print(event)


func instantiate_initial_wedge():
	var scene = preload("res://Wedge.tscn")
	var wedge = scene.instantiate()
	add_child(wedge)
	wedges.append(wedge)
	wedge.connect("wedge_rotate", _on_wedge_rotate)
	last_wedge = wedge


func instantiate_wedges(n):
	var offset = Vector3(-1, 0, 0)
	for i in range(n):
		var scene = preload("res://Wedge.tscn")
		var wedge = scene.instantiate()
		last_wedge.add_child(wedge)
		
		wedge.set_position(offset)
		wedges.append(wedge)
		wedge.index = last_wedge.index + 1
		wedge.connect("wedge_rotate", _on_wedge_rotate)
		wedge.rotation_degrees.y = 180.0
		wedge.rotation_degrees.z = -90.0
		
		if wedge.index % 2 == 0:
			wedge.set_color(Globals.WedgeColor.WHITE)
		else:
			wedge.set_color(Globals.WedgeColor.ORANGE)
		
		last_wedge = wedge


func set_wedge_count(n):
	if n == wedge_count:
		return
	elif n < wedge_count:
		wedges[n].queue_free()
		var kept_wedges = []
		for i in range(n):
			kept_wedges.append(wedges[i])
		wedges = kept_wedges
		last_wedge = wedges[-1]
	elif n > wedge_count:
		instantiate_wedges(n - wedge_count)
	
	wedge_count = n


func wedge_list():
	var wedge_turns = []
	for wedge in wedges:
		wedge_turns.append(wedge.turns)
	return wedge_turns


func get_center():
	var pos_x = []
	var pos_y = []
	var pos_z = []
	for wedge in wedges:
		pos_x.append(wedge.global_position.x)
		pos_y.append(wedge.global_position.y)
		pos_z.append(wedge.global_position.z)
		
	return Vector3(
		avg(pos_x),
		avg(pos_y),
		avg(pos_z)
	)

func avg(lst):
	var t = 0.0
	for x in lst:
		t += x
	return t / len(lst)


func set_cam_orthogonal(ortho):
	if ortho:
		camera.set_orthogonal(10.0, 0.05, 4000.0)
	else:
		camera.set_perspective(60.0, 0.05, 4000.0)
	cam_orthogonal = ortho


func zoom_in():
	if cam_orthogonal:
		if camera.size > 1:
			camera.size -= 0.5
	else:
		if camera.position.z > 1:
			camera.translate(-camera.basis.z.normalized() * zoom_sensitivity)

func zoom_out():
	if cam_orthogonal:
		if camera.size < 30:
			camera.size += 0.5
	else:
		if camera.position.z < 30:
			camera.translate(camera.basis.z.normalized() * zoom_sensitivity)

func reset_cam():
	if cam_orthogonal:
		camera.size = 10.0
	else:
		camera.position.z = 8.0
		
	camera_spatial.rotation = initial_cam_rot
	if not cam_following:
		camera_spatial.position = initial_cam_pos


func _on_wedge_rotate(i, dir: Globals.WedgeRotation):
	wedges[i].rotate_wedge(dir)
	print(wedge_list())


func _on_reset_cam_button_pressed():
	reset_cam()


func _on_cam_mode_button_item_selected(index):
	# Perspective mode button index = 0
	# Orthogonal = 1
	if index == 0:
		set_cam_orthogonal(false)
	elif index == 1:
		set_cam_orthogonal(true)


func _on_cam_follow_button_toggled(button_pressed):
	cam_following = button_pressed


func _on_wedge_count_edit_text_submitted(new_text):
	var n = int(new_text)
	if n > 0:
		set_wedge_count(n)


func _on_rot_speed_slider_value_changed(value):
	Globals.set_rotation_speed(value)


func _on_animate_button_toggled(button_pressed):
	for wedge in wedges:
		Globals.animated = button_pressed
