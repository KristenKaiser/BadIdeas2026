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
	return held_merch.back()

func place_held_merch(new_parent : Node3D, offset : Vector3, is_box : bool = false):
	var merch =  pop_last_held_merch()
	merch.scale = Vector3.ONE
	merch.reparent(new_parent)
	offset -= merch.center_offset * Global.grid_size

	if is_box: 
		merch.global_position = offset
	else: 
		merch.global_position = new_parent.global_position + offset

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
	new_item.rotation_degrees = item_Data.item_rotation 
	new_item.get_child(0).rotation_degrees = Vector3.ZERO
	new_item.grid_shape = item_Data.grid_shape
	new_item.center_offset = item_Data.center_offset
	return new_item 
