extends Control
class_name Blur
var blur_tween : Tween
@export var rect : ColorRect
var max_blur : float = 10.0
var blur_time : float = 1.5
var is_blurred : bool = false
@export var black : ColorRect
var black_tween : Tween


func _ready() -> void:
	Global.blur = self

func transiton_in():
	is_blurred = true

	if blur_tween:
		blur_tween.kill()
	blur_tween = create_tween()
	var current_blur :float = rect.material.get_shader_parameter("blur_strength")
	blur_tween.tween_method(
		func(value): rect.material.set_shader_parameter("blur_strength", value),
		rect.material.get_shader_parameter("blur_strength"),
		max_blur,
		(blur_time/max_blur) * (max_blur - current_blur)
	)
	
	
func transition_out(): 
	is_blurred = false
	if blur_tween:
		blur_tween.kill()
	blur_tween = create_tween()
	var current_blur :float = rect.material.get_shader_parameter("blur_strength")
	blur_tween.tween_method(
		func(value): rect.material.set_shader_parameter("blur_strength", value),
		rect.material.get_shader_parameter("blur_strength"),
		0,
		(blur_time/max_blur) * (current_blur)
	)

func fade_to_black():
	
	if black_tween: 
		black_tween.kill()
	black_tween = create_tween()
	black_tween.tween_property(black, "color", Color(0.0, 0.0, 0.0, 1.0), .5)
	await black_tween.finished
	rect.material.set_shader_parameter("blur_strength", 0)
	
	
