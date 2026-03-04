extends CSGBox3D

@export var collision_shape : CollisionShape3D 

func _ready() -> void:
	collision_shape.shape.size = size
	

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent() is Box:
		area.get_parent().current_state = area.get_parent().State.CONVEYING


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent() is Box:
		area.get_parent().current_state = area.get_parent().State.EXITING
