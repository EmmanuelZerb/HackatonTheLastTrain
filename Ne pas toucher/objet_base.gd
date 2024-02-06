extends Node3D

class_name objet_base

@export_category("Paramêtres objet")

@export var declencher_a_la_mort:Node # A revisiter, peut être que c'est "Node3D"
@export var max_vie:int

var vie:int

func _ready():
	vie = max_vie

func a_la_mort():
	if(declencher_a_la_mort.has_method("trigger")):
		declencher_a_la_mort.declencheur()

func joueur_touche(): # ajouter damage
	vie -= 1
	if (vie <= 0):
		tuer()

func tuer():
	a_la_mort()
	queue_free()
	# et plus
	
func declencheur():
	pass
