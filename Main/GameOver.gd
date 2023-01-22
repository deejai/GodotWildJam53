extends Node2D

@onready var factory_scene = load("res://Main/Factory/Factory.tscn")
@onready var mainmenu_scene = load("res://Main/MainMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$ProfitReportLabel.text = $ProfitReportLabel.text.replace("__AMOUNT__", str("$", Main.profits))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_packed(mainmenu_scene)


func _on_restart_button_pressed():
	get_tree().change_scene_to_packed(factory_scene)
