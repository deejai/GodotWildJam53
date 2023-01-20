extends Node

@onready var score_label: Label = $UILayer/ScoreLabel
@onready var submissions: Node2D = $Submissions
@onready var health_progress_bar: TextureProgressBar = $UILayer/HealthUI/TextureProgressBar

var wages: int = 0
var health: float = 100
var health_decay: float = 5

func _ready() -> void:
	submissions.get_child(0).init(get_random_color())
	submissions.get_child(1).init(get_random_color())


func _process(delta: float) -> void:
	score_label.text = str("$", wages)
	
	health = max(0, health - health_decay * delta)
	health_progress_bar.value = health


func get_random_color() -> int:
	return randi_range(Main.ColorType.RED, Main.ColorType.VIOLET)


func _on_spawn_object(obj) -> void:
	add_child(obj)


func _on_garbage_collect_area_body_entered(body: Node2D) -> void:
	body.queue_free()


func _on_robot_request_complete() -> void:
	submissions.get_child(0).init(get_random_color())
	submissions.get_child(0).reset()
	wages += 10


func _on_robot_request_2_complete() -> void:
	submissions.get_child(1).init(get_random_color())
	submissions.get_child(1).reset()
	wages += 10


func _on_robot_request_placed_slot() -> void:
	wages += 1 + randi() % 3


func _on_robot_request_2_placed_slot() -> void:
	wages += 1 + randi() % 3
