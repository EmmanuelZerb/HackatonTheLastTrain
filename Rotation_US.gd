extends Node3D



func _ready():
	print(ArduinoManager.ultrasonUn)
	print(ArduinoManager.boutonTrois)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("bouton 3:")
	print(ArduinoManager.boutonTrois, ArduinoManager.ultrasonUn)
	#get_parent().rotation.y = deg_to_rad(ArduinoManager.ultrasonUn) * 2
	if(ArduinoManager.boutonTrois):
		get_parent().rotation.y = -1.5
	else:
		get_parent().rotation.y = 0
