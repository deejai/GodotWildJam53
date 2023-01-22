extends Node2D

var grabbed_obj:Node2D

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				grab_obj_at(event.position)
			elif grabbed_obj:
				trigger_droppable_at(event.position)
				release_grabbed_obj()


func trigger_droppable_at(pos: Vector2) -> void:
	for object in query_areas_at(pos):
		var node:Node2D = object.collider
		if node.is_in_group("droppable"):
			node.insert_body(grabbed_obj)
			break


func grab_obj_at(pos: Vector2) -> void:
	for object in query_bodies_at(pos):
		var node:Node2D = object.collider
		if node.is_in_group("grabbable"):
			node.unsnap()
			node.grab()
			grabbed_obj = node
			break


func release_grabbed_obj() -> void:
	if is_instance_valid(grabbed_obj):
		grabbed_obj.release()
		grabbed_obj = null


func query_bodies_at(pos: Vector2) -> Array:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_bodies = true
	query.collide_with_areas = false
	return get_world_2d().direct_space_state.intersect_point(query, 32)


func query_areas_at(pos: Vector2) -> Array:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_bodies = false
	query.collide_with_areas = true
	return get_world_2d().direct_space_state.intersect_point(query, 32)
