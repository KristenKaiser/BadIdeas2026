extends Node
class_name MerchManager
@export var prototypes : Array[MerchData]
var all_merch : Array[Merchandise]
var held_merch : Array[Merchandise]
const MerchandiseScript = preload("uid://8d86k6wj4m5x")


func add_merch(merch : Merchandise):
	all_merch.append(merch)

func remove_merch(merch : Merchandise):
	while all_merch.has(merch):
		all_merch.erase(merch)

func hold_merch(merch : Merchandise):
	held_merch.append(merch)

func drop_merch(merch : Merchandise):
	while held_merch.has(merch):
		held_merch.erase(merch)

func pop_last_held_merch()-> Merchandise:
	return held_merch.pop_back()

func get_last_held_merch()-> Merchandise:
	if held_merch.is_empty():
		return null
	return held_merch.back()

func place_held_merch(new_parent : Node3D):
	var merch :Merchandise = pop_last_held_merch()
	if merch.ghost != null:
		place_merch_from_ghost(new_parent, merch)
	else: 
		place_merch(new_parent, merch)


func place_merch(new_parent : Node3D, merch : Merchandise):
	Global.camera_manager.held_object = null
	merch.is_held = false
	merch.scale = Vector3.ONE
	merch.reparent(new_parent)
	merch.position = merch.get_pivot_offset()
	if new_parent is Box: 
		merch.location = merch.Location.BOX
	elif new_parent is Camera3D: 
		merch.location = merch.Location.HELD
	elif new_parent is OrderTube: 
		merch.location = merch.Location.ORDER_TUBE

func place_merch_from_ghost(new_parent : Node3D, merch : Merchandise):
	Global.camera_manager.held_object = null
	merch.is_held = false
	merch.scale = Vector3.ONE
	merch.reparent(new_parent)
	merch.global_position = merch.ghost.global_position
	merch.rotation = merch.ghost.rotation
	merch.object_mesh.position = merch.ghost.object_mesh.position
	merch.object_mesh.rotation = merch.ghost.object_mesh.rotation
	
	
	
func get_object_by_code(code: String) -> MerchData:
	for prototype in prototypes:
		if prototype.code == code: 
			return prototype
	return null

func create_from_code(code : String) -> Merchandise:
	var item_Data : MerchData = get_object_by_code(code)
	if item_Data == null : return null
	var new_item : Node3D = item_Data.item.instantiate()
	new_item.set_script(MerchandiseScript)
	new_item.rotation_degrees = Vector3.ZERO
	new_item.get_child(0).rotation_degrees = item_Data.item_rotation 
	new_item.grid_shape = item_Data.grid_shape
	new_item.center_offset = item_Data.center_offset
	new_item.trash_fill = item_Data.trash_fill
	new_item.merch_name = item_Data.item_name
	new_item.rotate_axis = item_Data.get_rotate_axis_string()
	return new_item 
	
func get_size_from_code(code: String)-> int:
	var item_Data : MerchData = get_object_by_code(code)
	var rows : int = item_Data.grid_shape.count("\n") 
	if rows == -1 : rows = 1
	else: rows += +1
	var columns : int = item_Data.grid_shape.find("\n")
	if columns == -1 : columns = item_Data.grid_shape.length()
	return rows * columns
