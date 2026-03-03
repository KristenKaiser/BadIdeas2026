extends Node
class_name CameraManager

var cameras : Array[Camera3D]
var current : Camera3D
var prev_cameras : Array[Camera3D]

func _ready() -> void:
	current = get_viewport().get_camera_3d()

func add_camera(camera: Camera3D):
	cameras.append(camera)

func change_camera(new_camera : Camera3D): 
	prev_cameras.append(current)
	current = new_camera
	
	if new_camera.current == true:
		return
	var children : Array[Node] = get_viewport().get_camera_3d().get_children()
	new_camera.current = true
	for child in children:
		if child.is_in_group("pickupable"):
			if child.has_method("get_mesh"):
				hold_item(child, child.get_mesh())
			else: 
				printerr("%s is in group pickuppable but does not have method get_mesh" % child)
		child.reparent(new_camera)

func add_child_to_active(child : Node3D):
	child.reparent(get_viewport().get_camera_3d())

func change_camera_to_prev():
	change_camera(prev_cameras.pop_back())

func hold_item(item : Node3D, mesh_instance : MeshInstance3D):
	item.reparent(current)
	item.scale = Vector3(.1,.1,.1)
	item.position = Vector3(.08, -.045, -.07)
	item.global_rotation = current.global_rotation
	mesh_instance.layers = 2
	current.cull_mask = 0xFFFFFFFF
	
