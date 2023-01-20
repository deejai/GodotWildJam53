extends RigidBody2D

const vec_limit = 30

var is_grabbed:bool = false
var snap_pos: Vector2 = Vector2.INF

func _physics_process(delta: float):
	if is_grabbed:
		var vec_to_mouse = get_global_mouse_position() - global_position
		if vec_to_mouse.length() > vec_limit:
			vec_to_mouse = vec_to_mouse.normalized() * vec_limit
		linear_velocity = vec_to_mouse * 50


func _integrate_forces(state):
	if(snap_pos != Vector2.INF):
		state.set_transform(Transform2D(0, snap_pos))
		state.angular_velocity = 0
		state.linear_velocity = Vector2.ZERO


func grab() -> void:
	is_grabbed = true
	get_parent().move_child(self, -1)


func release() -> void:
	is_grabbed = false


func enable_gravity():
	gravity_scale = 1


func disable_gravity():
	gravity_scale = 0


func snap_to(pos: Vector2):
	snap_pos = pos
	custom_integrator = true
	collision_layer = 2
	collision_mask = 2


func unsnap():
	snap_pos = Vector2.INF
	custom_integrator = false
	collision_layer = 1
	collision_mask = 1

