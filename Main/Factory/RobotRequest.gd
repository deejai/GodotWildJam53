extends Node2D

class_name RobotRequest

var type: Main.BoxType = Main.BoxType.BLANK

var parts = {
	head = false,
	leftarm = false,
	rightarm = false,
	leftleg = false,
	rightleg = false
}

# Called when the node enters the scene tree for the first time.
func _ready():
	parts[["leftarm", "rightarm", "head"][randi() % 3]] = true
	parts[["leftleg", "rightleg", "head"][randi() % 3]] = true
	update_visuals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(type: Main.BoxType):
	self.type = type
	for part in $Parts.get_children():
		part.frame = type

func submit_part(part: RobotPart):
	match part.slot:
		Main.RobotPart.HEAD:
			if parts.head == false:
				parts.head = true
			else:
				return false
		Main.RobotPart.ARM:
			if parts.leftarm == false:
				parts.leftarm = true
			elif parts.rightarm == false:
				parts.rightarm = true
			else:
				return false
		Main.RobotPart.LEG:
			if parts.leftleg == false:
				parts.leftleg = true
			elif parts.rightleg == false:
				parts.rightleg = true
			else:
				return false
		_:
			assert(false)

	update_visuals()

	return true

func update_visuals():
	if parts.head:
		$Parts/Head.visible = true

	if parts.leftarm:
		$Parts/LeftArm.visible = true

	if parts.rightarm:
		$Parts/RightArm.visible = true

	if parts.leftleg:
		$Parts/LeftLeg.visible = true

	if parts.rightleg:
		$Parts/RightLeg.visible = true

func complete():
	for key in parts:
		if parts[key] == false:
			return false
			
	return true
