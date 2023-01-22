extends Node

@onready var score_label: Label = $UILayer/ScoreLabel
@onready var submissions: Node2D = $Submissions
@onready var health_progress_bar: TextureProgressBar = $UILayer/HealthUI/TextureProgressBar
@onready var sawblade1: Sprite2D = $SawBlades/SawBlade1/Sprite2D
@onready var sawblade2: Sprite2D = $SawBlades/SawBlade2/Sprite2D
@onready var sparks = load("res://Main/Particles/Sparks.tscn")
@onready var sawblade_sfx = load("res://Main/Sound/SawbladeSound.tscn")
@onready var gameover_scene = load("res://Main/GameOver.tscn")

var health: float = 100
var health_decay: float = 1

var game_time: float = 0.0

func _ready() -> void:
	Main.profits = 0
	submissions.get_child(0).init(get_random_color())
	submissions.get_child(1).init(get_random_color())

func _process(delta: float) -> void:
	game_time += delta

	modify_performance(-health_decay * delta * (1 + game_time/60.0))

	if health == 0:
		get_tree().change_scene_to_packed(gameover_scene)

	sawblade1.rotation -= 3 * delta
	sawblade2.rotation -= 3 * delta


func get_random_color() -> int:
	return randi_range(Main.ColorType.RED, Main.ColorType.VIOLET)


func _on_spawn_object(obj) -> void:
	add_child(obj)


func _on_garbage_collect_area_body_entered(body: Node2D) -> void:
	body.queue_free()


func _on_robot_request_complete() -> void:
	submissions.get_child(0).init(get_random_color())
	submissions.get_child(0).reset()
	modify_profits(10)
	modify_performance(30)


func _on_robot_request_2_complete() -> void:
	submissions.get_child(1).init(get_random_color())
	submissions.get_child(1).reset()
	modify_profits(10)
	modify_performance(30)


func _on_robot_request_placed_slot() -> void:
	modify_profits(1 + randi() % 3)
	modify_performance(10)


func _on_robot_request_2_placed_slot() -> void:
	modify_profits(1 + randi() % 3)
	modify_performance(10)


func _on_saw_blade_body_entered(body):
	if body is GrabbableBody:
		modify_profits(-1 - randi() % 2)
		modify_performance(-5)
		var spark_inst = sparks.instantiate()
		spark_inst.position = body.position + Vector2(20,20)
		add_child(spark_inst)
		body.queue_free()
		

func modify_profits(amount: int):
	Main.profits += amount
	score_label.text = str("" if Main.profits > 0 else "-", "$", abs(Main.profits))
	score_label.set("theme_override_colors/font_color", Color(1,0,0) if Main.profits < 0 else Color("006200"))

func modify_performance(amount: float):
	health = clampf(health + amount, 0.0, 100.0)
	health_progress_bar.value = health
