extends Area2D

signal filled

@export var allowed_type: Main.RobotPartSlot = Main.RobotPartSlot.BODY

var content:RigidBody2D = null
var disabled:bool = false


func insert_body(body) -> void:
	if !disabled and body.slot == allowed_type:
		release_body()
		content = body
		body.snap_to(global_position)
		filled.emit()


func release_body() -> void:
	if is_instance_valid(content):
		content.unsnap()
		content = null


func destroy_body() -> void:
	if is_instance_valid(content):
		content.queue_free()
		content = null


func disable() -> void:
	disabled = true


func enable() -> void:
	disabled = false
