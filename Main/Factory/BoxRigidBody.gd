extends RigidBody2D

var snap_pos: Vector2 = Vector2.INF

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _integrate_forces(state):
	if(snap_pos != Vector2.INF):
		state.set_transform(Transform2D(0, snap_pos))
		state.angular_velocity = 0
		state.linear_velocity = Vector2.ZERO
