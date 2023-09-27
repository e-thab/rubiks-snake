extends Node3D

var ORANGE = 0
var WHITE = 1	#default color
var mesh

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = $Mesh
	set_color(ORANGE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_color(color):
	# Sets the 'primary' color of the wedge. White means white platform with orange sticker.
	match color:
		ORANGE:
			mesh.set_surface_override_material(0, load("res://resources/mat_orange.tres"))
			mesh.set_surface_override_material(1, load("res://resources/mat_white.tres"))
		WHITE:
			mesh.set_surface_override_material(0, null)
			mesh.set_surface_override_material(1, null)
	
