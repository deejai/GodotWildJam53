extends Node

class_name RobotPart

var type: Main.BoxType = Main.BoxType.BLANK
var slot: Main.RobotPart = Main.RobotPart.BODY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(type: Main.BoxType, slot: Main.RobotPart):
	self.type = type
	self.slot = slot
	$RigidBody2D/Sprite.frame = type

func enable_gravity():
	$RigidBody2D.gravity_scale = 1

func disable_gravity():
	$RigidBody2D.gravity_scale = 0
