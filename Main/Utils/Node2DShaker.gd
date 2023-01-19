extends Node

@export var shake_strength:float = 10.0

@onready var parent:Node2D = get_parent()

var origin_position:Vector2


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	var rand_vector = Vector2(randf()*2-1, randf()*2-1).normalized()
	parent.position = origin_position + rand_vector * shake_strength * randf()


func start() -> void:
	origin_position = parent.position
	set_process(true)


func stop() -> void:
	set_process(false)
	parent.position = origin_position
