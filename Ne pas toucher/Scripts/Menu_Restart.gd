extends Control

@export var Scène_A_Lancer:PackedScene = null


func _on_button_pressed():
	if Scène_A_Lancer != null:
		get_tree().paused = false
		get_tree().change_scene_to_packed(Scène_A_Lancer)
