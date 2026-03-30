extends MeshInstance3D

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Global.camera_manager.held_object != null and Global.camera_manager.held_object is TrashBag: 
				Global.camera_manager.held_object.queue_free()
				Global.camera_manager.held_object = null
