extends Node3D

class_name objet_base

@export_category("Paramêtres objet")

@export var déclencher_a_la_mort1:Node # A revisiter, peut être que c'est "Node3D"
@export var déclencher_a_la_mort2:Node
@export var déclencher_a_la_mort3:Node
@export var max_vie:int

enum Liste_Déclencheurs {
	Retirer_Vie,
	Apparaitre,
	Ouvrir,
	Victoire,
	Défaite,
	Charger_Niveau,
	Aucun
}
@export_enum("Retirer_Vie", "Apparaitre", "Ouvrir", "Victoire", "Défaite", "Charger_Niveau", "Aucun") var Déclencheur := 0
@export var Vie_Perdu_Par_Déclencheur: int = 0
@export var Son_Joué_Par_Déclencheur:AudioStream = null
# time for door opening
@export var Prochain_Niveau:PackedScene = null
@export var Menu_Victoire:PackedScene = null
@export var Menu_Défaite:PackedScene = null

var Dégât_au_contact_du_joueur = null
var FX_mort = null 

var vie:int

func _ready():
	vie = max_vie

func a_la_mort():
	if déclencher_a_la_mort1 != null:
		if(déclencher_a_la_mort1.has_method("déclencheur")):
			déclencher_a_la_mort1.déclencheur()
	if déclencher_a_la_mort2 != null:
		if(déclencher_a_la_mort2.has_method("déclencheur")):
			déclencher_a_la_mort2.déclencheur()
	if déclencher_a_la_mort3 != null:
		if(déclencher_a_la_mort3.has_method("déclencheur")):
			déclencher_a_la_mort3.déclencheur()
	if FX_mort != null:
		print("FX_mort PAS NULL")
		FX_mort.jouer_son_et_fx()

func joueur_touche(): # ajouter damage
	if Dégât_au_contact_du_joueur != null:
		print("joueur_touche et Dégât_au_contact_du_joueur pas null")
		vie -= Dégât_au_contact_du_joueur.Nombre_Dégats
		if (vie <= 0):
			tuer()

func tuer():
	a_la_mort()
	queue_free()
	# et plus

func déclencheur():
	match Déclencheur:
		Liste_Déclencheurs.Retirer_Vie:
			vie -= Vie_Perdu_Par_Déclencheur
			if (vie <= 0): tuer()
		Liste_Déclencheurs.Apparaitre:
			self.show()
		Liste_Déclencheurs.Ouvrir:
			var tween := create_tween()
			tween.tween_property(self, "rotation:y", deg_to_rad(90), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		Liste_Déclencheurs.Victoire:
			if Menu_Victoire != null:
				#%Menus.add_child(Menu_Victoire.instantiate())
				#%Menu_Victoire.show()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				print("Victoire !")
				get_tree().paused = true
		Liste_Déclencheurs.Défaite:
			if Menu_Défaite != null:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				print("Défaite !")
				get_tree().paused = true
		Liste_Déclencheurs.Charger_Niveau:
			if Prochain_Niveau != null:
				get_tree().change_scene_to_packed(Prochain_Niveau)
		Liste_Déclencheurs.Aucun:
			pass

	if Son_Joué_Par_Déclencheur != null && %General_Manager != null:
		%General_Manager.Joue_Un_Son(Son_Joué_Par_Déclencheur, self.position)
