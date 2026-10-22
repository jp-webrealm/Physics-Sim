extends Node2D

var paused = true;

func _ready() -> void:
	get_tree().paused = true

func _on_start_button_button_up() -> void:
	get_tree().paused = !paused
	paused = !paused
 
