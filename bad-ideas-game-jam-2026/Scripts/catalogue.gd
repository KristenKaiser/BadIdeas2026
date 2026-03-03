extends MeshInstance3D

var is_zoomed_in : bool = false
@export var camera : Camera3D
var prev_camera : Camera3D


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				on_click()

func on_click():
	if is_zoomed_in == false:
		prev_camera = get_viewport().get_camera_3d()
		Global.camera_manager.change_camera(camera)
		#camera.current = true
		print("zoom in")
		is_zoomed_in = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if is_zoomed_in:
				Global.camera_manager.change_camera_to_prev()
				#prev_camera.current = true
				print("zoom out")
				is_zoomed_in = false
				get_viewport().set_input_as_handled()
