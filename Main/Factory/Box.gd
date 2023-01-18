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

func snap_to(pos: Vector2):
	$RigidBody2D.snap_pos = pos
	$RigidBody2D.custom_integrator = true
	$RigidBody2D.collision_layer = 2
	$RigidBody2D.collision_mask = 2
	z_index = 20

func unsnap():
	$RigidBody2D.snap_pos = Vector2.INF
	$RigidBody2D.custom_integrator = false
	$RigidBody2D.collision_layer = 1
	$RigidBody2D.collision_mask = 1
	z_index = 25
