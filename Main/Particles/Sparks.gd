extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$SawbladeSound.pitch_scale = 0.9 + 0.2 * randf()
	$SawbladeSound.play()
	$GPUParticles2D.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $GPUParticles2D.emitting == false and $SawbladeSound.playing == false:
		queue_free()
