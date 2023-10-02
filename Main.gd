extends Node3D

@export var wedge_count: int = 24
@export var cam_orthogonal = false

var camera: Camera3D
var camera_spatial: Node3D
var cam_rotating = false
var cam_panning = false
var initial_cam_rot
var initial_cam_pos

var pan_sensitivity = 1.0
var rot_sensitivity = 1.0
var zoom_sensitivity = 0.5
var SENS_MULTI = 0.01	# Pan and rotate need small numbers. this allows sensible, human-readable options

var rotation_speed = 1.5	# How quickly wedges rotate
var wedges = []


# Called when the node enters the scene tree for the first time.
func _ready():
	camera = $CameraSpatial/Camera3D
	camera_spatial = $CameraSpatial
	set_cam_orthogonal(cam_orthogonal)
	instantiate_wedges(wedge_count)
	
	camera_spatial.position = wedges[wedge_count/2].global_position
	initial_cam_rot = camera_spatial.rotation
	initial_cam_pos = camera_spatial.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
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
		if cam_panning:
			var mvmt = Vector3(-event.relative.x, event.relative.y, 0.0) * pan_sensitivity * SENS_MULTI
			camera_spatial.translate(mvmt)
		elif cam_rotating:
			camera_spatial.rotation.y -= event.relative.x * rot_sensitivity * SENS_MULTI
			camera_spatial.rotation.x -= event.relative.y * rot_sensitivity * SENS_MULTI
			camera_spatial.rotation.x = clamp(camera_spatial.rotation.x, -PI/2.0, PI/2.0)


func instantiate_wedges(n):
	#var pos = Vector3.ZERO
	var previous_wedge
	var pos = Vector3(-1, 0, 0)
	
	for i in range(n):
		var scene = preload("res://Wedge.tscn")
		var wedge = scene.instantiate()
		
		if previous_wedge:
			previous_wedge.add_child(wedge)
		else:
			add_child(wedge)
		
		wedge.set_position(pos)
		wedges.append(wedge)
		
		wedge.index = i
		wedge.rot_speed = rotation_speed
		wedge.connect("wedge_rotate", _on_wedge_rotate)
		
		if i % 2 == 0:
			wedge.set_color(Globals.WedgeColor.WHITE)
			#pos.x -= 1
		else:
			wedge.set_color(Globals.WedgeColor.ORANGE)
			#wedge.rotation_degrees.z = -180
			#pos.y += 1
		
		if previous_wedge:
			wedge.rotation_degrees.y = 180.0
			wedge.rotation_degrees.z = -90.0
		previous_wedge = wedge


func set_cam_orthogonal(ortho):
	if ortho:
		camera.set_orthogonal(10.0, 0.05, 4000.0)
	else:
		camera.set_perspective(60.0, 0.05, 4000.0)


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
	camera_spatial.position = Vector3.ZERO
	camera_spatial.rotation = initial_cam_rot
	camera.position.z = 8.0

func _on_wedge_rotate(i, dir: Globals.WedgeRotation):
	wedges[i].rotate_wedge(dir)
