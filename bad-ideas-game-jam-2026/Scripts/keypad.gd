
extends Node3D
class_name KeyPad

@export var buttons: Array[Button3D]
@export var display_label : Label3D
var keypad_input : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_label.text = keypad_input
	for button in buttons:
		button.backspace_button_pressed.connect(backspace)
		button.clear_button_pressed.connect(clear_input)
		button.num_button_pressed.connect(append_num)


func backspace():
	keypad_input = keypad_input.left(keypad_input.length()-1)
	display_label.text = keypad_input
	
func clear_input():
	keypad_input = ""
	display_label.text = keypad_input

func append_num(value : String):
	keypad_input += value
	display_label.text = keypad_input
