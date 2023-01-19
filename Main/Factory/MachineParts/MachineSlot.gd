extends Area2D

signal filled

@export var allowed_type: Main.RobotPartSlot = Main.RobotPartSlot.BODY

var content:RigidBody2D = null
var disabled:bool = false


func grab_nearby_body() -> void:
	release_body()
	
	for b in get_overlapping_bodies():
		if "is_grabbed" in b and b.is_grabbed and b.slot == allowed_type:
			content = b
			b.snap_to(global_position)
			filled.emit()
			break


func release_body() -> void:
	if content:
		content.unsnap()
		content = null


func destroy_body() -> void:
	if content:
		content.queue_free()
		content = null


func disable() -> void:
	disabled = true


func enable() -> void:
	disabled = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and content:
				content.is_grabbed = true
				release_body()
			elif !event.pressed and !content and !disabled:
				grab_nearby_body()
