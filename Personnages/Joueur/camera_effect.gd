extends Camera3D

# Paramètres de zoom
@export var zoom_speed = 12.0
@export var max_zoom = 15.0
@export var min_fov = 5.0
@export var max_fov = 70.0

# Variables internes
var original_fov
var current_zoom = 1.0
var zoom_input = 0.0
var original_position
var pixels_per_zoom = 100 # Approximation pour l'affichage en pixels

func _ready():
	# Stocker le FOV original et la position
	original_fov = fov
	original_position = position

func _process(delta):
	# Gérer le zoom
	handle_zoom(delta)

	# Ajouter un léger mouvement statique pour simuler une caméra à main
	add_subtle_movement()

func _input(event):
	# Contrôle du zoom uniquement avec la molette de la souris
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_input = 2.0 # Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_input = -2.0 # Zoom out

func handle_zoom(delta):
	# Appliquer le zoom d'après l'input
	if zoom_input != 0:
		var new_zoom = current_zoom + zoom_input * zoom_speed * delta
		current_zoom = clamp(new_zoom, 1.0, max_zoom)

		# CORRECTION: Convertir le niveau de zoom en FOV (zoom plus grand = FOV plus petit)
		# Quand on zoome, le FOV doit DIMINUER (pas augmenter)
		fov = max_fov - (current_zoom - 1.0) * ((max_fov - min_fov) / (max_zoom - 1.0))

		# Réinitialiser l'input après l'avoir appliqué
		zoom_input = 0.0

		# Quand on zoom, faire varier légèrement la position pour donner un effet de recadrage
		if zoom_input > 0:
			position = original_position + Vector3(randf_range(-0.002, 0.002), randf_range(-0.002, 0.002), 0)

func add_subtle_movement():
	# Léger mouvement aléatoire très subtil (comme une caméra à main)
	if randf() < 0.05: # 5% de chance par frame
		position = original_position + Vector3(
			randf_range(-0.003, 0.003),
			randf_range(-0.003, 0.003),
			0
		)
	else:
		# Retour progressif à la position d'origine
		position = position.lerp(original_position, 0.1)

# Fonction pour obtenir le zoom en pixels (approximatif)
func get_zoom_pixels():
	return int(current_zoom * pixels_per_zoom)
