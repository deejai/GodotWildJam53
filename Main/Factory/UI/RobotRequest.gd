class_name RobotRequest
extends Node2D

signal placed_slot
signal complete

var color: Main.ColorType = Main.ColorType.BLANK

var parts = {
	head = false,
	body = true,
	leftarm = false,
	rightarm = false,
	leftleg = false,
	rightleg = false
}

func _ready():
	reset()
	update_visuals()


func init(color: Main.ColorType):
	self.color = color
	for part in $Parts.get_children():
		part.frame = color


func reset() -> void:
	parts = {
		head = false,
		body = true,
		leftarm = false,
		rightarm = false,
		leftleg = false,
		rightleg = false
	}
	parts[["leftarm", "rightarm", "head"][randi() % 3]] = true
	parts[["leftleg", "rightleg", "head"][randi() % 3]] = true
	update_visuals()


func submit_part(part):
	match part.slot:
		Main.RobotPartSlot.HEAD:
			if parts.head == false:
				parts.head = true
			else:
				return false
		Main.RobotPartSlot.ARM:
			if parts.leftarm == false:
				parts.leftarm = true
			elif parts.rightarm == false:
				parts.rightarm = true
			else:
				return false
		Main.RobotPartSlot.LEG:
			if parts.leftleg == false:
				parts.leftleg = true
			elif parts.rightleg == false:
				parts.rightleg = true
			else:
				return false
		Main.RobotPartSlot.BODY:
			if parts.body == false:
				parts.body = true
			else:
				return false
		_:
			assert(false)
	
	update_visuals()
	
	if is_complete():
		complete.emit()
	
	return true

func update_visuals():
	$Parts/Head.visible = parts.head
	$Parts/Body.visible = parts.body
	$Parts/LeftArm.visible = parts.leftarm
	$Parts/RightArm.visible = parts.rightarm
	$Parts/LeftLeg.visible = parts.leftleg
	$Parts/RightLeg.visible = parts.rightleg


func is_complete():
	for key in parts:
		if parts[key] == false:
			return false
			
	return true


func _on_body_detector_placed(body) -> void:
	if submit_part(body):
		placed_slot.emit()
		body.queue_free()
