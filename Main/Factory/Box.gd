extends Node2D

class_name ChuteBox

var type: Main.BoxType = Main.BoxType.BLANK

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func init(type: Main.BoxType):
	self.type = type
	$RigidBody2D/Sprite.frame = type

func enable_gravity():
	$RigidBody2D.gravity_scale = 1

func disable_gravity():
	$RigidBody2D.gravity_scale = 0
