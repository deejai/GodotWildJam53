extends "res://Main/Factory/GrabbableBody/GrabbableBody.gd"

@export var color: Main.ColorType
@export var slot: Main.RobotPartSlot = Main.RobotPartSlot.BODY

func init(color: Main.ColorType):
	self.color = color
	$Sprite2D.frame = color
