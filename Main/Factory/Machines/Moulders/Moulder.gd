extends Node2D

signal created_product(product)

@export var product_scene: PackedScene

@onready var slot: Area2D = $Slot
@onready var shutter: Node2D = $Shutter
@onready var smoke: Node2D = $Smoke
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var shutter_timer: Timer = $ShutterTimer
@onready var processing_timer: Timer = $ProcessingTimer
@onready var moulder_sound: AudioStreamPlayer = $MoulderSound
@onready var node_2d_shaker: Node = $Node2DShaker
@onready var spawn_position: Marker2D = $SpawnPosition


func _ready() -> void:
	shutter.open()
	smoke.deactivate()


func _process(delta: float) -> void:
	progress_bar.value = 1.0 - processing_timer.time_left / processing_timer.wait_time


func start_processing(color: Main.ColorType) -> void:
	slot.disable()
	shutter.close()
	smoke.activate()
	processing_timer.start()
	node_2d_shaker.start()
	moulder_sound.play()
	shutter_timer.start()
	
	await processing_timer.timeout
	
	stop_processing()
	create_product(color)


func stop_processing() -> void:
	slot.enable()
	shutter.open()
	smoke.deactivate()
	node_2d_shaker.stop()
	shutter_timer.stop()


func create_product(color: Main.ColorType) -> void:
	var product = product_scene.instantiate()
	product.init(color)
	product.position = spawn_position.global_position
	product.linear_velocity = Vector2(-5 + 10 * randf() * 10, -300)
	product.angular_velocity = 0.5 + 1 * randf()
	created_product.emit(product)


func _on_slot_filled() -> void:
	start_processing(slot.content.color)
	slot.destroy_body()


func _on_shutter_timer_timeout() -> void:
	shutter.open()
