extends CSGBox3D
class_name Box

enum State {ENTERING, CONVEYING, EXITING}
var current_state : State
@export var camera : Camera3D
@export var sizes : Dictionary [String, Vector3i]
var current_size: String
@export var box_interior : CSGBox3D ##TODO only needed for whiteboxing
@export var collision_shape : CollisionShape3D





func _ready() -> void:
	set_box_size("Small")
	var grid : MeshInstance3D=  create_grid_mesh(Vector2i(sizes[current_size].x,sizes[current_size].z), Global.grid_size)
	box_interior.add_child(grid)
	grid.position = Vector3(-box_interior.size.x/2, -box_interior.size.y/2, -box_interior.size.z/2)

	
func _process(delta: float) -> void:
	match current_state:
		State.ENTERING:
			entering(delta)
		State.CONVEYING:
			conveying(delta)
		State.EXITING: 
			exiting(delta)

func entering(delta: float):
	position.y -= Global.box_drop_speed * delta
	
	
func conveying(delta: float): 
	position.x += Global.conveyer_speed *delta

func exiting(delta: float):
	position.y -= Global.box_drop_speed * delta

func ship():
	Global.box_manager.box_dropper.drop_box()
	await get_tree().create_timer(1).timeout
	self.queue_free()

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if Global.camera_manager.current != camera: 
					Global.camera_manager.change_camera(camera, true)
				elif Global.merch_manager.held_merch.is_empty() == false:
					Global.merch_manager.place_held_merch(self, Vector3.ZERO)




func set_box_size(box_size : String):
	current_size = box_size
	#var grid_size : Vector2 = sizes[box_size]
	var size_vector : Vector3 = Vector3(sizes[box_size]) * Global.grid_size
	var change_vector : Vector3 = size_vector/box_interior.size
	size *= change_vector
	box_interior.size = size_vector
	collision_shape.shape.size *= change_vector


func create_grid_mesh(grid_size: Vector2i, cell_size: float) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var mesh_material = StandardMaterial3D.new()
	mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_material.albedo_color = Color(1, 1, 1, 0.3)
	mesh_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, mesh_material)
	for i in range(0, grid_size.x + 1):
		# Lines along X
		immediate_mesh.surface_add_vertex(Vector3(i * cell_size, 0, 0))
		immediate_mesh.surface_add_vertex(Vector3(i * cell_size, 0,  grid_size.y * cell_size))
		# Lines along Z
		immediate_mesh.surface_add_vertex(Vector3(0, 0, i * cell_size))
		immediate_mesh.surface_add_vertex(Vector3( grid_size.x * cell_size, 0, i * cell_size))
	immediate_mesh.surface_end()
	
	mesh_instance.mesh = immediate_mesh
	return mesh_instance
