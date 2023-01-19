extends Node2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D


func activate() -> void:
	gpu_particles_2d.emitting = true


func deactivate() -> void:
	gpu_particles_2d.emitting = false
