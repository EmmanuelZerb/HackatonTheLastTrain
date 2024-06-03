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
@export var final_object: bool = false

@onready var final_camera = %Final_Camera
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

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
		if final_object:
			body.Play_Feedback_Sound()
			body.hide()
			final_camera.make_current()
			AudioPlayer3D.stream_paused = true
			body.BackgroundSoundPlayer.stream_paused = true
			fade_to_black()
		else:
			if Prochain_Objet_A_Activer:
				Prochain_Objet_A_Activer.activated = true
				Prochain_Objet_A_Activer.set_visibility(true)
				Prochain_Objet_A_Activer.play_random_sound()
				body.Play_Feedback_Sound()
			queue_free()

func _on_audio_stream_player_3d_finished():
	AudioPlayer3D.play()

func fade_to_black():
	var tween = get_tree().create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 6.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
