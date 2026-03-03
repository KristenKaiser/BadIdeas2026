extends CSGCylinder3D
@export var deposit : Node3D
@export var keypad : KeyPad
const Merchandise = preload("uid://8d86k6wj4m5x")

func _ready() -> void:
	keypad.order_item.connect(order_item)

func order_item(item : PackedScene):
	var new_item : Node3D = item.instantiate()
	new_item.set_script(Merchandise)
	deposit.add_child(new_item)
	#new_item.position = deposit.position
