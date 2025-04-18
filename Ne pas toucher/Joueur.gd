extends CharacterBody3D

# Paramètres du joueur
@export var speed = 5.0
@export var jump_strength = 6.0
@export var sensitivity = 0.002

# Paramètres gyroscope
@export var use_gyroscope = true  
@export var gyro_sensitivity = 0.25  # Sensibilité augmentée (0.1 → 0.25)
@export var gyro_invert_x = true  # Axe X inversé par défaut
@export var gyro_invert_y = true  # Axe Y inversé par défaut
@export var gyro_limit = 10.0  # Limiter les valeurs du gyroscope entre -10 et 10
@export var gyro_threshold = 0.3  # Seuil réduit pour détecter plus facilement les mouvements

# Paramètres Arduino
@export var use_arduino = true
@export var arduino_deadzone = 50  # Zone morte du joystick augmentée
@export var joystick_threshold = 0.15  # Seuil minimum pour les valeurs normalisées

# Paramètres caméra
@export var min_fov = 10.0  # FOV minimum (zoom max)
@export var max_fov = 120.0  # FOV maximum (zoom min)
@export var max_pitch_angle = 1.5  # Angle maximal de rotation verticale (plus grand pour regarder plus loin)

# Paramètre simple pour le son de pas
@export var footstep_interval = 0.4  # Temps entre chaque pas (secondes)

# Références aux nœuds
@onready var head = $Tête
@onready var camera = $Tête/Camera3D
@onready var arduino_manager = null
@onready var fmod_emitter = $FmodEventEmitter3D  # Référence à l'émetteur FMOD existant

# Variables pour la rotation de la caméra
var total_pitch = 0.0
var total_yaw = 0.0
var total_roll = 0.0
var target_fov = 75.0  # FOV par défaut

# Variables d'état
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var debug_timer = 0.0
var connection_error = false
var previous_button_state = 0

# Valeurs du joystick pour le débogage
var last_joy_x = 512
var last_joy_y = 512
var joy_moving = false

# Variables pour le gyroscope relatif
var prev_gyro_x = 0.0
var prev_gyro_y = 0.0
var gyro_delta_x = 0.0
var gyro_delta_y = 0.0
var gyro_ignore_frames = 5  # Ignorer les premières lectures pour stabiliser
var gyro_frame_count = 0

# Variable pour le son de pas
var footstep_timer = 0.0

# Obtenir une référence à l'autoload Arduino_Manager
func _ready():
	# Capture la souris
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	print("Joueur initialisé - recherche Arduino Manager...")
	
	# Méthode 1: recherche directe
	arduino_manager = get_node_or_null("/root/Arduino_Manager")
	
	# Méthode 2: recherche avec variantes de nom
	if arduino_manager == null:
		var possible_paths = [
			"/root/ArduinoManager", 
			"/root/arduinomanager", 
			"/root/Arduino_Manager"
		]
		
		for path in possible_paths:
			var node = get_node_or_null(path)
			if node != null:
				arduino_manager = node
				print("Arduino Manager trouvé à: ", path)
				break
	
	# Vérifier si l'Arduino Manager a été trouvé
	if arduino_manager != null:
		print("Arduino Manager trouvé! Vérification...")
		if arduino_manager.has_method("IsActive"):
			var is_active = arduino_manager.IsActive()
			print("Arduino Manager est actif: ", is_active)
			connection_error = false
		else:
			print("AVERTISSEMENT: Arduino Manager trouvé mais méthode IsActive manquante!")
			connection_error = true
	else:
		connection_error = true
		print("ERREUR: Arduino Manager NON trouvé!")
		
		# Afficher les nœuds disponibles au niveau root
		var root = get_tree().get_root()
		print("=== Nœuds disponibles dans root: ===")
		for i in range(root.get_child_count()):
			print("- ", root.get_child(i).name)
		print("===================================")

func _input(event):
	# Appuyer sur G pour basculer entre souris et gyroscope
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		use_gyroscope = !use_gyroscope
		print("Gyroscope: ", "activé" if use_gyroscope else "désactivé")
		
		# Réinitialiser les variables du gyroscope lors de l'activation
		if use_gyroscope:
			reset_gyro_values()
		
	# Appuyer sur X pour inverser l'axe X du gyroscope
	if event is InputEventKey and event.pressed and event.keycode == KEY_X:
		gyro_invert_x = !gyro_invert_x
		print("Gyroscope axe X inversé: ", gyro_invert_x)
		
	# Appuyer sur Y pour inverser l'axe Y du gyroscope
	if event is InputEventKey and event.pressed and event.keycode == KEY_Y:
		gyro_invert_y = !gyro_invert_y
		print("Gyroscope axe Y inversé: ", gyro_invert_y)
		
	# Touches pour ajuster la sensibilité du gyroscope
	if event is InputEventKey and event.pressed and event.keycode == KEY_BRACKETRIGHT: # Touche ]
		gyro_sensitivity += 0.05
		print("Sensibilité gyroscope augmentée: ", gyro_sensitivity)
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_BRACKETLEFT: # Touche [
		gyro_sensitivity = max(0.05, gyro_sensitivity - 0.05)
		print("Sensibilité gyroscope diminuée: ", gyro_sensitivity)
		
	# Touches + et - pour ajuster la zone morte du joystick
	if event is InputEventKey and event.pressed and event.keycode == KEY_EQUAL: # Touche +
		arduino_deadzone += 10
		print("Zone morte joystick augmentée: ", arduino_deadzone)
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_MINUS: # Touche -
		arduino_deadzone = max(10, arduino_deadzone - 10)
		print("Zone morte joystick diminuée: ", arduino_deadzone)

	# Gestion de l'entrée de la souris pour la caméra (seulement si gyroscope désactivé)
	if not use_gyroscope and event is InputEventMouseMotion:
		# Rotation horizontale (yaw)
		total_yaw -= event.relative.x * sensitivity
		
		# Rotation verticale (pitch)
		total_pitch -= event.relative.y * sensitivity

	# Réinitialiser la rotation avec la touche R
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		reset_camera_orientation()
		
	# Appuyer sur Échap pour libérer le curseur
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	# Touche A pour basculer le mode Arduino
	if event is InputEventKey and event.pressed and event.keycode == KEY_A:
		use_arduino = !use_arduino
		print("Mode Arduino: ", "activé" if use_arduino else "désactivé")

# Réinitialiser les variables du gyroscope
func reset_gyro_values():
	prev_gyro_x = 0.0
	prev_gyro_y = 0.0
	gyro_delta_x = 0.0
	gyro_delta_y = 0.0
	gyro_frame_count = 0
	print("Valeurs du gyroscope réinitialisées")

# Réinitialiser l'orientation de la caméra
func reset_camera_orientation():
	total_pitch = 0.0
	total_yaw = 0.0
	total_roll = 0.0
	reset_gyro_values()
	print("Orientation de la caméra réinitialisée")

func _process(delta):
	debug_timer += delta
	
	# Gestion de la reconnexion périodique
	if debug_timer > 3.0:
		debug_timer = 0.0
		
		# Si on n'a pas trouvé l'Arduino Manager, essayer à nouveau
		if arduino_manager == null:
			arduino_manager = get_node_or_null("/root/Arduino_Manager")
			if arduino_manager == null:
				arduino_manager = get_node_or_null("/root/ArduinoManager")
			
			if arduino_manager != null:
				print("Arduino Manager retrouvé!")
				connection_error = false
				reset_gyro_values()
				
		# Afficher les valeurs du joystick pour débogage périodique
		if arduino_manager != null and joy_moving:
			print("Joystick - X:", last_joy_x, " Y:", last_joy_y, " (zone morte:", arduino_deadzone, ")")
	
	# *** GESTION DU GYROSCOPE EN MODE RELATIF ***
	if use_arduino and use_gyroscope and arduino_manager != null:
		# Récupérer les valeurs actuelles du gyroscope
		var current_gyro_x = arduino_manager.GetGyroX()
		var current_gyro_y = arduino_manager.GetGyroY()
		
		# Limiter les valeurs brutes entre -gyro_limit et gyro_limit
		current_gyro_x = clamp(current_gyro_x, -gyro_limit, gyro_limit)
		current_gyro_y = clamp(current_gyro_y, -gyro_limit, gyro_limit)
		
		# Pendant les premières frames, initialiser les valeurs de référence
		if gyro_frame_count < gyro_ignore_frames:
			prev_gyro_x = current_gyro_x
			prev_gyro_y = current_gyro_y
			gyro_frame_count += 1
			return
		
		# Calculer le changement relatif depuis la dernière frame
		gyro_delta_x = current_gyro_x - prev_gyro_x
		gyro_delta_y = current_gyro_y - prev_gyro_y
		
		# Mettre à jour les valeurs précédentes pour la prochaine frame
		prev_gyro_x = current_gyro_x
		prev_gyro_y = current_gyro_y
		
		# Ignorer les petits changements (tremblements)
		if abs(gyro_delta_x) < gyro_threshold:
			gyro_delta_x = 0
		if abs(gyro_delta_y) < gyro_threshold:
			gyro_delta_y = 0
		
		# Application avec inversion si nécessaire (maintenant activée par défaut)
		if gyro_invert_x:
			gyro_delta_x = -gyro_delta_x
		if gyro_invert_y:
			gyro_delta_y = -gyro_delta_y
		
		# ÉCHANGE DES AXES: Utiliser gyro_y pour la rotation horizontale et gyro_x pour la verticale
		if abs(gyro_delta_x) > 0 or abs(gyro_delta_y) > 0:
			# Rotation horizontale (yaw) - maintenant contrôlée par gyro_y
			total_yaw -= gyro_delta_y * gyro_sensitivity
			
			# Rotation verticale (pitch) - maintenant contrôlée par gyro_x
			total_pitch -= gyro_delta_x * gyro_sensitivity
			
			# Afficher les deltas pour le débogage
			if debug_timer < 0.05:
				print("Mouvement gyro - Delta X:", gyro_delta_x, " Delta Y:", gyro_delta_y)
	
	# *** GESTION DU ZOOM ***
	if use_arduino and arduino_manager != null:
		# Récupérer la valeur de zoom
		var zoom_value = arduino_manager.GetZoom()
		
		# Adaptation spécifique à la plage du capteur (29 à 990)
		if zoom_value >= 29 and zoom_value <= 990:
			# Normaliser la valeur sur la plage spécifique du capteur
			# 29 = zoom minimum, 990 = zoom maximum
			var normalized_zoom = (zoom_value - 29) / float(990 - 29)
			
			# Mappage direct de la valeur normalisée au FOVV
			# 0.0 = FOV maximum (zoom min), 1.0 = FOV minimum (zoom max)
			target_fov = min_fov + ((1.0 - normalized_zoom) * (max_fov - min_fov))
			
			# Application directe sans lissage pour un effet immédiat
			camera.fov = target_fov
	
	# Appliquer les rotations à la caméra avec des limites étendues
	head.rotation.x = clamp(total_pitch, -max_pitch_angle, max_pitch_angle)  # Limiter la rotation verticale
	rotation.y = wrapf(total_yaw, -PI, PI)  # Garder la rotation horizontale dans une plage raisonnable

func _physics_process(delta):
	# Ajout de la gravité
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Gestion du saut
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_strength
	
	# *** GESTION DU BOUTON D'INTERACTION ***
	if use_arduino and arduino_manager != null:
		var current_button = arduino_manager.GetButtonPress()
		
		# Détecter le front montant (moment où le bouton est pressé)
		if current_button == 1 and previous_button_state == 0:
			print("Bouton d'interaction Arduino pressé!")
			interact_with_world()
		
		previous_button_state = current_button

	# Variables pour le mouvement
	var input_dir = Vector2.ZERO
	joy_moving = false
	
	# *** GESTION DU JOYSTICK ***
	if use_arduino and arduino_manager != null:
		# Utiliser directement les valeurs du joystick de l'Arduino
		var joy_x = arduino_manager.GetJoyX()
		var joy_y = arduino_manager.GetJoyY()
		
		# Stocker pour le débogage
		last_joy_x = joy_x
		last_joy_y = joy_y
		
		# Appliquer une zone morte et normaliser les valeurs
		# CORRECTION: Mapping des directions pour correspondre à l'orientation physique du stick
		if abs(joy_x - 512) > arduino_deadzone:
			var normalized_x = (joy_x - 512) / 512.0
			
			# Appliquer un seuil minimum pour éviter les petits mouvements involontaires
			if abs(normalized_x) > joystick_threshold:
				input_dir.y = normalized_x * 1.5  # Stick X contrôle le mouvement avant/arrière
				joy_moving = true
		
		if abs(joy_y - 512) > arduino_deadzone:
			var normalized_y = (joy_y - 512) / 512.0
			
			# Appliquer un seuil minimum pour éviter les petits mouvements involontaires
			if abs(normalized_y) > joystick_threshold:
				input_dir.x = -normalized_y * 1.5  # Stick Y contrôle le mouvement gauche/droite
				joy_moving = true
	
	# Vérification supplémentaire: si les valeurs sont trop petites, arrêter le mouvement
	if abs(input_dir.x) < 0.1:
		input_dir.x = 0
	if abs(input_dir.y) < 0.1:
		input_dir.y = 0
				
	# Mode clavier (toujours actif même avec Arduino)
	if Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x -= 1

	# APPLICATION DU MOUVEMENT
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# SIMPLE GESTION DES PAS: Si on bouge et on est au sol
		if is_on_floor():
			footstep_timer += delta
			if footstep_timer >= footstep_interval:
				# Jouer le son de pas
				if fmod_emitter:
					fmod_emitter.play()
				footstep_timer = 0.0	
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

# Fonction d'interaction avec le monde
func interact_with_world():
	# Vérifier s'il y a quelque chose devant le joueur avec un raycast
	var space_state = get_world_3d().direct_space_state
	var camera_global_position = camera.global_position
	
	# Calculer la direction en avant depuis la caméra
	var ray_direction = -camera.global_transform.basis.z.normalized() * 2.0
	
	# Créer un query pour le raycast
	var query = PhysicsRayQueryParameters3D.create(camera_global_position, 
											  camera_global_position + ray_direction)
	
	# Effectuer le raycast
	var result = space_state.intersect_ray(query)
	
	if result:
		print("Interaction avec: ", result.collider.name)
		# Vérifier si l'objet peut interagir
		if result.collider.has_method("interact"):
			result.collider.interact(self)
		else:
			print("Cet objet n'a pas de méthode d'interaction.")
