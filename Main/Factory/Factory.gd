extends Node2D

var box = preload("res://Main/Factory/Box.tscn")

var timer: float = 0
var box_interval: float = 0.5
var next_spawn: float = box_interval

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer >= next_spawn:
		next_spawn += box_interval
		var new_box = box.instantiate()
		new_box.init(1 + randi() % 6)
		new_box.position.x = $BoxChute.position.x + $BoxChute.size.x/2 - 75 + randf() * 150
		add_child(new_box)
		print("box spawned at ", timer, " seconds")
