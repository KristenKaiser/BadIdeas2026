extends Node3D
class_name BoxModel

@export var cube : MeshInstance3D
@export var front_flap : MeshInstance3D
@export var back_flap : MeshInstance3D
@export var right_flap : MeshInstance3D
@export var left_flap : MeshInstance3D

var is_left_open :bool = true
var left_closed : Vector3 = Vector3(-90, 180, 90)
var left_open : Vector3 = Vector3(45, 180, 90)

var is_right_open :bool = true
var right_closed : Vector3 = Vector3(-90, 0, -90)
var right_open : Vector3 = Vector3(135, 0, -90)

var is_back_open :bool = true
var back_closed : Vector3 = Vector3(-90, 90, 90)
var back_open : Vector3 = Vector3(45, 90, 90)

var is_front_open :bool = true
var front_closed: Vector3 = Vector3(270, 90, -90)
var front_open : Vector3 = Vector3(135
, 90, -90)


func _ready() -> void:
	front_flap.rotation_degrees = front_open
	back_flap.rotation_degrees = back_open
	left_flap.rotation_degrees = left_open
	right_flap.rotation_degrees = right_open

func move_flap(flap : String): 
	print("move flap")
	var tween = get_tree().create_tween()
	var active_flap : MeshInstance3D
	var new_rotation : Vector3
	match flap: 
		"left":
			active_flap = left_flap
			new_rotation = left_closed if is_left_open else left_open
			is_left_open = !is_left_open
			
		"right":
			active_flap = right_flap
			new_rotation = right_closed if is_right_open else right_open
			is_right_open = !is_right_open
		"back":
			active_flap = back_flap
			new_rotation = back_closed if is_back_open else back_open
			is_back_open = !is_back_open
		"front":
			active_flap = front_flap
			new_rotation = front_closed if is_front_open else front_open
			is_front_open = !is_front_open
	tween.tween_property(active_flap, "rotation_degrees", new_rotation, 0.5)



### y and z are flipped in th modela
#func get_box_size() -> Vector3:
	#var size :Vector3  = cube.mesh.get_aabb().size
	##size.x = cube.mesh.get_aabb().size.x
	##size.y = cube.mesh.get_aabb().size.z
	##size.z = cube.mesh.get_aabb().size.y
	##size.x += back_flap.get_aabb().size.x + front_flap.get_aabb().size.x
	##size.z += get_flap_z_offset()
	##size.y += right_flap.get_aabb().size.z + left_flap.get_aabb().size.z
	#return size/scale
	#

func get_flap_z_offset()->float:
	var biggest_z : float = 0.0
	for flap in [left_flap, right_flap, front_flap, back_flap]:
		if flap.get_aabb().size.z > biggest_z:
			biggest_z = flap.get_aabb().size.z
	return biggest_z
	
func get_is_box_closed()->bool:
	if !is_left_open and !is_right_open and !is_back_open and !is_front_open: 
		return true
	return false
		
