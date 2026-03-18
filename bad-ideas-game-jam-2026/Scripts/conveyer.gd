extends CSGBox3D

@export var collision_shape : CollisionShape3D 


func _ready() -> void:
	collision_shape.shape.size = size


func entered_conveyer(area: Area3D) -> void:
	if area.get_parent() is Box:
		area.get_parent().current_state = area.get_parent().State.CONVEYING
		area.get_parent().global_position.y = global_position.y + size.y/2 + area.get_parent().box_collision_shape.shape.size.y/3


func exited_conveyer(area: Area3D) -> void:
	if area.get_parent() is Box:
		if area.get_parent().is_shipped == false: 
			area.get_parent().is_shipped = true
			Global.box_manager.ship(area.get_parent())
