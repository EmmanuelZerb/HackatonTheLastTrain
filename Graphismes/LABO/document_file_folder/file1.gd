extends Node3D

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer2") # Assurez-vous du nom exact de votre AnimationPlayer
@onready var interaction_area: Area3D = get_node("InteractionArea") # Assurez-vous du nom exact de votre Area3D
var joueur_est_dans_zone: bool = false

func _ready():
	# Connecter les signaux de l'Area3D
	if is_instance_valid(interaction_area):
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	else:
		printerr("Erreur : Le nœud Area3D 'InteractionArea' n'a pas été trouvé.")

func _process(delta):
	if joueur_est_dans_zone and Input.is_action_just_pressed("play_animation"):
		if is_instance_valid(animation_player) and animation_player.has_animation("Anim"):
			animation_player.play("Anim")
			print("Lancement de l'animation 'Anim'.")
		elif not is_instance_valid(animation_player):
			printerr("Erreur : Le nœud AnimationPlayer n'a pas été trouvé.")
		elif not animation_player.has_animation("Anim"):
			printerr("Erreur : L'animation 'Anim' n'existe pas dans l'AnimationPlayer.")

func _on_body_entered(body: Node3D):
	# Vérifier si le corps entrant est le joueur (en utilisant le nom "Joueur")
	print("ONBODY ENTERED")
	print(get_parent().name)
	#if body.is_in_group("Joueur") :
	joueur_est_dans_zone = true
	print("Joueur est entré dans la zone.")

func _on_body_exited(body: Node3D):
	# Vérifier si le corps sortant est le joueur (en utilisant le nom "Joueur")
	print("ONBODY EXIT")
	#if body.name == "Joueur":
	joueur_est_dans_zone = false
	print("Joueur est sorti de la zone.")
		# Optionnel: Arrêter l'animation quand le joueur quitte la zone
		# if is_instance_valid(animation_player) and animation_player.is_playing():
		#      animation_player.stop()
