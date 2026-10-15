extends Node2D


func _ready() -> void:
	get_tree().paused = true

func _on_start_button_button_up() -> void:
	get_tree().paused = false
 
