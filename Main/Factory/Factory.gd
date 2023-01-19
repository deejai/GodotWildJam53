extends Node2D

var box = preload("res://Main/Factory/Box.tscn")
var head = preload("res://Main/Factory/RobotComponents/Head.tscn")
var arm = preload("res://Main/Factory/RobotComponents/Arm.tscn")
var leg = preload("res://Main/Factory/RobotComponents/Leg.tscn")

var robot_request = preload("res://Main/Factory/RobotRequest.tscn")

var timer: float = 0

var box_interval: float = 1.5
var next_spawn: float = box_interval

var request_interval: float = 8.0
var next_request: float = 0.0

var grabbed_box: ChuteBox = null
var grabbed_part: RobotPart = null

var combiner_box1: ChuteBox = null
var combiner_box2: ChuteBox = null

var health: float = 100
var health_decay: float = 5

var robot_requests: Array = [null, null]

var wages: int = 0

@onready var combiner = $Combiner

class Producer:
	var duration: float
	var node: Node
	var timer: float = 0.0
	var payload: Callable = func(): print("Poof!")
	var loaded: bool = false
	var shutter_open_time: float
	var original_pos: Vector2

	func _init(duration: float, node: Node):
		self.duration = duration
		self.node = node
		self.original_pos = node.position
		self.shutter_open_time = 2.05 if node.has_meta("is_combiner") else 2.4

	func tick(delta: float):
		self.timer = max(0.0, self.timer - delta)
		var bar = self.node.get_node("ProgressBar")
		bar.value = 0.0 if self.timer == 0.0 else 100.0 * (1 - self.timer / self.duration)
		bar.visible = self.timer > 0.0
		self.set_visuals()
		if self.loaded:
			if self.timer == 0.0:
				self.loaded = false
				self.payload.call()
			else:
				self.node.position = self.original_pos + Vector2(-1 + 2 * randf(), -1 + 2 * randf())

	func start():
		self.loaded = true
		self.timer = self.duration
		self.tick(0.0)
		self.set_visuals()
		self.node.get_node("Sound").play()

	func ready():
		return self.timer == 0.0
		
	func set_visuals():
		var busy: bool = self.timer > 0.0
		for shutter in self.node.get_node("Shutters").get_children():
			shutter.visible = false if !busy or self.shutter_open_time < (self.duration - self.timer) else true
		self.node.get_node("Smoke").visible = busy
		if !busy:
			self.node.position = self.original_pos

@onready var producers: Dictionary = {
	combiner = Producer.new(2.6, $Combiner),
	headmaker = Producer.new(2.75, $HeadMaker),
	armmaker = Producer.new(2.75, $ArmMaker),
	legmaker = Producer.new(2.75, $LegMaker),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$BGMusic.play()
	$ConveyorBelt/AudioLoop.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	
	$ScoreLabel.text = str("$", wages)

	for key in producers:
		producers[key].tick(delta)

	if timer >= next_request and (robot_requests[0] == null or robot_requests[1] == null):
		next_request = timer + request_interval
		var request_slot = 0 if robot_requests[0] == null else 1
		var new_request = robot_request.instantiate()
		robot_requests[request_slot] = new_request
		new_request.position = $RobotPanel1.position if request_slot == 0 else $RobotPanel2.position
		new_request.init(1 + randi() % 6)
		add_child(new_request)

	if timer >= next_spawn:
		next_spawn = timer + box_interval
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
			if grabbed_box == null and grabbed_part == null and event.pressed:
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
					elif node is RobotPart:
						grabbed_part = node
						grabbed_part.disable_gravity()
						break

			elif grabbed_box and !event.pressed:
				if producers.combiner.ready() and grabbed_box and !combiner_box1 and $Combiner/Rect1.get_global_rect().has_point(get_global_mouse_position()):
					grabbed_box.snap_to($Combiner/Rect1.global_position + $Combiner/Rect1.size/2)
					combiner_box1 = grabbed_box
				elif producers.combiner.ready() and grabbed_box and !combiner_box2 and $Combiner/Rect2.get_global_rect().has_point(get_global_mouse_position()):
					grabbed_box.snap_to($Combiner/Rect2.global_position + $Combiner/Rect2.size/2)
					combiner_box2 = grabbed_box
				elif producers.headmaker.ready() and grabbed_box and $HeadMaker.get_global_rect().has_point(get_global_mouse_position()):
					part_produce(grabbed_box.type, Main.RobotPart.HEAD)
					grabbed_box.queue_free()
				elif producers.armmaker.ready() and grabbed_box and $ArmMaker.get_global_rect().has_point(get_global_mouse_position()):
					part_produce(grabbed_box.type, Main.RobotPart.ARM)
					grabbed_box.queue_free()
				elif producers.legmaker.ready() and grabbed_box and $LegMaker.get_global_rect().has_point(get_global_mouse_position()):
					part_produce(grabbed_box.type, Main.RobotPart.LEG)
					grabbed_box.queue_free()
				else:
					grabbed_box.unsnap()
					grabbed_box.enable_gravity()

				grabbed_box = null

			elif grabbed_part and !event.pressed:
				
				for panel in [$RobotPanel1, $RobotPanel2]:
					var request_index = panel.get_meta("RequestIndex")
					var request: RobotRequest = robot_requests[request_index]
					if request and request.type == grabbed_part.type and panel.get_global_rect().has_point(get_global_mouse_position()):
						var success = request.submit_part(grabbed_part)
						if success:
							grabbed_part.queue_free()
							wages += 1 + randi() % 3
							if request.complete():
								robot_requests[request_index].queue_free()
								robot_requests[request_index] = null
								wages += 10

				grabbed_part.enable_gravity()
				grabbed_part = null

func _physics_process(delta):
	var grabbed_item = grabbed_box if grabbed_box else grabbed_part if grabbed_part else null
	if grabbed_item:
		var body = grabbed_item.get_node("RigidBody2D")
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
		new_box.position = Vector2($Combiner.position.x + $Combiner.size.x/2, $Combiner.position.y - 20)
		new_box.get_node("RigidBody2D").linear_velocity = Vector2(-5 + 10 * randf() * 10, -300)
		new_box.get_node("RigidBody2D").angular_velocity = 0.5 + 1 * randf()
		add_child(new_box)

func part_produce(type: Main.BoxType, parttype: Main.RobotPart):
	var part: RobotPart
	var slot: Main.RobotPart
	var producer: Producer

	match parttype:
		Main.RobotPart.HEAD:
			producer = producers.headmaker
			slot = Main.RobotPart.HEAD
			part = head.instantiate()

		Main.RobotPart.ARM:
			producer = producers.armmaker
			slot = Main.RobotPart.ARM
			part = arm.instantiate()

		Main.RobotPart.LEG:
			producer = producers.legmaker
			slot = Main.RobotPart.LEG
			part = leg.instantiate()

		_:
			assert(false)

	producer.start()
	producer.payload = func():
		part.init(type, slot)
		part.position = producer.node.position + Vector2(producer.node.size.x/2, -20)
		part.get_node("RigidBody2D").linear_velocity = Vector2(-5 + 10 * randf() * 10, -300)
		part.get_node("RigidBody2D").angular_velocity = 0.5 + 1 * randf()
		add_child(part)

func _on_area_2d_body_entered(body):
	var obj = body.get_owner()
	if obj is ChuteBox or obj is RobotPart:
		if obj == grabbed_box:
			grabbed_box = null
		if obj == grabbed_part:
			grabbed_part = null
		obj.queue_free()
