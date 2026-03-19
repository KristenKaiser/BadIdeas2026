extends Node3D
class_name ShippingLabel
@export var label : Label3D
@export var collision_shape : CollisionShape3D
@export var label_mesh : MeshInstance3D
var is_held : bool = false

func _ready() -> void:
	#collision_shape.shape.size = get_aabb().size
	
	await get_tree().process_frame
	resize_mesh_to_label()
	label_mesh.scale = Vector3(.2,.2,.2)
	collision_shape.shape.size = label_mesh.get_aabb().size
	collision_shape.position = Vector3.ZERO
	
func resize_mesh_to_label():
	var label_aabb = label.get_aabb()
	var local_size = label_aabb.size / label.global_transform.basis.get_scale()

	var padding = Vector2(0.2, 0.1)

	label_mesh.mesh.size = Vector3(
		local_size.x + padding.x,
		local_size.y + padding.y,
		label_mesh.mesh.size.z
	)
	


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Global.merch_manager.held_merch.is_empty():
				if !is_held: 
					label_mesh.rotation_degrees = Vector3(360, 90, 0)
					Global.camera_manager.hold_item(self, label_mesh)
