extends MeshInstance3D
var cylinder_radius : float = 24.9
var cylinder_height : float= 100.0
var screens_around : float= 20
var screens_vertical : float= 20
var screen_size : Vector3 = Vector3(6.5, 3, .1) #Vector3(1.125, 5.0, .1)
@export var player_window : MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_cells()


func create_cells():
	#var player_window_aabb = player_window.get_aabb()
	#var player_window_global_aabb = AABB(player_window.global_position + player_window_aabb.position, player_window_aabb.size)
	#player_window_global_aabb.position += player_window.global_position
	
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = screens_around * screens_vertical 

	var screen_mesh = BoxMesh.new()
	screen_mesh.size = screen_size
	multimesh.mesh = screen_mesh

	var screen_material = StandardMaterial3D.new()
	screen_material.albedo_color = Color(0.0, 0.016, 0.181, 1.0)
	screen_material.emission_enabled = true
	screen_material.emission = Color(0.0, 0.016, 0.181, 1.0)
	screen_material.emission_energy_multiplier = 1.0

	var multimesh_instance = MultiMeshInstance3D.new()
	multimesh_instance.multimesh = multimesh
	multimesh_instance.material_override = screen_material
	add_child(multimesh_instance)


	# Position each screen on the cylinder interior
	var screen_index = 0
	for row in range(screens_vertical):
		for col in range(screens_around):
			var angle = (float(col) / screens_around) * TAU
			
			var x = cos(angle) * cylinder_radius
			var z = sin(angle) * cylinder_radius
			var y = (cylinder_height / 2.0) - (row * (cylinder_height / screens_vertical))
			
			#skip placing window on player window
			var screen_position = Vector3(x, y, z)
		
		# Check if this screen would overlap with the player_window
			if is_position_occupied_by_player_window(screen_position):
				#print("skip")
				continue  # Skip this screen
			
			var cell_transform = Transform3D()
			cell_transform.origin = Vector3(x, y, z)
			
			# Rotate to face the center of the cylinder
			# The screen's local -Z axis should point toward center (0, y, 0)
			var direction_to_center = Vector3.ZERO - cell_transform.origin
			direction_to_center.y = 0  # Ignore vertical component
			direction_to_center = direction_to_center.normalized()
			
			# Create basis where -Z faces the center
			cell_transform.basis = Basis.looking_at(-direction_to_center, Vector3.UP)
			
			multimesh.set_instance_transform(screen_index, cell_transform)
			screen_index += 1

		
	# Update instance count to match actual screens placed
	#multimesh.instance_count = screen_index + 1

func is_position_occupied_by_player_window(test_position: Vector3) -> bool:

	var player_window_pos = player_window.position # .global_position
	var player_window_size = player_window.mesh.size if player_window.mesh else Vector3(1, 1, 1)

	# Create an AABB for the player window
	var player_window_aabb = AABB(player_window_pos - player_window_size / 2.0, player_window_size)

	# Create an AABB for the screen

	var screen_aabb = AABB(test_position - screen_size / 2.0, screen_size)
	#if (screen_aabb.get_center() -player_window_aabb.get_center()).abs() < player_window_aabb.size:
	
	print("screen")
	#print_aabb_corners(screen_aabb)
	##print("window")
	##print_aabb_corners(player_window_aabb)
	#print("---------------------")

	# Check if they intersect
	return player_window_aabb.intersects(screen_aabb)


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
