extends Node

var camera = null
var shake_intensity = 0.0
var shake_duration = 0.0
var shake_timer = 0.0
var original_position = Vector3.ZERO

func _ready():
	camera = get_parent()
	if camera:
		original_position = camera.position

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta

		# Calculer l'intensité restante
		var current_intensity = shake_intensity * (shake_timer / shake_duration)

		# Appliquer un mouvement aléatoire à la caméra
		if camera:
			var random_offset = Vector3(
				randf_range(-1, 1) * current_intensity,
				randf_range(-1, 1) * current_intensity,
				0
			)
			camera.position = original_position + random_offset

		# Si le temps est écoulé, revenir à la position d'origine
		if shake_timer <= 0:
			if camera:
				camera.position = original_position

func start(intensity, duration):
	if camera:
		original_position = camera.position

	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
