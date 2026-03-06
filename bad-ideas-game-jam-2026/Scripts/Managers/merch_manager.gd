extends Node
class_name MerchManager

var all_merch : Array[Merchandise]
var held_merch : Array[Merchandise]

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
	if is_box: 
		merch.global_position = offset
	else: 
		merch.global_position = new_parent.global_position + offset
