extends MeshInstance3D


@export var camera : Camera3D
var prev_camera : Camera3D


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				on_click()

func on_click():
	if Global.camera_manager.current != camera:
		prev_camera = get_viewport().get_camera_3d()
		Global.camera_manager.change_camera(camera, true)
		#camera.current = true
		print("zoom in")
