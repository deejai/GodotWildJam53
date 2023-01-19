extends Node2D

var box = preload("res://Main/Factory/Box.tscn")

var timer: float = 0
var box_interval: float = 1.5
var next_spawn: float = box_interval

var grabbed_box: ChuteBox = null
var combiner_box1: ChuteBox = null
var combiner_box2: ChuteBox = null

var health: float = 100
var health_decay: float = 5

class Producer:
	var duration: float
	var node: Node
	var timer: float = 0.0
	var payload: Callable = func(): print("Poof!")
	var loaded: bool = false

	func _init(duration: float, node: Node):
		self.duration = duration
		self.node = node

	func tick(delta: float):
		self.timer = max(0.0, self.timer - delta)
		var bar = self.node.get_node("ProgressBar")
		bar.value = 0.0 if self.timer == 0.0 else 100.0 * (1 - self.timer / self.duration)
		bar.visible = self.timer > 0.0
		if self.loaded and self.timer == 0.0:
			self.loaded = false
			self.payload.call()
			self.set_visuals()

	func start():
		self.loaded = true
		self.timer = self.duration
		self.tick(0.0)
		self.set_visuals()

	func ready():
		return self.timer == 0.0
		
	func set_visuals():
		var busy: bool = self.timer > 0.0
		for shutter in self.node.get_node("Shutters").get_children():
			shutter.visible = busy
		self.node.get_node("Smoke").visible = busy

@onready var producers: Dictionary = {
	combiner = Producer.new(3.0, $Combiner),
	headmaker = Producer.new(3.0, $HeadMaker),
	armmaker = Producer.new(3.0, $ArmMaker),
	legmaker = Producer.new(3.0, $LegMaker),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$BGMusic.play()
	$ConveyorBelt/AudioLoop.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	
	for key in producers:
		producers[key].tick(delta)

	if timer >= next_spawn:
		next_spawn += box_interval
		var new_box = box.instantiate()
		new_box.init([Main.BoxType.RED, Main.BoxType.BLUE, Main.BoxType.YELLOW][randi() % 3])
		new_box.position.x = $BoxChute.position.x + $BoxChute.size.x/2 - 75 + randf() * 150
		add_child(new_box)

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

	health = max(0, health - health_decay * delta)
	$HealthUI/TextureProgressBar.value = health

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
				if producers.combiner.ready() and grabbed_box and !combiner_box1 and $Combiner/Rect1.get_global_rect().has_point(get_global_mouse_position()):
					grabbed_box.snap_to($Combiner/Rect1.global_position + $Combiner/Rect1.size/2)
					combiner_box1 = grabbed_box
				elif producers.combiner.ready() and grabbed_box and !combiner_box2 and $Combiner/Rect2.get_global_rect().has_point(get_global_mouse_position()):
					grabbed_box.snap_to($Combiner/Rect2.global_position + $Combiner/Rect2.size/2)
					combiner_box2 = grabbed_box
				elif producers.headmaker.ready() and grabbed_box and $HeadMaker.get_global_rect().has_point(get_global_mouse_position()):
					grabbed_box.queue_free()
				elif producers.armmaker.ready() and grabbed_box and $ArmMaker.get_global_rect().has_point(get_global_mouse_position()):
					grabbed_box.queue_free()
				elif producers.legmaker.ready() and grabbed_box and $LegMaker.get_global_rect().has_point(get_global_mouse_position()):
					grabbed_box.queue_free()
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

func combiner_produce(type: Main.BoxType):
	producers.combiner.start()
	combiner_box1.queue_free()
	combiner_box2.queue_free()
	combiner_box1 = null
	combiner_box2 = null
	producers.combiner.payload = func():
		var new_box = box.instantiate()
		new_box.init(type)
		new_box.position.x = $Combiner.position.x + $Combiner.size.x/2
		new_box.position.y = $Combiner.position.y - 20
		new_box.get_node("RigidBody2D").linear_velocity = Vector2(-5 + randf() * 10, -300)
		add_child(new_box)

func _on_area_2d_body_entered(body):
	var obj = body.get_owner()
	if obj is ChuteBox:
		if obj == grabbed_box:
			grabbed_box = null
		obj.queue_free()
