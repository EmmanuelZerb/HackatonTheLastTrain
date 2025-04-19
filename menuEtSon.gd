extends CanvasLayer

func _ready() -> void:
	$FmodEventEmitter2D.set_parameter("IntroLoop", "Intro")
	$FmodEventEmitter2D.play()
	
	$Control/MarginContainer/VBoxContainer/LancerJeu.pressed.connect(_on_LancerJeu_pressed)
	$Control/MarginContainer/VBoxContainer/QuitterJeu.pressed.connect(_on_QuitterJeu_pressed)

# Fonction appelée quand le bouton LancerJeu est pressé
func _on_LancerJeu_pressed() -> void:
	# Charger et changer pour la scène du jeu
	get_tree().change_scene_to_file("res://LastStrain.tscn")

# Fonction appelée quand le bouton QuitterJeu est pressé
func _on_QuitterJeu_pressed() -> void:
	# Quitter le jeu
	get_tree().quit()
