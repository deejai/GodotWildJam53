extends Node2D

var box = preload("res://Main/Factory/Box.tscn")

var timer: float = 0
var box_interval: float = 1.5
var next_spawn: float = box_interval

var grabbed_box: ChuteBox = null
var combiner_box1: ChuteBox = null
var combiner_box2: ChuteBox = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer >= next_spawn:
		next_spawn += box_interval
		var new_box = box.instantiate()
		new_box.init([Main.BoxType.RED, Main.BoxType.BLUE, Main.BoxType.YELLOW][randi() % 3])
		new_box.position.x = $BoxChute.position.x + $BoxChute.size.x/2 - 75 + randf() * 150
		add_child(new_box)
		print("box spawned at ", timer, " seconds")
		
	if combiner_box1 != null and combiner_box2 != null:
		match combiner_box1.type:
			Main.BoxType.RED:
				if combiner_box2.type == Main.BoxType.BLUE:
					combiner_produce(Main.BoxType.VIOLET)
				elif combiner_box2.type == Main.BoxType.YELLOW:
					combiner_produce(Main.BoxType.ORANGE)
			Main.BoxType.YELLOW:
				if combiner_box2.type == Main.BoxType.BLUE:
					combiner_produce(Main.BoxType.GREEN)
				elif combiner_box2.type == Main.BoxType.RED:
					combiner_produce(Main.BoxType.ORANGE)
			Main.BoxType.BLUE:
				if combiner_box2.type == Main.BoxType.RED:
					combiner_produce(Main.BoxType.VIOLET)
				elif combiner_box2.type == Main.BoxType.YELLOW:
					combiner_produce(Main.BoxType.GREEN)

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
						if node == combiner_box1:
							combiner_box1 = null
						elif node == combiner_box2:
							combiner_box2 = null
						grabbed_box = node
						grabbed_box.unsnap()
						grabbed_box.disable_gravity()
						break
			elif grabbed_box and !event.pressed:
				if grabbed_box and !combiner_box1 and $CombinerRect1.get_global_rect().has_point(get_global_mouse_position()):
					grabbed_box.snap_to($CombinerRect1.position + $CombinerRect1.size/2)
					combiner_box1 = grabbed_box
				elif grabbed_box and !combiner_box2 and $CombinerRect2.get_global_rect().has_point(get_global_mouse_position()):
					grabbed_box.snap_to($CombinerRect2.position + $CombinerRect2.size/2)
					combiner_box2 = grabbed_box
				else:
					grabbed_box.unsnap()
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


func _on_combiner_area_1_input_event(viewport, event, shape_idx):
	pass # Replace with function body.


func _on_combiner_area_2_input_event(viewport, event, shape_idx):
	pass # Replace with function body.

func combiner_produce(type: Main.BoxType):
	combiner_box1.queue_free()
	combiner_box2.queue_free()
	combiner_box1 = null
	combiner_box2 = null
	var new_box = box.instantiate()
	new_box.init(type)
	new_box.position.x = $Combiner.position.x + $Combiner.size.x/2
	new_box.position.y = $Combiner.position.y - 20
	new_box.get_node("RigidBody2D").linear_velocity = Vector2(-5 + randf() * 10, -300)
	add_child(new_box)
