extends Node2D

signal spawned_box(box)

const box_scene:PackedScene = preload("res://Main/Factory/GrabbableBody/Box/Box.tscn")

@onready var spawn_path_follower: PathFollow2D = $SpawnPath/SpawnPathFollower
@onready var spawn_point: Marker2D = $SpawnPath/SpawnPathFollower/SpawnPoint


func randomize_spawn_point_pos() -> void:
	spawn_path_follower.progress_ratio = randf()


func spawn_box(color:Main.ColorType) -> void:
	randomize_spawn_point_pos()
	
	var box = box_scene.instantiate()
	box.init(color)
	box.position = spawn_point.global_position
	
	spawned_box.emit(box)


func spawn_random_colored_box() -> void:
	var color = Main.PrimaryColors[randi() % 3]
	spawn_box(color)


func _on_spawn_timer_timeout() -> void:
	spawn_random_colored_box()
