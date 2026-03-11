extends Node
class_name BoxManager

var boxes : Array[Box]
var box_dropper : BoxDropper
@export var sizes : Dictionary [String, Vector3i]

func add_box(box : Box):
	boxes.append(box)
	if box.get_parent() != null:
		box.reparent(self)
	else:
		add_child(box)
