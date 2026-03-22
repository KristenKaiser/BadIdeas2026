extends Node

@export var conveyer_speed: float =.1
var conveyer_speed_increase: float =.05
var slow_conveyer_speed: float =.1
var fast_conveyer_speed: float = 1
var box_drop_speed: float =.8
var grid_size : float  = .1 # 1.0/6.0
var base_boxes_per_day : int = 7
var current_boxes_per_day : int 
var metrics_tv : MetricsScreen
var health_tv : HealthScreen
var blur : Blur

const MERCH_MANAGER = preload("uid://cpxhjnah05wv6")
var merch_manager : MerchManager 

const CAMERA_MANAGER = preload("uid://w47oe1a1j5pu")
var camera_manager : CameraManager

const BOX_MANAGER = preload("uid://bo1cyd553pjcu")
var box_manager : BoxManager

const SCORE_MANAGER = preload("uid://7ho1x50016pi")
var score_manager : ScoreManager

const HEALTH_MANAGER = preload("uid://84chghh6wnhi")
var healh_manager : HealthManager

var ui : UI

func _ready() -> void:
	current_boxes_per_day = base_boxes_per_day
	start_game()

func start_game():
	merch_manager = MERCH_MANAGER.instantiate()
	add_child(merch_manager)
	
	camera_manager = CAMERA_MANAGER.instantiate()
	add_child(camera_manager)
	
	box_manager = BOX_MANAGER.instantiate()
	add_child(box_manager)
	
	score_manager = SCORE_MANAGER.instantiate()
	add_child(score_manager)
	
	healh_manager = HEALTH_MANAGER.instantiate()
	add_child(healh_manager)
	
	
func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey:
			if OS.get_keycode_string(event.keycode) == "2" and event.pressed:
				conveyer_speed = fast_conveyer_speed
			if OS.get_keycode_string(event.keycode) == "2" and event.pressed == false:
				conveyer_speed = slow_conveyer_speed
			if OS.get_keycode_string(event.keycode) == "1" and event.pressed:
				if conveyer_speed == 0:
					conveyer_speed = slow_conveyer_speed
				else:
					conveyer_speed = 0


func fit_collision_to_meshes(node_3d: Node3D, collision_shape: CollisionShape3D) -> void:
	# Collect all MeshInstance3D children of node_3d
	var mesh_instances: Array[MeshInstance3D] = []
	for child in node_3d.get_children():
		if child is MeshInstance3D:
			mesh_instances.append(child)

	if mesh_instances.is_empty():
		return

	# Build a combined AABB in global space
	var global_aabb: AABB

	for mesh_inst in mesh_instances:
		if mesh_inst.mesh == null:
			continue

		# Get the mesh's local AABB, then transform it to global space
		# using the MeshInstance3D's global transform (which includes node_3d's scale)
		var local_aabb: AABB = mesh_inst.mesh.get_aabb()
		var global_mesh_aabb: AABB = mesh_inst.global_transform * local_aabb

		if global_aabb == AABB():
			global_aabb = global_mesh_aabb
		else:
			global_aabb = global_aabb.merge(global_mesh_aabb)

	# Convert global AABB into the Area3D's parent local space.
	# collision_shape is a child of Area3D, so we work in Area3D's transform space.
	var area_3d: Area3D = collision_shape.get_parent()
	var area_global_xform: Transform3D = area_3d.global_transform

	# Transform the 8 corners of the global AABB into Area3D local space,
	# then re-compute the AABB (handles rotation differences)
	var local_aabb_final: AABB
	var corners := [
		global_aabb.position,
		global_aabb.position + Vector3(global_aabb.size.x, 0, 0),
		global_aabb.position + Vector3(0, global_aabb.size.y, 0),
		global_aabb.position + Vector3(0, 0, global_aabb.size.z),
		global_aabb.position + Vector3(global_aabb.size.x, global_aabb.size.y, 0),
		global_aabb.position + Vector3(global_aabb.size.x, 0, global_aabb.size.z),
		global_aabb.position + Vector3(0, global_aabb.size.y, global_aabb.size.z),
		global_aabb.position + global_aabb.size,
	]

	for i in corners.size():
		var local_pt: Vector3 = area_global_xform.affine_inverse() * corners[i]
		if i == 0:
			local_aabb_final = AABB(local_pt, Vector3.ZERO)
		else:
			local_aabb_final = local_aabb_final.expand(local_pt)

	# Apply to the CollisionShape3D
	var box := BoxShape3D.new()
	box.size = local_aabb_final.size
	collision_shape.shape = box
	collision_shape.position = local_aabb_final.get_center()
	
