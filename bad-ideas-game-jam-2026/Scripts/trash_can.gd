extends CSGBox3D
class_name  TrashCan
var capacity : int = 1
var trash_fill : int = 0
@export var label : Label3D
const TRASH_BAG = preload("uid://cl1qnrmj2sti4")



func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if trash_fill >= capacity: 
				empty_trash()
			else:
				throw_away_held_object()
				

func throw_away_held_object():
	if Global.camera_manager.held_object != null:
		#if trash_fill >= capacity: 
			#return
		if Global.merch_manager.get_last_held_merch() == Global.camera_manager.held_object:
			Global.merch_manager.pop_last_held_merch()
		if Global.camera_manager.held_object.has_method("get_trash_fill"):
			trash_fill += Global.camera_manager.held_object.get_trash_fill()
		else:
			trash_fill += 1
		Global.camera_manager.held_object.queue_free()
		if trash_fill >= capacity: 
			show_trash_full()
			
func show_trash_full():
	label.text = "TRASH\nFULL"

func show_trash_empty(): 
	label.text = "TRASH"

func empty_trash():
	show_trash_empty()
	if Global.camera_manager.held_object != null:
		return
	var trash_bag : TrashBag= TRASH_BAG.instantiate()
	trash_bag.trash_fill = trash_fill
	trash_fill = 0
	Global.camera_manager.hold_item(trash_bag, trash_bag.get_node("Mesh"))
