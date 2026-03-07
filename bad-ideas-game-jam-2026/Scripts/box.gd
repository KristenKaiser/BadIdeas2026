extends CSGBox3D
class_name Box

enum State {ENTERING, CONVEYING, EXITING, STILL}
var current_state : State
@export var camera : Camera3D
@export var sizes : Dictionary [String, Vector3i]
var current_size: String
@export var box_interior : CSGBox3D ##TODO only needed for whiteboxing
@export var box_collision_shape : CollisionShape3D
@export var bottom_box_collision_shape : CollisionShape3D
var ghost: MeshInstance3D = null
var ghost_timer : Timer
var is_zoomed_in : bool = false
var grid_statuses : Array[Array]
	

func _ready() -> void:
	Global.camera_manager.camera_changed.connect(camera_changed)
	set_box_size("Small")
	current_state = State.STILL
	for z in range(sizes[current_size].z): 
		var temp : Array[bool]
		temp.resize(sizes[current_size].x)
		temp.fill(false)
		grid_statuses.append(temp)
	print_grid(grid_statuses)
	var grid : MeshInstance3D=  create_grid_mesh(Vector2i(sizes[current_size].x,sizes[current_size].z), Global.grid_size)
	box_interior.add_child(grid)
	grid.position = Vector3(-box_interior.size.x/2, -box_interior.size.y/2.9, -box_interior.size.z/2)
	bottom_box_collision_shape.shape.size = Vector3(box_interior.size.x, .01, box_interior.size.z)
	bottom_box_collision_shape.position.y = box_interior.position.y - box_interior.size.y/2 + .01
	box_collision_shape.shape.size = size
	#ghost_timer.timeout.connect(hide_ghost)
	
	
func _process(delta: float) -> void:
	match current_state:
		State.ENTERING:
			entering(delta)
		State.CONVEYING:
			conveying(delta)
		State.EXITING: 
			exiting(delta)
		State.STILL:
			pass

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
	if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if Global.camera_manager.current != camera: 
					Global.camera_manager.change_camera(camera, true)
					#box_collision_shape.disabled = true

func set_box_size(box_size : String):
	current_size = box_size
	#var grid_size : Vector2 = sizes[box_size]
	var size_vector : Vector3 = Vector3(sizes[box_size]) * Global.grid_size
	var change_vector : Vector3 = size_vector/box_interior.size
	size *= change_vector
	box_interior.size = size_vector
	box_collision_shape.shape.size *= change_vector

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

func snap_to_grid(world_pos: Vector3) -> Vector3:
	#offset orgin point for odd number row/columns
	if sizes[current_size].x % 2 != 0: 
		world_pos.x += Global.grid_size/2.0
	if sizes[current_size].z % 2 != 0: 
		world_pos.z += Global.grid_size/2.0
	
	var snap_position :  Vector3 = Vector3 ((floor(world_pos.x / Global.grid_size) * Global.grid_size) ,
		world_pos.y, # keep Y as-is, or snap it too if needed
		(floor(world_pos.z / Global.grid_size) * Global.grid_size) 
	)
	# offset center of snap for even rows.colums
	if sizes[current_size].x % 2 == 0: 
		snap_position.x +=  Global.grid_size/2
	if sizes[current_size].z % 2 == 0: 
		snap_position.z +=  Global.grid_size/2
	return snap_position

func _box_bottom_on_area_3d_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if Global.merch_manager.held_merch.is_empty() == false:
			if event.pressed:
				var new_position : Vector3= snap_to_grid(to_local(event_position))
				if add_to_grid(Vector2(new_position.x, new_position.z),  Global.merch_manager.get_last_held_merch().grid_shape) == true: 
				#fill_grid(Vector2(new_position.x, new_position.z),  Global.merch_manager.get_last_held_merch().grid_shape)
					Global.merch_manager.place_held_merch(self, new_position)
				
				if ghost != null: 
					ghost.queue_free()
	if event is InputEventMouseMotion:
		if Global.merch_manager.held_merch.is_empty() == false:
			move_ghost(snap_to_grid(to_local(event_position)))

func add_to_grid(snap_position: Vector2, shape: String)->bool:
	var grid_update : Array[Array] = get_grid_placement(snap_position, shape)
	if grid_update == [[-1]]:
		print("! out of bounds")
		return false
	print_grid(grid_statuses)
	for row in range(grid_update.size()-1):
		for column in range(grid_update.size()-1):
			if grid_statuses[row][column] == true and grid_update[row][column] == true:
				print("overlap")
				return false
	for row in range(grid_update.size()-1):
		for column in range(grid_update.size()-1):
			if grid_update[row][column] == true:
				grid_statuses[row][column] = true
	print_grid(grid_statuses)
	return true


func get_grid_placement(snap_position: Vector2, shape: String)-> Array[Array]:
	@warning_ignore("integer_division")
	var position_int : Vector2i = Vector2i(floori(snapped(snap_position.x/Global.grid_size,.1)) + sizes[current_size].x/2 , \
	floori(snapped(snap_position.y/Global.grid_size, .1))+ sizes[current_size].z/2)
	
	var grid_copy : Array[Array] = grid_statuses.duplicate(true)
	for row in grid_copy:
			row.fill(false)
	var columns : int = shape.find("\n") 
	var shape_copy : String = shape.remove_chars("\n")
	@warning_ignore("integer_division")
	var orgin : Vector2i = Vector2i(shape_copy.find("o")%columns, floor(shape_copy.find("o")/columns))
	grid_copy[position_int.y][position_int.x] = true
	var index : int = 0
	for x in shape_copy.count("x", 0, 0):
		index = shape_copy.find("x", index)
		@warning_ignore("integer_division")
		var index_vector : Vector2i = Vector2(index%columns, floor(index/columns))
		index_vector = -(orgin - index_vector)
		index += 1
		index_vector = position_int + index_vector
		if index_vector.y >= grid_copy.size() or index_vector.x >= grid_copy[index_vector.y].size():
			print("out of bounds")
			return [[-1]]
		grid_copy[index_vector.y][index_vector.x] = true
	return grid_copy
	

func print_grid(grid : Array[Array]):
	for row in grid: 
		print(row)

func move_ghost(ghost_position : Vector3):
	if ghost == null: 
		ghost = Global.merch_manager.get_last_held_merch().object_mesh.duplicate()
		ghost.name = ghost.name +"_ghost"
		self.add_child(ghost)
		ghost.rotation = Global.merch_manager.get_last_held_merch().rotation
		ghost.rotation.x = 90
		ghost.get_child(0).get_child(0).disabled = true
		ghost.transparency =.5
	ghost.position = ghost_position - (Global.merch_manager.get_last_held_merch().center_offset * Global.grid_size)

func camera_changed() -> void:
	if camera == Global.camera_manager.current:
		is_zoomed_in = true
		box_collision_shape.shape.size.y = .01
		box_collision_shape.position.y = position.y - size.y/2 + .01
	elif is_zoomed_in == true: 
		is_zoomed_in = false
		box_collision_shape.shape.size = size
		box_collision_shape.global_position = global_position

func _on_box_bottom_3d_mouse_entered() -> void:
	if ghost != null:
		ghost.show()

func _on_box_bottom_3d_mouse_exited() -> void:
	if ghost != null:
		ghost.hide()
