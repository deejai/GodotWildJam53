extends Node2D

@export var min_spawn_rate : float = 0.1
@export var max_spawn_rate : float = 1.0

@onready var timer: Timer = $Timer
@onready var objects: ResourcePreloader = $Objects
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D


func randomize_position() -> void:
	path_follow_2d.progress_ratio = randf()


func spawn_stuff() -> void:
	randomize_position()
	
	var object_names:Array = objects.get_resource_list()
	var object_name = object_names[randi() % object_names.size()]
	var scene:PackedScene = objects.get_resource(object_name)
	var object:Node2D = scene.instantiate()
	object.position = path_follow_2d.global_position
	object.init(randi_range(Main.ColorType.RED, Main.ColorType.VIOLET))
	add_child(object)


func _on_timer_timeout() -> void:
	spawn_stuff()
	timer.start(randf_range(min_spawn_rate, max_spawn_rate))
