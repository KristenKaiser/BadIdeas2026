extends Merchandise
class_name Water
#var is_held : bool = false
@export var bottle : Bottle
var tween: Tween
var pee_time : float = 1.0
var is_peeing : bool = false
var is_written_up_pee : bool = false
var is_drinking : bool = false
var is_written_up_drink : bool = false
var is_observed : bool = false
const WATER = preload("uid://dg21mddb1l2b5")
@export var is_stash : bool = false # when true grabbing a water will instantiate a new water to grab



func _ready() -> void:
	Global.penopticon.spotlight_on_cell.connect(observed)
	Global.penopticon.spotlight_off_cell.connect(unobserved)
	object_mesh = bottle.bottle
	
func get_mesh()-> MeshInstance3D:
	return bottle.bottle

func get_area3d()->Area3D:
	return bottle.get_node("area3D")

func observed():
	is_observed = true
	if is_drinking and is_written_up_drink == false: 
		recieve_writeup(Global.ui.metrics_card.Writeup.DRINKING)
		is_written_up_drink = true
	if is_peeing and is_written_up_drink == false: 
		recieve_writeup(Global.ui.metrics_card.Writeup.PEEING)
		is_written_up_pee = true 
	

func unobserved():
	is_observed = false
	is_written_up_drink = false
	is_written_up_pee = false


func recieve_writeup(reason : MetricsReport.Writeup):
	Global.ui.metrics_card.writeup(reason)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_held == false:
				if is_stash: 
					create_water()
				else: 
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
	
func create_water():
	if Global.camera_manager.held_object != null:
		return
	var new_water : Water = WATER.instantiate()
	
	Global.camera_manager.held_object = new_water 
	new_water.is_held = true
	Global.camera_manager.current.add_child(new_water)
	new_water.position = Vector3(0, -.2 ,-.45)

func grab_water():
	if Global.camera_manager.held_object != null:
		return
	remove_from_box.emit(global_position, self)
	Global.camera_manager.held_object = self
	is_held = true
	if self.get_parent() == null:
		Global.camera_manager.current.add_child(self)
	else:
		reparent(Global.camera_manager.current)
	position = Vector3(0, -.2 ,-.45)

func drink_water():
	is_drinking = true
	if is_observed and is_written_up_drink == false:
		recieve_writeup(Global.ui.metrics_card.Writeup.DRINKING)
		is_written_up_drink = true
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
	is_drinking = false

func pee():
	
	if bottle.is_full_water:
		return
	if is_held == false:
		return
	is_peeing = true
	if is_observed and is_written_up_pee == false:
		recieve_writeup(Global.ui.metrics_card.Writeup.PEEING)
		is_written_up_pee = true
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
	is_peeing = false
