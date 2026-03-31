extends Node3D
class_name Merchandise

var object_mesh : MeshInstance3D
@export var merch_name : String
var is_held : bool = false
var area3d : Area3D
var collision_shape : CollisionShape3D
@export var grid_shape : String
@export var center_offset: Vector3 
@export var trash_fill : int
var is_ghost: bool = false
@export var rotate_axis : String
signal rotateghost(amount : Vector3)
signal changgeGhostPivot(pivot_change : Vector3)
var current_pivot_offset : Vector3
var ghost : Merchandise
var orignal_merch : Merchandise
enum Location{ORDER_TUBE, HELD, BOX}
var location : Location
signal remove_from_box(location : Vector3, merch : Merchandise)
var base_rotation : Vector3
var ghost_rotatation : Vector3 = Vector3.ZERO

func _ready() -> void:
	if is_ghost: 
		return
	Global.merch_manager.add_merch(self)
	add_to_group("pickupable")
	object_mesh = get_child(0)
	area3d  = Area3D.new()
	area3d.name = "area3d"
	object_mesh.add_child(area3d)
	object_mesh.scale *= get_size_from_shape()
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "collision_shape"
	var shape = BoxShape3D.new()
	var aabb = object_mesh.get_aabb()
	shape.size =  aabb.size
	object_mesh.global_position = global_position
	
	collision_shape.shape = shape
	collision_shape.shape.resource_local_to_scene = true
	area3d.add_child(collision_shape)
	area3d.input_event.connect(_on_area_3d_input_event)
	collision_shape.position = aabb.get_center()
	object_mesh.position = -aabb.get_center() * object_mesh.scale
	current_pivot_offset = get_pivot_offset()
	object_mesh.position -= current_pivot_offset

func get_pivot_offset()-> Vector3:
	var orgin: Vector2
	var grid_array = get_grid_as_array()
	for y in range(grid_array.size()):
		for x in range(grid_array[y].size()):
			if grid_array[y][x] == "o":
				orgin = Vector2(x + .5,y + .5)
	var zero : Vector2 = Vector2(grid_array[0].size() /2.0, grid_array.size() /2.0 )
	var offset = orgin - zero
	offset *= Global.grid_size
	return Vector3(0, offset.y, -offset.x)

func get_mesh()-> MeshInstance3D:
	return get_child(0)

func get_area3d()->Area3D:
	return object_mesh.get_node("area3d")
	

func duplicate_globals(orgin :Merchandise, new_is_ghost : bool = true):
	orignal_merch = orgin
	if new_is_ghost:
		orgin.ghost = self
	object_mesh = get_mesh()
	merch_name = orgin.merch_name
	is_held = orgin.is_held
	area3d = get_area3d()
	collision_shape = area3d.get_node("collision_shape")
	grid_shape = orgin.grid_shape
	center_offset = orgin.center_offset
	trash_fill = orgin.trash_fill
	rotate_axis = orgin.rotate_axis
	orgin.rotateghost.connect(rotate_ghost)
	orgin.changgeGhostPivot.connect(change_ghost_pivot)

func rotate_ghost(amount : Vector3):
	rotation_degrees += Vector3(-amount.y, -amount.x, -amount.z)

func get_size_from_shape() -> Vector3:
	var grid_array : Array[Array] = get_grid_as_array()
	var target_size : Vector3 = Vector3( grid_array[0].size(), grid_array.size(), 1) * Global.grid_size
	var aabb = object_mesh.get_aabb()  # local space
	var global_aabb : AABB = object_mesh.global_transform * aabb  # world space AABB
	var scale_factor : Vector3 =  target_size / global_aabb.size 	
	return scale_factor


func _on_area_3d_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select_object(event_position)
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey:
			if is_held == true:
				if OS.get_keycode_string(event.keycode) == "Q" and event.pressed and is_ghost == false:
					turn(false)
					get_viewport().set_input_as_handled()
				if OS.get_keycode_string(event.keycode) == "E" and event.pressed and is_ghost == false:
					turn(true)
					get_viewport().set_input_as_handled()
	

func select_object(_event_position : Vector3):
	match location: 
		Location.HELD: 
			pass
		Location.ORDER_TUBE:
			if self == Global.order_tube.held_object:
				Global.order_tube.held_object = null
			hold_object()
		Location.BOX: 
			remove_from_box.emit(global_position, self)
			hold_object(rotation_degrees - (Vector3(0, 0, -90) - base_rotation))

	
	
func hold_object(rotation_offset : Vector3 = Vector3.ZERO): 
	if Global.merch_manager.hold_merch(self):
		is_held = true
		Global.camera_manager.hold_item(self, object_mesh, rotation_offset)
		ghost_rotatation = rotation_offset


func turn(is_right : bool):
	if is_right: 
		rotate_shape(true)
		#update_center_offset(true)
		rotate_node(90.0)
	else:
		rotate_shape(false)
		#update_center_offset(false)
		rotate_node(-90.0)
	
func change_ghost_pivot(pivot_change : Vector3):
	object_mesh.position += pivot_change

func rotate_node(rotation_change : float):
	match rotate_axis: 
		"X":
			rotation_degrees.x += rotation_change
			rotateghost.emit(Vector3(rotation_change, 0, 0))
		"Y":
			rotation_degrees.y += rotation_change
			rotateghost.emit(Vector3(0, rotation_change, 0))
		"Z":
			rotation_degrees.z += rotation_change
			rotateghost.emit(Vector3(0, 0, rotation_change))

func update_center_offset(is_to_right : bool ):
	# upper right or lower left
	if (center_offset.x > 0 and center_offset.z > 0) or (center_offset.x < 0 and center_offset.z < 0):
		if is_to_right:
			center_offset.x = -center_offset.x
		else:
			center_offset.z = - center_offset.z
	# upper left or lower right
	else:
		if is_to_right:
			center_offset.z = -center_offset.z
		else:
			center_offset.x = - center_offset.x

func get_grid_as_array()-> Array[Array]:
	var start_shape : Array[Array]
	var current_row : Array[String] = []
	
	start_shape.append(current_row)
	for i in range(grid_shape.length()):
		var character : String = grid_shape[i]
		if character =="\n":
			var new_row : Array[String] = []
			start_shape.append(new_row)
			current_row = new_row
		else: 
			current_row.append(character)
	
	return start_shape

## if rotate shape starts breaking check ##UNTESTED
func rotate_shape(is_to_right : bool ):
	var rows : int = grid_shape.count("\n") 
	if rows == -1 : rows = 1 ##UNTESTED
	else: rows += +1  ##UNTESTED
	var columns : int = grid_shape.find("\n")
	if columns == -1 : columns = grid_shape.length()
	if rows == 1 and columns == 1:
		return

	var start_shape : Array[Array] = get_grid_as_array()
	
	#convert rows to parimeter 
	var perimeter_rows : Array[Array] = []
	var perimeter_row : Array[String] = []
	perimeter_rows.append(perimeter_row)
	var edge_array : Array[String] = []
	while start_shape.is_empty() == false:
		for row in range(start_shape.size()):
			if row == 0 :
				perimeter_row.append_array(start_shape[0])
			elif row == start_shape.size()-1:
				start_shape[row].reverse()
				perimeter_row.append_array(start_shape[row])
			else:
				perimeter_row.append(start_shape[row][start_shape[row].size() -1])
				start_shape[row].remove_at(start_shape[row].size() -1)
				if start_shape[row].is_empty() == false:
					edge_array.append(start_shape[row][0])
					start_shape[row].remove_at(0)
		start_shape.remove_at(start_shape.size() -1)
		if start_shape.is_empty() == false:
			start_shape.remove_at(0)
		edge_array.reverse()
		perimeter_row.append_array(edge_array)
		edge_array = [] 
		if start_shape.is_empty() != true:
			var new_perimeter : Array[String] = []
			perimeter_rows.append(new_perimeter)
			perimeter_row = new_perimeter
	if perimeter_rows.back().is_empty():
		perimeter_rows.pop_back()
	
	#shift parimeter
	if columns == 1: 
		if is_to_right:
			perimeter_rows[0].reverse()
	elif rows == 1: 
		if is_to_right == false: 
			perimeter_rows[0].reverse()
	else:
		var rows_offset
		if is_to_right:
			rows_offset = rows - 1 
		else: 
			rows_offset = columns - 1
		for row in range(perimeter_rows.size()): 
			var temp_array : Array[String] = []
			for i in range(rows_offset):
				if is_to_right:
					temp_array.insert(0, perimeter_rows[row].pop_back())
				else: 
					temp_array.append(perimeter_rows[row].pop_front())
			rows_offset -= 2
			if is_to_right:
				temp_array.append_array(perimeter_rows[row])
				perimeter_rows[row] = temp_array.duplicate()
			else:
				perimeter_rows[row].append_array(temp_array)
		if perimeter_rows.back().is_empty():
			perimeter_rows.pop_back()
	
	#convert parimeter back to rows
	var end_shape : Array[Array]
	end_shape.resize(columns)
	
	if rows == 1: 
		for row in end_shape:
			row.append(perimeter_row.pop_front())
	else: 
		var column_offset = rows
		var curent_starting_row = 0
		var current_row_int: int = 0
		while perimeter_rows.is_empty() == false:
			var write_index : int = 0
			if end_shape[current_row_int].has("!"):
				write_index = end_shape[current_row_int].find("!")
				end_shape[current_row_int].remove_at(write_index)
			for i in range(column_offset):
				end_shape[current_row_int].insert(write_index,  perimeter_rows[0].pop_front())
				write_index += 1
			current_row_int += 1
			
			while perimeter_rows[0].size() > column_offset:
				write_index = 0
				if end_shape[current_row_int].has("!"):
					write_index = end_shape[current_row_int].find("!")
					end_shape[current_row_int].remove_at(write_index)
				end_shape[current_row_int].insert(write_index, perimeter_rows[0].pop_back())
				end_shape[current_row_int].insert(write_index + 1, "!")
				end_shape[current_row_int].insert(write_index + 2, perimeter_rows[0].pop_front())
				current_row_int += 1
			write_index  = 0
			if end_shape.size() - 1 >= current_row_int and end_shape[current_row_int].has("!"):
				write_index = end_shape[current_row_int].find("!")
				end_shape[current_row_int].remove_at(write_index)
			perimeter_rows[0].reverse()
			for character in perimeter_rows[0]:
				end_shape[current_row_int].insert(write_index,  character)
				write_index += 1
			perimeter_rows.remove_at(0)
			column_offset -= 2
			curent_starting_row += 1
			current_row_int = curent_starting_row

		for y in range(end_shape.size()-1, -1, -1):
			for x in range(end_shape[y].size() -1, -1, -1):
				if end_shape[y][x] == "!":
					end_shape[y].remove_at(x)
	
	#convert array back to string
	var temp_shape : String = ""
	for row in range(end_shape.size()): 
		for character in end_shape[row]:
			temp_shape += character
		if end_shape.size()-1 != row:
			temp_shape += "\n"
	
	grid_shape = temp_shape
	
func get_trash_fill()-> int:
	return trash_fill
	
func get_grid_size() -> Vector2:
	var rows : int = grid_shape.count("\n") + 1
	var columns : int = grid_shape.find("\n")
	return Vector2(columns, rows)
	
func _exit_tree() -> void:
	if self.is_queued_for_deletion():
		if Global.camera_manager.held_object == self: 
			Global.camera_manager.held_object = null
