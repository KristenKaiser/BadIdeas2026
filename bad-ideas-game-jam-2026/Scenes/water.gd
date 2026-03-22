extends Node3D
var is_held : bool = false
@export var bottle : Bottle
var tween: Tween
var pee_time : float = 1.0


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_held == false: 
				grab_water()
			

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			if is_held == false:
				return
			if bottle.is_open == false:
				bottle.open()
			elif bottle.is_full_water:
				drink_water()
			elif bottle.is_full_water == false and bottle.is_open:
				bottle.close()
		if OS.get_keycode_string(event.keycode) == "P" and event.pressed:
			pee()
	
func grab_water():
	if Global.camera_manager.held_object != null:
		return
	Global.camera_manager.held_object = self
	is_held = true
	self.reparent(Global.camera_manager.current)
	position = Vector3(0, -.2 ,-.45)

func drink_water():
	Global.camera_manager.is_locked = true
	if is_held == false: 
		return
	if tween and tween.is_running():
		return
	Global.camera_manager.is_locked = true
	tween = create_tween()
	tween.tween_property(self, "rotation_degrees",Vector3(60, 0,0), .5 )
	await tween.finished
	##TODO drink minigame hit spave on the beat
	await get_tree().create_timer(1).timeout
	bottle.get_node("bottle").get_active_material(0).albedo_color = Color(1.0, 1.0, 1.0, 0.518)
	tween = create_tween()
	tween.tween_property(self, "rotation_degrees",Vector3(0, 0,0), .5 )
	await tween.finished
	Global.healh_manager.drink()
	bottle.is_full_water = false
	Global.camera_manager.is_locked = false

func pee():
	if bottle.is_full_water:
		return
	if is_held == false:
		return
	Global.camera_manager.is_locked = true
	var original_position : Vector3 = position
	if tween and tween.is_running():
		await tween.finished
	tween = create_tween()
	tween.tween_property(self, "position", position - Vector3(0,3,0), 1.0 )
	await tween.finished

	await get_tree().create_timer(pee_time).timeout
	bottle.get_node("bottle").get_active_material(0).albedo_color = Color(1.0, 1.0, 0.0, 0.906)
	tween = create_tween()
	tween.tween_property(self, "position", original_position, 1.0 )
	await tween.finished
	Global.healh_manager.pee()
	Global.camera_manager.is_locked = false
