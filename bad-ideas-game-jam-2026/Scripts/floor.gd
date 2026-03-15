extends CSGBox3D

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent() is Box:
		Global.box_manager.ship(area.get_parent())
		#area.get_parent().ship()
