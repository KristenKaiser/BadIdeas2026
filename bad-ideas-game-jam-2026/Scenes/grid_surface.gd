extends MeshInstance3D
class_name GridSurface


@export var grid_size : Vector2i = Vector2i(3,3)

@export var surface_collision_shape : CollisionShape3D
var ghost: Merchandise = null
var grid_statuses : Array[Array]
var held_objects : Dictionary[String, int]


func _ready() -> void:

	mesh.size = Vector3(grid_size.x * Global.grid_size, .01, grid_size.y * Global.grid_size)
	var grid : MeshInstance3D=  create_grid_mesh(grid_size, Global.grid_size)
	
	add_child(grid)
	grid.position = Vector3(-mesh.size.x/2, mesh.size.y/2, -mesh.size.z/2)
	#bottom_box_collision_shape.scale = Vector3.ONE
	surface_collision_shape.shape.size = Vector3(mesh.size.x, .01, mesh.size.z)
	surface_collision_shape.global_position.y = global_position.y - mesh.size.y/2 + .01
	set_grid_size()

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if Global.camera_manager.held_object != null:
			if event.pressed:
				add_to_box(event_position)
	if event is InputEventMouseMotion:
		if Global.camera_manager.held_object != null:
			move_ghost(snap_to_grid(to_local(event_position)))
#
func set_grid_size():
	for y in range(grid_size.y): 
		var temp : Array[bool]
		temp.resize(grid_size.x)
		temp.fill(false)
		grid_statuses.append(temp)

func create_grid_mesh(new_grid_size: Vector2i, cell_size: float) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var mesh_material = StandardMaterial3D.new()
	mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_material.albedo_color = Color(0.48, 0.271, 0.0, 0.302)
	mesh_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, mesh_material)
	for i in range(0, new_grid_size.x + 1):
		# Lines along X
		immediate_mesh.surface_add_vertex(Vector3(i * cell_size, 0, 0))
		immediate_mesh.surface_add_vertex(Vector3(i * cell_size, 0,  new_grid_size.y * cell_size))
		# Lines along Z
		immediate_mesh.surface_add_vertex(Vector3(0, 0, i * cell_size))
		immediate_mesh.surface_add_vertex(Vector3( new_grid_size.x * cell_size, 0, i * cell_size))
	immediate_mesh.surface_end()
	
	mesh_instance.mesh = immediate_mesh
	return mesh_instance

func snap_to_grid(world_pos: Vector3) -> Vector3:
	var x_pos : float = floor(snapped(world_pos.x / Global.grid_size, .1))
	var z_pos : float = floor(snapped(world_pos.z / Global.grid_size, .1))
	if grid_size.x % 2 != 0: 
		x_pos = floor(snapped(world_pos.x / Global.grid_size, 1))
	if grid_size.y % 2 != 0: 
		z_pos = floor(snapped(world_pos.z / Global.grid_size, 1))
	
	
	var snap_position :  Vector3 = Vector3 (x_pos * Global.grid_size ,
		world_pos.y, 
		z_pos * Global.grid_size
	)
	# offset center of snap for even rows.colums
	if grid_size.x % 2 == 0: 
		snap_position.x +=  Global.grid_size/2
	if grid_size.y % 2 == 0: 
		snap_position.z +=  Global.grid_size/2
	
	return snap_position

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
#
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
	var position_int : Vector2i = Vector2i(floori(snapped(snap_position.x/Global.grid_size,.1)) + grid_size.x/2 , \
	floori(snapped(snap_position.y/Global.grid_size, .1))+ grid_size.y/2)
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
#
func move_ghost(ghost_position : Vector3):
	if ghost == null: 
		ghost =  Global.merch_manager.get_last_held_merch().duplicate()
		ghost.scale = Vector3.ONE
		ghost.name = ghost.name +"_ghost"
		ghost.is_ghost = true
		Global.merch_manager.get_last_held_merch().get_parent().add_child(ghost)
		ghost.reparent(self)
		#ghost.rotation_degrees = Vector3(0, -90, -90) ##BAD PROGRAMMING different than box script to account for not changing gamera angle - when combining box and grid will need to account for camera angle instead of hard coding variable (apologies to futrue me) 
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
	if ghost.visible == false: 
		ghost.show()
	ghost.position = ghost_position - (Global.merch_manager.get_last_held_merch().center_offset * Global.grid_size)
	ghost.position.y = (ghost.object_mesh.get_aabb().size.y/2) * ghost.scale.y * ghost.object_mesh.scale.y


func turn_ghost_red():
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = Color(1, 0, 0)  # Pure red
	ghost.object_mesh.material_override = new_material


#func _on_box_bottom_3d_mouse_entered() -> void:
	#if ghost != null:
		#ghost.object_mesh.material_override = null
#
#func _on_box_bottom_3d_mouse_exited() -> void:
	#if ghost != null:
		#turn_ghost_red()
		#


func _on_area_3d_mouse_entered() -> void:
	if ghost != null and ghost.visible == false:
		ghost.show()


func _on_area_3d_mouse_exited() -> void:
	if ghost != null and ghost.visible == true:
		ghost.hide()
