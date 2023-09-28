extends Node3D

@export var wedges: int = 5

var camera: Camera3D
var camera_spatial: Node3D
var rotating = false
var panning = false
var initial_camera_rot

var pan_sensitivity = 1.0
var rot_sensitivity = 1.0
var zoom_sensitivity = 0.5
var SENS_MULTI = 0.01	# pan and rotate need small numbers. this allows sensible, human-readable options


# Called when the node enters the scene tree for the first time.
func _ready():
	camera = $CameraSpatial/Camera3D
	camera_spatial = $CameraSpatial
	initial_camera_rot = camera_spatial.rotation
	instantiate_wedges(wedges)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event.is_action("cam_pan"):
		panning = event.is_pressed()
	if event.is_action("cam_rotate"):
		rotating = event.is_pressed()
	if event.is_action("cam_zoom_in"):
		zoom_in()
	if event.is_action("cam_zoom_out"):
		zoom_out()
	if event.is_action("cam_reset"):
		reset_cam()
	
	if event is InputEventMouseMotion:
		if panning:
			var mvmt = Vector3(-event.relative.x, event.relative.y, 0.0) * pan_sensitivity * SENS_MULTI
			camera_spatial.translate(mvmt)
		elif rotating:
			camera_spatial.rotation.y -= event.relative.x * rot_sensitivity * SENS_MULTI
			camera_spatial.rotation.x -= event.relative.y * rot_sensitivity * SENS_MULTI
			camera_spatial.rotation.x = clamp(camera_spatial.rotation.x, -PI/2.0, PI/2.0)


func instantiate_wedges(n):
	var pos = Vector3.ZERO
	
	for i in range(n):
		var scene = preload("res://Wedge.tscn")
		var wedge = scene.instantiate()
		add_child(wedge)
		wedge.set_position(pos)
		
		if i % 2 == 0:
			wedge.set_color(Globals.WedgeColor.WHITE)
			pos.x -= 1
		else:
			wedge.set_color(Globals.WedgeColor.ORANGE)
			wedge.rotation_degrees.z = -180
			pos.y += 1


func zoom_in():
	if camera.position.z > 1:
		camera.translate(-camera.basis.z.normalized() * zoom_sensitivity)

func zoom_out():
	if camera.position.z < 30:
		camera.translate(camera.basis.z.normalized() * zoom_sensitivity)

func reset_cam():
	camera_spatial.position = Vector3.ZERO
	camera_spatial.rotation = initial_camera_rot
	camera.position.z = 8.0
