extends Node3D

func _ready() -> void:
	# Référence à votre émetteur FMOD 3D
	var sound_emitter = $Sketchfab_Scene28/FmodEventEmitter3D
	
	# Lancer le son après 5 secondes
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 10.0
	timer.one_shot = true
	timer.timeout.connect(_on_audio_timer_timeout)
	timer.start()

func _on_audio_timer_timeout() -> void:
	$Sketchfab_Scene28/FmodEventEmitter3D.play()
