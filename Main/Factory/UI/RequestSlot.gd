extends Area2D

signal placed(body)


func grab_nearby_body() -> void:
	for b in get_overlapping_bodies():
		if "is_grabbed" in b and b.is_grabbed:
			placed.emit(b)
			break


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if !event.pressed:
				grab_nearby_body()
