extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const ALTITUDE_SMOOTHING_FACTOR = 0.1  # Adjust this value to control the altitude smoothing amount
const ROTATION_SMOOTHING_FACTOR = 0.1  # Adjust this value to control the rotation smoothing amount

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target_altitude = 0.0
var target_rotation = 0.0

@onready var BackgroundSoundPlayer: AudioStreamPlayer = $BackgroundSoundPlayer

@onready var AudioPlayer1: AudioStreamPlayer = $AudioStreamPlayer1
@onready var AudioPlayer2: AudioStreamPlayer = $AudioStreamPlayer2
@onready var AudioPlayer3: AudioStreamPlayer = $AudioStreamPlayer3

var AudioPlayers = []

func _ready():
	randomize()
	AudioPlayers = [AudioPlayer1, AudioPlayer2, AudioPlayer3]

func Arduino_Mouvement():
	target_altitude = float(ArduinoManager.ultrasonUn) / 3
	target_rotation = deg_to_rad(ArduinoManager.potentiometreUn / 1.5)

func Play_Feedback_Sound():
	var random_index = randi() % AudioPlayers.size()
	AudioPlayers[random_index].play()

func _physics_process(delta):
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
	
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Auto forward movement in the direction the character is facing
	var forward_direction = -transform.basis.z.normalized()
	velocity.x = forward_direction.x * SPEED
	velocity.z = forward_direction.z * SPEED
	
	move_and_slide()


func _on_background_sound_player_finished():
	$BackgroundSoundPlayer.play()
