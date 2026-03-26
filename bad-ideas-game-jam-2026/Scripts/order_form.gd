extends MeshInstance3D
class_name OrderForm
@export var label : Label3D
@export var collision_shape : CollisionShape3D
var parent_box : Box
var is_zoomed : bool = false
var requested_items : Dictionary[String, int]
var generated_items : Array[Merchandise] = []
var flat_rotation = Vector3(-90, 0, 0)


func _ready() -> void:	
	await get_tree().process_frame
	resize_mesh_to_label()
	scale = Vector3(.1,.1,.1)
	collision_shape.shape.size = get_aabb().size
	collision_shape.position = Vector3.ZERO
	position = get_home_position()
	rotation_degrees = flat_rotation
	
func write_to_label(text :String):
	label.text += text
	resize_mesh_to_label.call_deferred()

func resize_mesh_to_label():
	var label_aabb = label.get_aabb()
	var local_size = label_aabb.size / label.global_transform.basis.get_scale()

	var padding = Vector2(0.2, 0.1)

	mesh.size = Vector3(
		local_size.x + padding.x,
		local_size.y + padding.y,
		mesh.size.z
	)

func write_requested_items():
	for item in requested_items:
		write_to_label("%s x %s\n"% [item, requested_items[item]])

func get_home_position()-> Vector3:
	var home_position : Vector3
	home_position.y = -parent_box.box_collision_shape.shape.size.y / 2 + .03
	home_position.x = (-parent_box.box_collision_shape.shape.size.x / 2) - (get_aabb().size.x * scale.x)
	home_position.z = 0
	return home_position
	

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_zoomed:
				is_zoomed = false
				position = get_home_position()
				rotation_degrees = flat_rotation
			else: 
				is_zoomed = true
				global_position = parent_box.global_position
				position.y += .3
				rotation = Global.camera_manager.current.rotation
				

func generate_order():
	var possible_boxes = Global.box_manager.generate_box_sizes()
	var box_size : String = possible_boxes.pick_random()
	var max_empty_spaces : int = Global.box_manager.box_empty_fill[box_size]
	var box_area : int = Global.box_manager.sizes[box_size].x * Global.box_manager.sizes[box_size].y * Global.box_manager.sizes[box_size].z
	var available_box_area : int = box_area
	parent_box.set_box_size(box_size)
	write_requested_items()
	var max_attempts : int = 20
	while available_box_area > max_empty_spaces and max_attempts > 0:
		place_merch(box_size, available_box_area)
		available_box_area = 0
		for y in range(parent_box.grid_statuses.size()):
			for x in range(parent_box.grid_statuses[y].size()):
				if parent_box.grid_statuses[y][x]== false:
					available_box_area += 1
		max_attempts -= 1
	for item in range(generated_items.size() - 1, -1, -1):
		generated_items[item].queue_free()
	for row in parent_box.grid_statuses:
		row.fill(false)
	write_requested_items()

func place_merch(box_size : String, available_box_area : int, code : String = ""): 
	var box_area : int = Global.box_manager.sizes[box_size].x * Global.box_manager.sizes[box_size].y * Global.box_manager.sizes[box_size].z
	if code == "":
		var is_code_picked: bool = false
		while is_code_picked == false:
			code = Global.merch_manager.prototypes.pick_random().code
			if Global.merch_manager.get_size_from_code(code) <= available_box_area:
				is_code_picked = true
			
	var current_merch : Merchandise = Global.merch_manager.create_from_code(code)
	
	parent_box.add_child(current_merch)
	current_merch.rotation_degrees = Vector3(0, -90, -90)
	
	var y_max : float = ((Global.box_manager.sizes[box_size].z/2.0) * Global.grid_size) - (Global.grid_size / 2.0)
	var x_max : float = ((Global.box_manager.sizes[box_size].x/2.0) * Global.grid_size) - (Global.grid_size / 2.0)
	
	for i in range(randi_range(0,3)):
		current_merch.turn(true)
	
	var successful_placement : bool = false
	var max_placement_attempts = box_area
	while successful_placement == false and max_placement_attempts >= 0:
		var random_position : Vector3 = Vector3(\
			randi_range(0, int((x_max * 2)/ Global.grid_size ) ),\
			-Global.grid_size / 2.0,
			randi_range(0, int((y_max * 2)/ Global.grid_size )) 
		)
		var new_position : Vector3 = Vector3((random_position.x* Global.grid_size) - x_max, -Global.grid_size / 2.0,(random_position.z * Global.grid_size) - y_max )
		new_position= parent_box.snap_to_grid(new_position)
		max_placement_attempts -= 1
		if parent_box.add_to_grid(Vector2(new_position.x, new_position.z),  current_merch.grid_shape) == true: 
			current_merch.position = new_position
			successful_placement = true
	
	if successful_placement == false: 
		
		for y_axis in range(int((y_max * 2)/ Global.grid_size ) + 1):
			for x_axis in range(int((x_max *2 )/ Global.grid_size ) + 1):
				var new_position : Vector3 = Vector3((x_axis* Global.grid_size) - x_max, -Global.grid_size / 2.0,(y_axis * Global.grid_size) - y_max )
				new_position = parent_box.snap_to_grid(new_position)
				if parent_box.add_to_grid(Vector2(new_position.x, new_position.z),  current_merch.grid_shape) == true: 
					current_merch.position = new_position
					successful_placement = true
					break
			if successful_placement: 
				break
	
	if successful_placement == true: 
		#requested_items.append(current_merch.merch_name)
		if requested_items.has(current_merch.merch_name):
			requested_items[current_merch.merch_name] += 1
		else: 
			requested_items[current_merch.merch_name] = 1

		generated_items.append(current_merch)
	else: 
		current_merch.queue_free()
