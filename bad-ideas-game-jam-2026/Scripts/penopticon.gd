extends MeshInstance3D
class_name Penopticon

var cylinder_radius : float = 24.9
var cylinder_height : float= 60
var cells_around : int = 19
var cells_vertical : int = 15
var cell_size : Vector3 = Vector3(6.5, 3, .1) 
var prev_warning_move : Vector2i = Vector2(1,0)
@export var player_window : MeshInstance3D
@export var spotlight : SpotLight3D
var cell_positions : Array[Array] = []
var warning_cell : MeshInstance3D
var spotlight_cell : MeshInstance3D
var timer : Timer
var current_warning_cell : Vector2i = Vector2i(1,1)
var current_spotlight_cell: Vector2i
var previous_spotlight_cell: Vector2i
var home_cell : Vector3
@export var spotlight_glare : MeshInstance3D
signal spotlight_on_cell
signal spotlight_off_cell

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.penopticon = self
	position.y -= 1
	cell_positions.resize(cells_around)
	for i in range(cells_around):
		var new_array : Array = []
		new_array.resize(cells_vertical)
		cell_positions[i] = new_array
	
	create_cells()
	warning_cell = create_moving_cell(.1, Color(0.577, 0.376, 0.192, 1.0))
	move_moving_cell(cell_positions[floor(cells_vertical*.95)][floor(cells_vertical/2.0)], warning_cell)
	current_warning_cell = Vector2i(floor(cells_vertical*.95),floor(cells_vertical/2.0))
	spotlight_cell = create_moving_cell(0, Color(1.0, 1.0, 1.0, 1.0))
	move_moving_cell(cell_positions[floor(cells_vertical*.95)-1][floor(cells_vertical/2.0)], spotlight_cell)
	move_spotligt(Vector2(floor(cells_vertical*.95)-1,floor(cells_vertical/2.0)))
	
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(focus_cell)
	add_child(timer)
	timer.start()

func focus_cell():
	previous_spotlight_cell = current_spotlight_cell
	current_spotlight_cell = current_warning_cell
	move_spotligt(current_spotlight_cell)
	move_moving_cell(cell_positions[current_spotlight_cell.x][current_spotlight_cell.y], spotlight_cell)
	var next_position : Vector2i = get_next_focus_cell()
	move_moving_cell(cell_positions[next_position.x][next_position.y], warning_cell)
	
	current_warning_cell = next_position

func move_spotligt(location : Vector2):
	spotlight.position.y = cell_positions[location.x][location.y].y
	var direction_to_cell = -cell_positions[location.x][location.y]
	direction_to_cell.y = 0 
	direction_to_cell = direction_to_cell.normalized()
	spotlight.basis = Basis.looking_at(-direction_to_cell, Vector3.UP)


func get_next_focus_cell()-> Vector2i:
	var north : Vector2i = Vector2i(0, -1)
	var south : Vector2i = Vector2i(0, 1)
	var east : Vector2i = Vector2i(1, 0)
	var west : Vector2i = Vector2i(-1, 0)

	var directions: Array[Vector2i] = [east, west]
	
	if current_warning_cell.y == 0: 
		directions.append(south)
	elif current_warning_cell.y == cells_vertical - 1: 
		directions.append(north)
	else:
		directions.append(north)
		directions.append(south)
	
	match prev_warning_move:
		north:
			directions.erase(south)
		south: 
			directions.erase(north)
		east: 
			directions.erase(west)
		west: 
			directions.erase(east)
	
	var direction = directions.pick_random()
	prev_warning_move = direction
	#account for x looping
	var new_position : Vector2i
	if (current_warning_cell.x + direction.x) % cells_around == 0: 
		new_position= Vector2i(0,current_warning_cell.y + direction.y)
	else: 
		new_position= Vector2i(current_warning_cell.x + direction.x , current_warning_cell.y + direction.y)
	
	return new_position
	

func create_moving_cell(emmisions: float, color : Color = Color.WHITE )->MeshInstance3D:
	var new_cell : MeshInstance3D = MeshInstance3D.new()
	
	var new_cell_mesh : BoxMesh = BoxMesh.new()
	new_cell_mesh.size = Vector3(cell_size.x, cell_size.y, cell_size.z * 2)
	new_cell.mesh = new_cell_mesh
	
	var new_material : StandardMaterial3D = StandardMaterial3D.new()
	new_material.albedo_color = color
	if emmisions != 0: 
		new_material.emission_enabled = true
		new_material.emission = color
		new_material.emission_energy_multiplier = emmisions
	
	new_cell.material_override = new_material
	add_child(new_cell)
	return new_cell


func move_moving_cell(new_position : Vector3, cell : MeshInstance3D):
	cell.position = new_position
	var direction_to_center = Vector3.ZERO - new_position
	direction_to_center.y = 0 
	direction_to_center = direction_to_center.normalized()
	cell.basis = Basis.looking_at(-direction_to_center, Vector3.UP)
	if new_position == home_cell:
		interact_home(cell)
	elif cell.visible == false:
		cell.show()
		# remove spotlight lighting from tvs 
		if cell_positions[previous_spotlight_cell.x][previous_spotlight_cell.y]  == home_cell:
			Global.tv_manager.change_lights(Global.tv_manager.LightColor.BASE)
			spotlight_glare.hide()
			spotlight_off_cell.emit()
			
	
func interact_home(cell : MeshInstance3D): 
	cell.hide()
	if cell == warning_cell: 
		Global.tv_manager.change_lights(Global.tv_manager.LightColor.WARNING)
	if cell == spotlight_cell: 
		spotlight_glare.show()
		Global.tv_manager.change_lights(Global.tv_manager.LightColor.SPOTLIGHT)
		spotlight_on_cell.emit()

	
		
func create_cells():
	var multimesh : MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = cells_around * cells_vertical 

	var cell_mesh : BoxMesh = BoxMesh.new()
	cell_mesh.size = cell_size
	multimesh.mesh = cell_mesh

	var cell_material : StandardMaterial3D = StandardMaterial3D.new()
	cell_material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	cell_material.emission_enabled = true
	cell_material.emission = Color(0.0, 0.016, 0.181, 1.0)
	cell_material.emission_energy_multiplier = 1.0

	var multimesh_instance = MultiMeshInstance3D.new()
	multimesh_instance.multimesh = multimesh
	multimesh_instance.material_override = cell_material
	add_child(multimesh_instance)

	# Position each cell on the cylinder interior
	var cell_index = 0
	for row in range(cells_vertical):
		for col in range(cells_around):
			var angle = (float(col) / cells_around) * TAU
			
			var x = cos(angle) * cylinder_radius
			var z = sin(angle) * cylinder_radius
			var y = (cylinder_height / 2.0) - (row * (cylinder_height / cells_vertical))
			
			#skip placing window on player window
			var cell_position = Vector3(x, y, z)
			
			cell_positions[col][row] = cell_position
		# Check if this cell would overlap with the player_window
			if is_position_occupied_by_player_window(cell_position):
				home_cell = cell_position
				continue  # Skip this cell
			
			
			var cell_transform = Transform3D()
			cell_transform.origin = Vector3(x, y, z)
			
			# Rotate to face the center of the cylinder
			# The cell's local -Z axis should point toward center (0, y, 0)
			var direction_to_center = Vector3.ZERO - cell_transform.origin
			direction_to_center.y = 0  # Ignore vertical component
			direction_to_center = direction_to_center.normalized()
			
			# Create basis where -Z faces the center
			cell_transform.basis = Basis.looking_at(-direction_to_center, Vector3.UP)
			
			multimesh.set_instance_transform(cell_index, cell_transform)
			cell_index += 1


func is_position_occupied_by_player_window(test_position: Vector3) -> bool:
	var player_window_pos = player_window.position 
	var player_window_size = player_window.mesh.size if player_window.mesh else Vector3(1, 1, 1)
	# Create an AABB for the player window
	var player_window_aabb = AABB(player_window_pos - player_window_size / 2.0, player_window_size)
	# Create an AABB for the cell
	var cell_aabb = AABB(test_position - cell_size / 2.0, cell_size)
	# Check if they intersect
	return player_window_aabb.intersects(cell_aabb)

func print_aabb_corners(aabb : AABB):
	print("center: %s\n
	%s %s \n
	%s %s\n
	\n
	%s %s \n
	%s %s\n" %[aabb.get_center(), 
	aabb.position + Vector3(0, aabb.size.y, 0), aabb.position + Vector3(aabb.size.x, aabb.size.y, 0), 
	aabb.position + Vector3(0, 0, 0), aabb.position + Vector3(aabb.size.z, 0, 0), 
	aabb.position + Vector3(0, aabb.size.y, -aabb.size.z), aabb.position + Vector3(aabb.size.x, aabb.size.y, -aabb.size.z), 
	aabb.position + Vector3(0, 0, -aabb.size.z), aabb.position + Vector3(aabb.size.z, 0, -aabb.size.z)] )
