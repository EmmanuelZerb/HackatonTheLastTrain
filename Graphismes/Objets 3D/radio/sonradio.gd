extends Node3D

func _ready() -> void:
	# Référence à votre émetteur FMOD 3D
	var sound_emitter = $Sketchfab_Scene28/FmodEventEmitter3D
	
	# Augmenter la portée du son
	# Si disponible dans FMOD, vous pourriez aussi ajuster le volume
	sound_emitter.set_parameter("Volume", 2.0)  # Doubler le volume
	
	# Lancer le son après 5 secondes
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(_on_audio_timer_timeout)
	timer.start()

func _on_audio_timer_timeout() -> void:
	$Sketchfab_Scene28/FmodEventEmitter3D.play()
