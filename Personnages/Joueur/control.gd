extends Control

# Références aux nœuds
var time_label
var red_square
var zoom_indicator
var zoom_text
var zoom_pixels_text
var zoom_level_bar
var position_label
var recording_text

# Variables d'état
var recording = true

# Couleurs
var text_color = Color(0.9, 0.9, 0.7, 1.0) # Jaune pâle comme dans les backrooms
var rec_color = Color(1, 0, 0, 1)  # Rouge pour l'indicateur

func _ready():
	# Configuration des éléments d'interface
	setup_ui()
	
func setup_ui():
	# Horloge
	time_label = Label.new()
	time_label.name = "TimeLabel"
	time_label.position = Vector2(20, 20)
	time_label.add_theme_color_override("font_color", text_color)
	add_child(time_label)
	
	# Carré rouge clignotant
	red_square = ColorRect.new()
	red_square.name = "RedSquare"
	red_square.size = Vector2(15, 15)
	red_square.position = Vector2(get_viewport_rect().size.x - 35, 20)
	red_square.color = rec_color
	add_child(red_square)
	
	# Texte "REC"
	recording_text = Label.new()
	recording_text.name = "RecText"
	recording_text.text = "REC"
	recording_text.position = Vector2(get_viewport_rect().size.x - 80, 20)
	recording_text.add_theme_color_override("font_color", rec_color)
	add_child(recording_text)
	
	# Indicateur de zoom principal
	zoom_indicator = Label.new()
	zoom_indicator.name = "ZoomLabel"
	zoom_indicator.position = Vector2(20, 50)
	zoom_indicator.add_theme_color_override("font_color", text_color)
	add_child(zoom_indicator)
	
	# Information de zoom en pixels
	zoom_pixels_text = Label.new()
	zoom_pixels_text.name = "ZoomPixelsText"
	zoom_pixels_text.position = Vector2(20, 75)
	zoom_pixels_text.add_theme_color_override("font_color", text_color)
	add_child(zoom_pixels_text)
	
	# Description du niveau de zoom
	zoom_text = Label.new()
	zoom_text.name = "ZoomText"
	zoom_text.position = Vector2(20, 100)
	zoom_text.add_theme_color_override("font_color", text_color)
	add_child(zoom_text)
	
	# Barre de niveau de zoom (visuel)
	zoom_level_bar = ColorRect.new()
	zoom_level_bar.name = "ZoomLevelBar"
	zoom_level_bar.position = Vector2(20, 125)
	zoom_level_bar.size = Vector2(100, 8)
	zoom_level_bar.color = Color(0.9, 0.9, 0.7, 0.5) # Jaune pâle semi-transparent
	add_child(zoom_level_bar)
	
	# Position approximative (coordonnées)
	position_label = Label.new()
	position_label.name = "PositionLabel"
	position_label.position = Vector2(20, get_viewport_rect().size.y - 40)
	position_label.add_theme_color_override("font_color", text_color)
	add_child(position_label)

func _process(delta):
	# Mettre à jour l'heure
	update_time()
	
	# Faire clignoter le carré rouge et le texte REC
	if Engine.get_frames_drawn() % 30 < 15:
		red_square.visible = true
		recording_text.visible = true
	else:
		red_square.visible = false
		recording_text.visible = false
	
	# Mettre à jour les indicateurs de zoom
	update_zoom_indicator()
	
	# Mettre à jour la position
	update_position()
	
	# Léger tremblement aléatoire très subtil
	add_subtle_effect()

func update_time():
	var datetime = Time.get_datetime_dict_from_system()
	var time_string = "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second]
	time_label.text = time_string

func update_zoom_indicator():
	var camera = get_camera()
	if camera and "current_zoom" in camera:
		var zoom_level = camera.current_zoom
		
		# Indicateur principal
		zoom_indicator.text = "ZOOM: " + ("%.1fx" % zoom_level)
		
		# Affichage en pixels
		var zoom_pixels = camera.get_zoom_pixels()
		zoom_pixels_text.text = "RESOLUTION: " + str(zoom_pixels) + " PX"
		
		# Information détaillée
		var zoom_info = ""
		if zoom_level < 1.5:
			zoom_info = "NORMAL VIEW"
		elif zoom_level < 3.0:
			zoom_info = "ENHANCED VIEW"
		elif zoom_level < 6.0:
			zoom_info = "DETAIL VIEW"
		else:
			zoom_info = "MAXIMUM MAGNIFICATION"
			
		zoom_text.text = zoom_info
		
		# Mettre à jour la barre de niveau de zoom
		var max_width = 150.0
		var max_zoom_value = camera.max_zoom
		var width = max_width * (zoom_level / max_zoom_value)
		zoom_level_bar.size.x = clamp(width, 5, max_width)

func update_position():
	var player = get_player()
	if player:
		var position = player.global_position
		var pos_text = "LOCATION: %.1f, %.1f, %.1f" % [position.x, position.y, position.z]
		position_label.text = pos_text

func get_camera():
	# Trouver la caméra dans la hiérarchie
	var parent = get_parent()
	if parent is Camera3D:
		return parent
	return null

func get_player():
	# Trouver le joueur (parent de la caméra)
	var camera = get_camera()
	if camera:
		var head = camera.get_parent()
		if head:
			var player = head.get_parent()
			if player:
				return player
	return null

func add_subtle_effect():
	# Tremblement très léger et subtil
	if randf() < 0.03:  # 3% de chance par frame
		var offset = Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
		position = offset
	else:
		position = Vector2.ZERO
