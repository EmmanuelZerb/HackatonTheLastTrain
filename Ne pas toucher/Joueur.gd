extends CharacterBody3D

# Paramètres du joueur
@export var speed = 5.0
@export var jump_strength = 6.0
@export var sensitivity = 0.002

# Paramètres gyroscope
@export var use_gyroscope = false
@export var gyro_sensitivity = 0.5

# Références aux nœuds
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var serial_connection = $SerialConnection

# Variables d'état
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Capture la souris
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Joueur initialisé")

	# Connecter le signal de SerialConnection si disponible
	if serial_connection and serial_connection.has_signal("gyro_data_received"):
		serial_connection.connect("gyro_data_received", Callable(self, "process_gyro_data"))

func _input(event):
	# Appuyer sur G pour basculer entre souris et gyroscope
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		use_gyroscope = !use_gyroscope
		print("Gyroscope: ", "activé" if use_gyroscope else "désactivé")

	# Gestion de l'entrée de la souris pour la caméra (seulement si gyroscope désactivé)
	if not use_gyroscope and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		if head:
			head.rotate_x(-event.relative.y * sensitivity)
			head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

	# Appuyer sur Échap pour libérer le curseur
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Cette fonction sera appelée par SerialConnection quand disponible
func process_gyro_data(x_rotation, y_rotation):
	if use_gyroscope:
		rotate_y(-x_rotation * gyro_sensitivity)
		if head:
			head.rotate_x(-y_rotation * gyro_sensitivity)
			head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	# Ajout de la gravité
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Gestion du saut
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_strength

	# Gestion des entrées de mouvement pour clavier AZERTY (ZQSD)
	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x -= 1

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
