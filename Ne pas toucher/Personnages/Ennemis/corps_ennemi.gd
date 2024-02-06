extends CharacterBody3D


const SPEED = 4.0

@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D

func _process(delta):
	velocity = Vector3.ZERO
	
	# Navigation
	nav_agent.set_target_position(g_vars.joueur.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	
	look_at(Vector3(g_vars.joueur.global_position.x, global_position.y, g_vars.joueur.global_position.z), Vector3.UP)
	move_and_slide()
