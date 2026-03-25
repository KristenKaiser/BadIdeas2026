extends Node3D
class_name TV
@export var tv_mesh : MeshInstance3D
@export var tv_content : PackedScene
@export var light : OmniLight3D

var base_energy = .1
var flicker_timer = 0.0
var next_flicker_time = 0.0
var current_energy = .1
#enum LightColor  {BASE, WARNING, SPOTLIGHT, FAIL}
@export var light_color = Color(0.297, 0.401, 0.634, 1.0) 
@export var warning_light_color: Color = Color(1.0, 0.561, 0.0, 1.0)
@export var spotlight_light_color : Color= Color(0.778, 0.92, 1.0, 1.0)
@export var fail_light_color : Color= Color(1.0, 0.194, 0.144, 1.0)
@export var fail_light_time : float = .5
var is_base_color : bool = true

func  _ready() -> void:
	create_screen(tv_content)

func reset_color_to_base():
	if is_base_color == false:
		change_light_color(Global.tv_manager.LightColor.BASE)

func change_light_color(new_color : TVManager.LightColor):
	match new_color:
		Global.tv_manager.LightColor.BASE:
			light.light_color = light_color
		Global.tv_manager.LightColor.WARNING:
			light.light_color = warning_light_color
		Global.tv_manager.LightColor.SPOTLIGHT:
			light.light_color = spotlight_light_color
		Global.tv_manager.LightColor.FAIL:
			light.light_color = fail_light_color
			await get_tree().create_timer(fail_light_time).timeout
			light.light_color = light_color

func _process(delta):
	flicker_timer += delta
	
	# Occasional longer dimming (eerie pauses)
	if flicker_timer >= next_flicker_time:
		create_flicker()
		next_flicker_time = flicker_timer + randf_range(1.5, 4.0)  # Long gaps between flickers
	
	light.light_energy = current_energy

func create_flicker():
	# Random choice of flicker type
	var flicker_type = randi() % 3
	
	match flicker_type:
		0:  # Sudden brief dip (most eerie)
			flicker_brief_dip()
		1:  # Slow unsettling fade
			flicker_slow_fade()
		2:  # Stuttering multiple flicks
			flicker_stutter()
	
	var color_shift = Color(
		randf_range(0.8, 1.0),
		randf_range(0.7, 0.95),
		randf_range(0.6, 0.85)
	)
	
	var tween = create_tween()
	tween.set_parallel(true)  
	tween.tween_property(light, "light_energy", 0.3, 0.08)
	#tween.tween_property(light, "light_color", color_shift, 0.08)
	tween.tween_property(light, "light_energy", base_energy, 0.15)
	#tween.tween_property(light, "light_color", light_color, 0.15)
	


func flicker_brief_dip():
	# Sudden darkness, quick recovery - deeply unsettling
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "current_energy", 0.3, 0.08)  # Drop fast
	tween.tween_property(self, "current_energy", base_energy, 0.15)  # Recover slower

func flicker_slow_fade():
	# Eerie slow dimming and brightening
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "current_energy", base_energy * 0.5, 0.4)
	tween.tween_property(self, "current_energy", base_energy, 0.6)

func flicker_stutter():
	# Multiple quick flicks in succession
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	
	for i in range(3):
		tween.tween_property(self, "current_energy", base_energy * 0.6, 0.05)
		tween.tween_property(self, "current_energy", base_energy, 0.07)


func create_screen(sub_scene : PackedScene): 
# Create SubViewport
	var sub_viewport = SubViewport.new()
	sub_viewport.size = Vector2(1920, 1080)
	add_child(sub_viewport)
	
	# Load and add your 2D scene
	var ui_scene :Screen = sub_scene.instantiate()
	ui_scene.parent_tv = self
	sub_viewport.add_child(ui_scene)
	
	# Create material with viewport texture
	var material = StandardMaterial3D.new()
	var viewport_texture = sub_viewport.get_texture()
	material.albedo_texture = viewport_texture
	material.emission_enabled = true
	material.emission_texture = viewport_texture
	material.emission_energy_multiplier = 2.0
	
	# Apply to TV mesh
	tv_mesh.set_surface_override_material(0, material)
