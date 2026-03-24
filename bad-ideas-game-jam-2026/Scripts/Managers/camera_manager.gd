extends Node
class_name CameraManager

@export var cameras : Array[Camera3D]
var current : Camera3D
var prev_cameras : Array[Camera3D]
var is_zoomed_in : bool = false
var is_screen_locked :bool = false
signal camera_changed
var held_object : Node3D
var is_locked :bool = false 

func _ready() -> void:
	current = get_viewport().get_camera_3d()


func add_camera(camera: Camera3D):
	cameras.append(camera)

func change_camera(new_camera : Camera3D, is_zoom : bool = false): 
	if is_locked:
		return
	prev_cameras.append(current)
	current = new_camera
	if is_zoom == true: 
		is_zoomed_in = true
	
	if new_camera.current == true:
		return
	var children : Array[Node] = get_viewport().get_camera_3d().get_children()
	new_camera.current = true
	for child in children:
		var child_position : Vector3 = child.position
		var child_rotation : Vector3 = child.rotation
		child.reparent(new_camera)
		child.position = child_position
		child.rotation = child_rotation
	camera_changed.emit()

func add_child_to_active(child : Node3D):
	child.reparent(get_viewport().get_camera_3d())

func change_camera_to_prev():
	if is_locked:
		return
	change_camera(prev_cameras.pop_back())

func hold_item(item : Node3D, mesh_instance : MeshInstance3D, rotation_offset : Vector3 = Vector3.ZERO):
	if item.get_parent() != null:
		item.reparent(current)
	else:
		current.add_child(item)
	item.scale = Vector3(.1,.1,.1)
	item.position = Vector3(.08, -.045, -.07)
	item.rotation_degrees = Vector3(180, 90, 0) + Vector3(rotation_offset.y, rotation_offset.z, rotation_offset.z)
	mesh_instance.layers = 2
	current.cull_mask = 0xFFFFFFFF
	held_object = item
	
	
func follow_mouse(camera : Camera3D, base_rotaton : Vector3, x_max_change : float, y_max_change : float, delta: float, speed : float, dead_zone_ratio : Vector2):
	if is_locked:
		return
	if is_screen_locked: return
	##TODO make max chage greater towards center so drift area is round not square
	var change : float = 1 ##TODO replace this with speed
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_center = get_viewport().get_visible_rect().size/2
	var x_change : float = 0
	var y_change : float = 0
	var y_dist_to_center : float = abs(mouse_pos.x - screen_center.x)/screen_center.x
	var x_dist_to_center : float = abs(mouse_pos.y - screen_center.y)/screen_center.y
	if mouse_pos.y > screen_center.y + ( (screen_center.y * dead_zone_ratio.y) / 2):
		if camera.rotation_degrees.x - change > base_rotaton.x - x_max_change:
			x_change = -smoothstep(0.0, 1.0, x_dist_to_center) 
	elif mouse_pos.y < screen_center.y - ( (screen_center.y  * dead_zone_ratio.y) / 2):
		if camera.rotation_degrees.x + change < base_rotaton.x + x_max_change:
			x_change = smoothstep(0.0, 1.0, x_dist_to_center) 
		
	if mouse_pos.x > screen_center.x + ( (screen_center.x * dead_zone_ratio.x )/ 2):
		if camera.rotation_degrees.y - change > base_rotaton.y - y_max_change:
			y_change = -smoothstep(0.0, 1.0, y_dist_to_center) 
	elif mouse_pos.x < screen_center.x - ( (screen_center.x * dead_zone_ratio.x )/ 2):
		if camera.rotation_degrees.y + change < base_rotaton.y + y_max_change:
			y_change = smoothstep(0.0, 1.0, y_dist_to_center) 
	
	camera.rotation_degrees += Vector3(x_change, y_change , 0) * delta * speed
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if is_zoomed_in:
				change_camera_to_prev()
				#prev_camera.current = true
				print("zoom out")
				is_zoomed_in = false
				get_viewport().set_input_as_handled()
	if event is InputEventKey:
		if OS.get_keycode_string(event.keycode) == "L" and event.pressed:
			is_screen_locked = !is_screen_locked
			
