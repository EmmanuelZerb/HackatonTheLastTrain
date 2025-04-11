extends CharacterBody3D

const SPEED = 10.0
const ALTITUDE_SMOOTHING_FACTOR = 0.1  # Adjust this value to control the altitude smoothing amount
const ROTATION_SMOOTHING_FACTOR = 0.1  # Adjust this value to control the rotation smoothing amount

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target_altitude = 0.0
var target_rotation = 0.0

var Is_Arduino_Mode_On = true # Variable to switch between arduino control and Mouse/Keyboard controls
const SENSIBILITE = 0.002
const ALTITUDE_CHANGE_SPEED = 0.12

@onready var BackgroundSoundPlayer: AudioStreamPlayer = $BackgroundSoundPlayer

@onready var AudioPlayer1: AudioStreamPlayer = $AudioStreamPlayer1
@onready var AudioPlayer2: AudioStreamPlayer = $AudioStreamPlayer2
@onready var AudioPlayer3: AudioStreamPlayer = $AudioStreamPlayer3

var AudioPlayers = []

var compteur_object_collecte = 0

func _ready():
	randomize()
	AudioPlayers = [AudioPlayer1, AudioPlayer2, AudioPlayer3]
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	%ArduinoModeTimer.timeout.connect(_on_ArduinoModeTimer_timeout)
	%ArduinoModeTimer.start(2.0)

	$FmodEventEmitter3D_ambiance.set_parameter("AmbianceChange", "None")
	$FmodEventEmitter3D_ambiance.play()

func Arduino_Mouvement():
	target_altitude = float(ArduinoManager.ultrasonUn) / 3
	target_rotation = deg_to_rad(ArduinoManager.potentiometreUn / 1.5)

func Play_Feedback_Sound():
	# ancienne méthode :
	#var random_index = randi() % AudioPlayers.size()
	#AudioPlayers[random_index].play()
	# nouvelle méthode :
	$FmodEventEmitter3D_reward.play()
	compteur_object_collecte = compteur_object_collecte + 1
	if (compteur_object_collecte == 1):
		$FmodEventEmitter3D_ambiance.set_parameter("AmbianceChange", "State1")
	elif (compteur_object_collecte == 2):
		$FmodEventEmitter3D_ambiance.set_parameter("AmbianceChange", "State2")
	elif (compteur_object_collecte == 3):
		$FmodEventEmitter3D_ambiance.set_parameter("AmbianceChange", "State3")


func _physics_process(delta):
	# Toggle on and off the "ArduinoMode", indicate-it by text on screen
	if Input.is_action_just_pressed("ArduinoToggle"):
		Is_Arduino_Mode_On = !Is_Arduino_Mode_On
		if Is_Arduino_Mode_On:
			%Menus/Arduino_indicator.text = "Arduino mode on"
			%ArduinoModeTimer.start(2.0) # start a timer to erase the text after 2 seconds
		elif !Is_Arduino_Mode_On:
			%Menus/Arduino_indicator.text = "Arduino mode off"
			%ArduinoModeTimer.start(2.0) # start a timer to erase the text after 2 seconds
	
	# Handles Arduino controlled altitude changes and camera rotation
	if Is_Arduino_Mode_On:
		Arduino_Mouvement()
	
		# Smooth the altitude changes
		var current_altitude = global_position.y
		var smoothed_altitude = lerp(current_altitude, target_altitude, ALTITUDE_SMOOTHING_FACTOR)
		global_position.y = smoothed_altitude
		
		# Smooth the rotation changes
		var current_rotation = rotation.y
		var rotation_difference = fmod(target_rotation - current_rotation, TAU)
		if rotation_difference > PI:
			rotation_difference -= TAU
		var smoothed_rotation = current_rotation + rotation_difference * ROTATION_SMOOTHING_FACTOR
		rotation.y = smoothed_rotation
		
	# Handles non-arduino altitude change
	elif !Is_Arduino_Mode_On:
		if Input.is_action_pressed("Sauter"):
			global_position.y += ALTITUDE_CHANGE_SPEED
		elif Input.is_action_pressed("Courir") and !is_on_floor():
			global_position.y -= ALTITUDE_CHANGE_SPEED
	
	# Auto forward movement in the direction the character is facing
	var forward_direction = -transform.basis.z.normalized()
	velocity.x = forward_direction.x * SPEED
	velocity.z = forward_direction.z * SPEED
	
	move_and_slide()

# Handles non-Arduino camera rotation (with the mouse)
func _input(event):
	if event is InputEventMouseMotion and !Is_Arduino_Mode_On:
		rotate_y(-event.relative.x * SENSIBILITE)

# A function called to erase the text "Arduino mode on/off" on the screen when the timer expire
func _on_ArduinoModeTimer_timeout():
	%Menus/Arduino_indicator.text = ""

# Called to loop the background sound when it's finish to be played
func _on_background_sound_player_finished():
	$BackgroundSoundPlayer.play()
