extends Area2D

signal placed(body)


func insert_body(body) -> void:
	placed.emit(body)
