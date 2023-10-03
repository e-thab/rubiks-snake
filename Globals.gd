extends Node

enum WedgeColor {WHITE, ORANGE}
enum WedgeRotation {CLOCKWISE, COUNTER_CLOCKWISE}

var animated = true # Animate wedge rotations
var rotation_speed = 1.0 # How quickly wedges rotate if animated


func set_rotation_speed(f: float):
	rotation_speed = f
