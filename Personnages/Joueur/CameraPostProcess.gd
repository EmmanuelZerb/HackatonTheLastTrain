extends Node
# Ce script nécessite un nœud ColorRect avec un matériau shader
@onready var post_process_rect = $ColorRect

# Paramètres d'effet
@export var noise_amount = 0.03
@export var scratches_amount = 0.02
@export var vignette_intensity = 0.3
@export var color_aberration = 0.5
@export var enable_effects = true

func _ready():
	# S'assurer que le shader existe
	if not post_process_rect or not post_process_rect.material:
		push_error("Le shader de post-processing n'est pas configuré correctement")
		return
	# Initialiser les paramètres du shader
	update_shader_parameters()

func _process(delta):
	if not enable_effects or not post_process_rect or not post_process_rect.material:
		return
	# Ajouter un bruit aléatoire qui change légèrement au fil du temps
	post_process_rect.material.set_shader_parameter("noise_offset",
		Vector2(randf(), randf()) * noise_amount)

func update_shader_parameters():
	if not post_process_rect or not post_process_rect.material:
		return
	post_process_rect.material.set_shader_parameter("noise_amount", noise_amount)
	post_process_rect.material.set_shader_parameter("scratches_amount", scratches_amount)
	post_process_rect.material.set_shader_parameter("vignette_intensity", vignette_intensity)
	post_process_rect.material.set_shader_parameter("color_aberration", color_aberration)

# Vous pouvez ajouter ces méthodes pour modifier les effets en temps réel
func set_noise_amount(amount):
	noise_amount = amount
	update_shader_parameters()

func set_scratches_amount(amount):
	scratches_amount = amount
	update_shader_parameters()

func set_vignette_intensity(amount):
	vignette_intensity = amount
	update_shader_parameters()

func set_color_aberration(amount):
	color_aberration = amount
	update_shader_parameters()

func toggle_effects():
	enable_effects = !enable_effects
	post_process_rect.visible = enable_effects
