extends Node2D

signal created_product(product)

@export var product_scene: PackedScene

@onready var slots: Node2D = $Slots
@onready var shutters: Node2D = $Shutters
@onready var smoke: Node2D = $Smoke
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var shutter_timer: Timer = $ShutterTimer
@onready var processing_timer: Timer = $ProcessingTimer
@onready var combiner_sound: AudioStreamPlayer = $CombinerSound
@onready var node_2d_shaker: Node = $Node2DShaker
@onready var spawn_position: Marker2D = $SpawnPosition

var color_combo_dict := {
	[Main.ColorType.RED, Main.ColorType.YELLOW] : Main.ColorType.ORANGE,
	[Main.ColorType.RED, Main.ColorType.BLUE] : Main.ColorType.VIOLET,
	[Main.ColorType.YELLOW, Main.ColorType.BLUE] : Main.ColorType.GREEN,
}


func _ready() -> void:
	for shutter in shutters.get_children():
		shutter.open()
	smoke.deactivate()


func _process(delta: float) -> void:
	progress_bar.value = 1.0 - processing_timer.time_left / processing_timer.wait_time


func start_processing(color: Main.ColorType) -> void:
	for slot in slots.get_children():
		slot.disable()
	for shutter in shutters.get_children():
		shutter.close()
	smoke.activate()
	processing_timer.start()
	node_2d_shaker.start()
	combiner_sound.play()
	shutter_timer.start()
	
	await processing_timer.timeout
	
	stop_processing()
	create_product(color)


func stop_processing() -> void:
	for slot in slots.get_children():
		slot.enable()
	for shutter in shutters.get_children():
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
	var slot1 = slots.get_child(0)
	var slot2 = slots.get_child(1)
	
	if !slot1.content or !slot2.content:
		return
	
	var color_combo = [slot1.content.color, slot2.content.color]
	color_combo.sort()
	if color_combo_dict.has(color_combo):
		start_processing(color_combo_dict[color_combo])
		for slot in slots.get_children():
			slot.destroy_body()


func _on_shutter_timer_timeout() -> void:
	for shutter in shutters.get_children():
		shutter.open()
