extends Node3D
class_name Box

enum State {ENTERING, CONVEYING, EXITING, STILL}
var current_state : State
@export var camera : Camera3D
@export var box : BoxModel
var current_size: String
@export var box_interior : CollisionShape3D ##TODO only needed for whiteboxing
@export var box_collision_shape : CollisionShape3D
@export var bottom_box_collision_shape : CollisionShape3D
var ghost: Merchandise= null
var ghost_timer : Timer
var is_zoomed_in : bool = false
var grid_statuses : Array[Array]
@export var order_form : OrderForm
var held_objects : Dictionary[String, int]
var is_shipped : bool = false

func _ready() -> void:
	Global.camera_manager.camera_changed.connect(camera_changed)
	
	order_form.parent_box = self
	order_form.generate_order()
	current_state = State.STILL
	var grid : MeshInstance3D=  create_grid_mesh(Vector2i(Global.box_manager.sizes[current_size].x,Global.box_manager.sizes[current_size].z), Global.grid_size)
	
	box_interior.add_child(grid)
	grid.position = Vector3(-box_interior.shape.size.x/2, -box_interior.shape.size.y/2.9, -box_interior.shape.size.z/2)
	#bottom_box_collision_shape.scale = Vector3.ONE
	bottom_box_collision_shape.shape.size = Vector3(box_interior.shape.size.x, .01, box_interior.shape.size.z)
	bottom_box_collision_shape.global_position.y = box_interior.global_position.y - box_interior.shape.size.y/2 + .01
	Global.fit_collision_to_meshes(box, box_collision_shape)


func set_grid_size():
	for z in range(Global.box_manager.sizes[current_size].z): 
		var temp : Array[bool]
		temp.resize(Global.box_manager.sizes[current_size].x)
		temp.fill(false)
		grid_statuses.append(temp)


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


func _on_box_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if Global.camera_manager.current != camera: 
					Global.camera_manager.change_camera(camera, true)

func set_box_size(box_size : String):
	current_size = box_size
	var size_vector : Vector3 = Vector3(Global.box_manager.sizes[box_size]) * Global.grid_size
	var change_vector : Vector3 = size_vector/box_interior.shape.size
	
	box_interior.shape.size = size_vector

	#box_collision_shape.shape.size = box.get_box_size()
	box.scale *= change_vector
	grid_statuses.clear()
	set_grid_size()

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
	var x_pos : float = floor(snapped(world_pos.x / Global.grid_size, .1))
	var z_pos : float = floor(snapped(world_pos.z / Global.grid_size, .1))
	if Global.box_manager.sizes[current_size].x % 2 != 0: 
		x_pos = floor(snapped(world_pos.x / Global.grid_size, 1))
	if Global.box_manager.sizes[current_size].z % 2 != 0: 
		z_pos = floor(snapped(world_pos.z / Global.grid_size, 1))
	
	
	var snap_position :  Vector3 = Vector3 (x_pos * Global.grid_size ,
		world_pos.y, 
		z_pos * Global.grid_size
	)
	# offset center of snap for even rows.colums
	if Global.box_manager.sizes[current_size].x % 2 == 0: 
		snap_position.x +=  Global.grid_size/2
	if Global.box_manager.sizes[current_size].z % 2 == 0: 
		snap_position.z +=  Global.grid_size/2
	return snap_position

func _box_bottom_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if Global.merch_manager.held_merch.is_empty() == false:
			if event.pressed:
				add_to_box(event_position)
	if event is InputEventMouseMotion:
		if Global.merch_manager.held_merch.is_empty() == false:
			move_ghost(snap_to_grid(to_local(event_position)))

func add_to_box(event_position: Vector3):
	var new_position : Vector3= snap_to_grid(to_local(event_position))
	if add_to_grid(Vector2(new_position.x, new_position.z),  Global.merch_manager.get_last_held_merch().grid_shape) == true: 
		Global.merch_manager.get_last_held_merch().location = Global.merch_manager.get_last_held_merch().Location.BOX
		Global.merch_manager.get_last_held_merch().remove_from_box.connect(remove_from_box)
		if held_objects.has(Global.merch_manager.get_last_held_merch().merch_name): 
			held_objects[Global.merch_manager.get_last_held_merch().merch_name] += 1
		else: 
			held_objects[Global.merch_manager.get_last_held_merch().merch_name] = 1
			
		if  Global.merch_manager.get_last_held_merch().ghost != null:
			Global.merch_manager.place_held_merch(self)
		else:
			Global.merch_manager.place_held_merch(self)
		if ghost != null: 
			ghost.queue_free()
		

func remove_from_box(world_position: Vector3, merch : Merchandise):
	if held_objects.has(merch.merch_name):
		held_objects[merch.merch_name] -= 1
		if held_objects[merch.merch_name] == 0: 
			held_objects.erase(merch.merch_name)
	var old_position : Vector3= snap_to_grid(to_local(world_position))
	merch.remove_from_box.disconnect(remove_from_box)
	remove_from_grid(Vector2(old_position.x, old_position.z), merch.grid_shape)
	
	
func is_grid_place_valid(snap_position: Vector2, shape: String)->bool:
	var grid_update : Array[Array] = get_grid_placement(snap_position, shape)
	if grid_update == [[-1]]:
		return false
	for row in range(grid_update.size()):
		for column in range(grid_update[row].size()):
			if grid_statuses[row][column] == true and grid_update[row][column] == true:
				return false
	return true

func add_to_grid(snap_position: Vector2, shape: String)->bool:
	if is_grid_place_valid(snap_position, shape) == false:
		return false
	var grid_update : Array[Array] = get_grid_placement(snap_position, shape)
	for row in range(grid_update.size()):##testing had size - 1
		for column in range(grid_update[row].size()):##testing had size - 1 
			if grid_update[row][column] == true:
				grid_statuses[row][column] = true
	return true

func remove_from_grid(snap_position: Vector2, shape: String):
	var grid_update : Array[Array] = get_grid_placement(snap_position, shape)
	for row in range(grid_update.size()):##testing had size - 1
		for column in range(grid_update[row].size()):##testing had size - 1
			if grid_update[row][column] == true:
				grid_statuses[row][column] = false


func get_grid_placement(snap_position: Vector2, shape: String)-> Array[Array]:
	@warning_ignore("integer_division")
	var position_int : Vector2i = Vector2i(floori(snapped(snap_position.x/Global.grid_size,.1)) + Global.box_manager.sizes[current_size].x/2 , \
	floori(snapped(snap_position.y/Global.grid_size, .1))+ Global.box_manager.sizes[current_size].z/2)
	# if outside of box return 
	if position_int.x < 0 or position_int.x > grid_statuses[0].size() - 1 or \
	position_int.y < 0 or position_int.y > grid_statuses.size() -1:
		return [[-1]]
	
	var grid_copy : Array[Array] = grid_statuses.duplicate(true)
	for row in grid_copy:
			row.fill(false)
	var columns : int = shape.find("\n") 
	if columns == -1: 
		columns = shape.length()
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
		if index_vector.y >= grid_copy.size() or index_vector.x >= grid_copy[index_vector.y].size() or \
		index_vector.x < 0 or index_vector.y < 0:
			return [[-1]]
		grid_copy[index_vector.y][index_vector.x] = true
	return grid_copy
	

func print_grid(grid : Array[Array]):
	for row in grid: 
		print(row)

func move_ghost(ghost_position : Vector3):
	if ghost == null: 
		ghost =  Global.merch_manager.get_last_held_merch().duplicate()
		ghost.scale = Vector3.ONE
		ghost.name = ghost.name +"_ghost"
		ghost.is_ghost = true
		Global.merch_manager.get_last_held_merch().get_parent().add_child(ghost)
		ghost.reparent(self)
		ghost.rotation_degrees = Vector3(0, -90, -90)
		ghost.duplicate_globals(Global.merch_manager.get_last_held_merch())
		ghost.collision_shape.disabled = true
		ghost.object_mesh.transparency =.5
		
	if is_grid_place_valid(Vector2(ghost_position.x, ghost_position.z), Global.merch_manager.get_last_held_merch().grid_shape) == false:
		is_grid_place_valid(Vector2(ghost_position.x, ghost_position.z), Global.merch_manager.get_last_held_merch().grid_shape)
		#if ghost_position.x > self.size.x/2.0 or ghost_position.x < -self.size.x/2.0 or ghost_position.z > self.size.x/2.0 or ghost_position.z < -self.size.y/2.0:
			#ghost.hide()
		turn_ghost_red()
	else:
		#ghost.show()
		ghost.object_mesh.material_override = null

	ghost.position = ghost_position - (Global.merch_manager.get_last_held_merch().center_offset * Global.grid_size)


func turn_ghost_red():
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = Color(1, 0, 0)  # Pure red
	ghost.object_mesh.material_override = new_material

func camera_changed() -> void:
	if camera == Global.camera_manager.current:
		is_zoomed_in = true
		box_collision_shape.disabled = true
		if ghost != null:
			ghost.show()
	elif is_zoomed_in == true: 
		box_collision_shape.disabled = false
		is_zoomed_in = false
		if ghost != null:
			ghost.orignal_merch.ghost = null
			ghost.queue_free()

func _on_box_bottom_3d_mouse_entered() -> void:
	if ghost != null:
		ghost.object_mesh.material_override = null

func _on_box_bottom_3d_mouse_exited() -> void:
	if ghost != null:
		turn_ghost_red()
		
func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey:
			if is_zoomed_in:
				if OS.get_keycode_string(event.keycode) == "W" and event.pressed:
					box.move_flap("left")
				if OS.get_keycode_string(event.keycode) == "S" and event.pressed:
					box.move_flap("right")
				if OS.get_keycode_string(event.keycode) == "A" and event.pressed:
					box.move_flap("front")
				if OS.get_keycode_string(event.keycode) == "D" and event.pressed:
					box.move_flap("back")
					
