extends Node

signal gyro_data_received(x_rotation, y_rotation)

# Variables pour simuler le gyroscope
var simulation_enabled = true
var simulation_timer = 0
var simulation_interval = 0.1
var noise_amplitude = 0.02

func _ready():
	print("Mode simulation pour le gyroscope")

func _process(delta):
	if simulation_enabled:
		simulation_timer += delta
		if simulation_timer >= simulation_interval:
			simulation_timer = 0

			# Générer des valeurs aléatoires pour simuler un léger mouvement
			var x = randf_range(-noise_amplitude, noise_amplitude)
			var y = randf_range(-noise_amplitude, noise_amplitude)

			# Envoyer les données simulées
			emit_signal("gyro_data_received", x, y)

			# Transmettre au joueur si possible
			var player = get_parent()
			if player and player.has_method("process_gyro_data"):
				player.process_gyro_data(x, y)

# Pour l'intégration future avec l'Arduino réel
func start_real_connection(port_name = "COM3", baud_rate = 115200):
	simulation_enabled = false
	print("Pour utiliser l'Arduino réel, veuillez installer l'addon godot-serial")
	print("Port série: " + port_name + ", Baud rate: " + str(baud_rate))
