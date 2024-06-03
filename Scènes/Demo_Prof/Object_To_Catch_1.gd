extends Area3D

@onready var AudioPlayer3D: AudioStreamPlayer3D = $AudioStreamPlayer3D


var PulseSounds = [
	"res://Ne pas toucher/Sons/SFX_BOUCLES/OBJET_LOOP_1.wav",
	"res://Ne pas toucher/Sons/SFX_BOUCLES/OBJET_LOOP_2.wav",
	"res://Ne pas toucher/Sons/SFX_BOUCLES/OBJET_LOOP_3.wav",
	"res://Ne pas toucher/Sons/SFX_BOUCLES/OBJET_LOOP_4.wav"
]

@export var activated: bool = false
@export var Prochain_Objet_A_Activer: Node
@export var final_object:bool = false

func _ready():
	set_visibility(activated)
	if activated:
		play_random_sound()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	pass

func set_visibility(is_visible):
	if is_visible:
		self.show()
	else:
		self.hide()

func play_random_sound():
	var random_index = randi() % PulseSounds.size()
	AudioPlayer3D.stream = load(PulseSounds[random_index])
	AudioPlayer3D.play()

func _on_body_entered(body):
	if body.name == "JoueurDemo":
		if Prochain_Objet_A_Activer:
			Prochain_Objet_A_Activer.activated = true
			Prochain_Objet_A_Activer.set_visibility(true)
			Prochain_Objet_A_Activer.play_random_sound()
			body.Play_Feedback_Sound()
		queue_free()


func _on_audio_stream_player_3d_finished():
	AudioPlayer3D.play()
