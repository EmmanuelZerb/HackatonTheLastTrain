extends Node3D

enum RotationAxis {
	X_AXIS,
	Y_AXIS,
	Z_AXIS
}
@export_enum("X Axis", "Y Axis", "Z Axis") var Axe_De_Rotation := 1
@export var Temps_De_Rotation:float = 2.0

func _ready():
	if get_parent() is objet_base:
		var tween := create_tween().set_loops()
		match Axe_De_Rotation:
			RotationAxis.X_AXIS:
				tween.tween_property(get_parent(), "rotation", get_parent().rotation + Vector3(PI * 2, 0, 0), Temps_De_Rotation).set_trans(Tween.TRANS_LINEAR)
			RotationAxis.Y_AXIS:
				tween.tween_property(get_parent(), "rotation", get_parent().rotation + Vector3(0, PI * 2, 0), Temps_De_Rotation).set_trans(Tween.TRANS_LINEAR)
			RotationAxis.Z_AXIS:
				tween.tween_property(get_parent(), "rotation", get_parent().rotation + Vector3(0, 0, PI * 2), Temps_De_Rotation).set_trans(Tween.TRANS_LINEAR)
