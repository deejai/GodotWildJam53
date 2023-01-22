extends Node

var newgame = preload("res://Main/Factory/Factory.tscn")


func _ready() -> void:
	$UI/OptionPanel.hide()
	$UI/CreditsPanel.hide()
	$MenuTheme.play()


func _on_btn_newgame_pressed() -> void:
	get_tree().change_scene_to_packed(newgame)


func _on_btn_options_pressed() -> void:
	$UI/OptionPanel.show()


func _on_btn_credits_pressed() -> void:
	$UI/CreditsPanel.show()


func _on_btn_quit_pressed() -> void:
	get_tree().quit()


func _on_btn_music_dec_pressed() -> void:
	pass # Replace with function body.


func _on_btn_music_inc_pressed() -> void:
	pass # Replace with function body.


func _on_btn_sfx_dec_pressed() -> void:
	pass # Replace with function body.


func _on_btn_sfx_inc_pressed() -> void:
	pass # Replace with function body.


func _on_btn_fullscreen_off_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_btn_fullscreen_on_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_btn_back_pressed() -> void:
	$UI/OptionPanel.hide()


func _on_credits_btn_back_pressed() -> void:
	$UI/CreditsPanel.hide()
