extends Node

enum WedgeColor {WHITE, ORANGE}
enum WedgeRotation {CLOCKWISE, COUNTER_CLOCKWISE}
enum Axis {X, Y}

var animated = true # Animate wedge rotations
var rotation_speed = 1.0 # How quickly wedges rotate if animated

var hover_mode = false
var select_mode = true

var wedges_rotating = 0


func set_rotation_speed(f: float):
	rotation_speed = f


func report_wedge_rotating(rotating, count=1):
	if rotating:
		wedges_rotating += count
	else:
		wedges_rotating -= count


func no_wedges_rotating():
	return wedges_rotating == 0
