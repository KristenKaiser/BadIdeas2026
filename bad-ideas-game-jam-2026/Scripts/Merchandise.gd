extends Node3D
class_name Merchandise

var object_mesh : MeshInstance3D
var is_held : bool = false
var area3d : Area3D
var collision_shape : CollisionShape3D
var grid_shape : String
var center_offset: Vector3 
var trash_fill : int

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
	object_mesh.scale = get_size_from_shape()

func get_size_from_shape() -> Vector3:
	var angle = object_mesh.rotation.z
	var cos_a = absf(cos(angle))
	var sin_a = absf(sin(angle))
	var columns = grid_shape.find("\n")
	var rows = grid_shape.count("\n") + 1
	
	var mesh_w = (columns * Global.grid_size) * cos_a - (rows * Global.grid_size) * sin_a
	var mesh_h = (rows * Global.grid_size) * cos_a - (columns * Global.grid_size) * sin_a
	
	#var transformed_aabb : AABB = object_mesh.get_aabb() * object_mesh.transform
	var x_scale : float = mesh_w / object_mesh.get_aabb().size.x 
	var y_scale: float
	var z_scale : float =  mesh_h / object_mesh.get_aabb().size.z
	
	if x_scale < z_scale: 
		y_scale = x_scale
	else:
		y_scale = z_scale
	
	return Vector3(x_scale, y_scale, z_scale)


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select_object()
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey:
			if is_held == true:
				if OS.get_keycode_string(event.keycode) == "Q" and event.pressed:
					turn(false)
					get_viewport().set_input_as_handled()
				if OS.get_keycode_string(event.keycode) == "E" and event.pressed:
					turn(true)
					get_viewport().set_input_as_handled()
	
func get_mesh()-> MeshInstance3D:
	return object_mesh

func select_object():
	if is_held:
		pass
	else:
		if Global.camera_manager.held_object != null: 
			return
		is_held = true
#		
		Global.camera_manager.hold_item(self, object_mesh)
		Global.merch_manager.hold_merch(self)

func turn(is_right : bool):
	print("turn")
	if is_right: 
		rotate_shape(true)
		update_center_offset(true)
		rotation_degrees.z += 90
	else:
		rotate_shape(false)
		update_center_offset(false)
		rotation_degrees.z -= 90
		
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

	

func rotate_shape(is_to_right : bool ):
	var rows : int = grid_shape.count("\n") + 1
	var start_shape : Array[Array]
	var current_row : Array[String] = []
	
	# put string into Array
	start_shape.append(current_row)
	for i in range(grid_shape.length()):
		var character : String = grid_shape[i]
		if character =="\n":
			var new_row : Array[String] = []
			start_shape.append(new_row)
			current_row = new_row
		else: 
			current_row.append(character)
	
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
	
	#shift parimeter
	var rows_offset = rows - 1
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
	
	#convert parimeter back to rows
	var end_shape : Array[Array]
	end_shape.resize(rows)
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
		if end_shape[current_row_int].has("!"):
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
	
	#convert array back to string
	var temp_shape : String = ""
	for row in end_shape: 
		for character in row:
			temp_shape += character
		if end_shape[end_shape.size()-1] != row:
			temp_shape += "\n"
	print(temp_shape)
	grid_shape = temp_shape
	
func get_trash_fill()-> int:
	return trash_fill
