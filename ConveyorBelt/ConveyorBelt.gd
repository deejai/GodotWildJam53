extends StaticBody2D

@export var speed:float = 1.0 : set = set_speed
@export var push_strength:float = 25.0

@onready var anim_player:AnimationPlayer = $AnimationPlayer

func _ready():
	speed = speed # Update speed setter


func set_speed(value:float) -> void:
	speed = value
	
	if anim_player:
		anim_player.playback_speed = speed
		constant_linear_velocity.x = push_strength * speed
