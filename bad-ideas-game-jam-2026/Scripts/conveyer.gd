extends CSGBox3D

@export var collision_shape : CollisionShape3D 

func _ready() -> void:
	collision_shape.shape.size = size


func entered_conveyer(area: Area3D) -> void:
	if area.get_parent() is Box:
		area.get_parent().current_state = area.get_parent().State.CONVEYING


func exited_conveyer(area: Area3D) -> void:
	if area.get_parent() is Box:
		area.get_parent().ship()
