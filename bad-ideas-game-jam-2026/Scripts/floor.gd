extends CSGBox3D




func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent() is Box:
		area.get_parent().ship()
