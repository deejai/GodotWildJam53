extends Node2D

var box = preload("res://Main/Factory/Box.tscn")

var timer: float = 0
var box_interval: float = 1.5
var next_spawn: float = box_interval

var grabbed_box: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer >= next_spawn:
		next_spawn += box_interval
		var new_box = box.instantiate()
		new_box.init([Main.BoxType.HEART, Main.BoxType.WATER, Main.BoxType.STAR][randi() % 3])
		new_box.position.x = $BoxChute.position.x + $BoxChute.size.x/2 - 75 + randf() * 150
		add_child(new_box)
		print("box spawned at ", timer, " seconds")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if grabbed_box == null and event.pressed:
				var query := PhysicsPointQueryParameters2D.new()
				query.position = event.position
				var objects := get_world_2d().direct_space_state.intersect_point(query, 32)
				for object in objects:
					var node = objects[0].collider.get_owner()
					if node is ChuteBox:
						grabbed_box = node
						grabbed_box.disable_gravity()
						break
			elif grabbed_box and !event.pressed:
				grabbed_box.enable_gravity()
				grabbed_box = null

func _physics_process(delta):
	if grabbed_box:
		var body = grabbed_box.get_node("RigidBody2D")
		var vec_to_mouse = get_global_mouse_position() - body.global_position
		var vec_limit = 30
		if vec_to_mouse.length() > vec_limit:
			vec_to_mouse = vec_to_mouse.normalized() * vec_limit
		body.linear_velocity = vec_to_mouse * 50
