
extends Node3D
class_name KeyPad

@export var buttons: Array[Button3D]
@export var display_label : Label3D
@export var display : MeshInstance3D
var keypad_input : String = ""
@export var codes_and_items : Dictionary[String, PackedScene]
signal order_item(PackedScene)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_label.text = keypad_input
	for button in buttons:
		button.backspace_button_pressed.connect(backspace)
		button.clear_button_pressed.connect(clear_input)
		button.num_button_pressed.connect(append_num)
		button.enter_button_pressed.connect(call_item)

func backspace():
	keypad_input = keypad_input.left(keypad_input.length()-1)
	display_label.text = keypad_input

func clear_input():
	keypad_input = ""
	display_label.text = keypad_input

func append_num(value : String):
	keypad_input += value
	display_label.text = keypad_input

func call_item():
	if codes_and_items.has(keypad_input):
		print("call item %s" % keypad_input)
		order_item.emit(codes_and_items[keypad_input])
		await display_flash_color(Color.GREEN)
	else:
		await display_flash_color(Color.RED)
	clear_input()

func display_flash_color(color : Color):
	var display_material = display.mesh.surface_get_material(0) as StandardMaterial3D
	var prev_color : Color = display_material.albedo_color
	display_material.albedo_color = color
	await get_tree().create_timer(1).timeout
	display_material.albedo_color = prev_color
