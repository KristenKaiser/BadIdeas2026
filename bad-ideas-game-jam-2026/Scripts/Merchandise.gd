extends Node3D
class_name Merchandise

var object_mesh : MeshInstance3D
var is_held : bool = false
var area3d : Area3D
var collision_shape : CollisionShape3D

func _ready() -> void:
	Global.merch_manager.add_merch(self)
	print("merch ready")
	add_to_group("pickupable")
	object_mesh = get_child(0)
	area3d  = Area3D.new()
	object_mesh.add_child(area3d)
	
	collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	var aabb = object_mesh.get_aabb()
	shape.size =  aabb.size
	collision_shape.shape = shape
	collision_shape.shape.resource_local_to_scene = true
	area3d.add_child(collision_shape)
	area3d.input_event.connect(_on_area_3d_input_event)
	
func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select_object()

func get_mesh()-> MeshInstance3D:
	return object_mesh

func select_object():
	if is_held:
		pass
	else:
		is_held = true
		Global.camera_manager.hold_item(self, object_mesh)
		Global.merch_manager.hold_merch(self)
