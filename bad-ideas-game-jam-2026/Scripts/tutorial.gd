extends CanvasLayer
class_name TutorialManager

var is_talking : bool = false
signal input_received
signal tutorial_step_complete
enum Tutorials {WELCOME, ORDER, PLACE, CLOSE, TAPE, ADDRESS, ALONE, METRICS,WATCHING, DRINK, DRINKUI, PEE, PEEUI}
var tutorial_status : Dictionary[Tutorials, bool] = {
	Tutorials.WELCOME: false, 
	Tutorials.ORDER: false, 
	Tutorials.PLACE: false, 
	Tutorials.CLOSE: false, 
	Tutorials.TAPE: false, 
	Tutorials.ADDRESS: false, 
	Tutorials.ALONE: false, 
	Tutorials.METRICS: false ,
	Tutorials.WATCHING: false, 
	Tutorials.DRINK: false, 
	Tutorials.DRINKUI: false, 
	Tutorials.PEE: false, 
	Tutorials.PEEUI: false
	}

@export var label : RichTextLabel
@export var dismiss_label : Label
enum TutorialsTexts {WELCOME, ORDER1, ORDER2, PLACE, CLOSE, TAPE1, TAPE2, ADDRESS, ALONE1, ALONE2, METRICS1, METRICS2, METRICS3 ,METRICS4, WATCHING, DRINK, DRINKUI1, DRINKUI2, PEE, PEEUI1, PEEUI2}
var tutorial_text : Dictionary[TutorialsTexts, String] ={
	TutorialsTexts.WELCOME: "Welcome employee *2159982* to your first day at Two-Day Shipping Inc. We hope you will find career success at your new position *PACKAGE FULFILMENT*.",
	TutorialsTexts.ORDER1: "To begin please order the item *Twoi* from the merchandise tube to your right. The code is 337",
	TutorialsTexts.ORDER2: "You can find reference to all merchandise numbers on the poster behind the merchandise tube or the catalogue below the poster.",
	TutorialsTexts.PLACE: "Place the Twoi in the box. You may rotate merchandise using the q and e keys.",
	TutorialsTexts.CLOSE: "Once you have filled your box close it with the w s a d keys.",
	TutorialsTexts.TAPE1: "Tape your box by repeatedly pressing the space bar",
	TutorialsTexts.TAPE2: "Right-click to exit the box.",
	TutorialsTexts.ADDRESS: "Finally print the mailing address at the printer behind the conveyer belt and attach it to the box.",
	TutorialsTexts.ALONE1 : "Great! I’ll let you handle the next few boxes on your own.",
	TutorialsTexts.ALONE2 : "Remember Two-Day Shipping Inc. is ALWAYS WATCHING",
	TutorialsTexts.METRICS1: "At the end of every day you will receive a report on your daily work. Including any writeups you may have earned. ",
	TutorialsTexts.METRICS2: "Please be aware having 3 active writeups for the same infraction or having 6 total writeups will result in termination.",
	TutorialsTexts.METRICS3: "All of today’s writeups will be cleared immediately to account for training",
	TutorialsTexts.METRICS4: "Remember Two-Day Shipping Inc. is ALWAYS WATCHING",
	TutorialsTexts.WATCHING: "the Boss isn’t always watching,\nBoss can only see one person at a time.\nThe lights always turn orange\nright before they look at you. ",
	TutorialsTexts.DRINK: "This is thirsty work,\nbe sure to check your vitals\nshown on the health monitor\nto the right.\nAnd don’t let them\ncatch you drinking.",
	TutorialsTexts.DRINKUI1:"Press space to open the water",
	TutorialsTexts.DRINKUI2:"Press space to drink water",
	TutorialsTexts.PEE: "If your bladder\nis getting full\none of those\nempty water bottles\nyou saved\nwill be useful.",
	TutorialsTexts.PEEUI1 : "Press p to pee in bottle",
	TutorialsTexts.PEEUI2 : "Be sure to throw your full bottles away"
}
var welcome : Array[String] = [tutorial_text[TutorialsTexts.WELCOME]]
var order : Array[String] = [tutorial_text[TutorialsTexts.ORDER1], tutorial_text[TutorialsTexts.ORDER2]]
var place : Array[String] = [tutorial_text[TutorialsTexts.PLACE]]
var close : Array[String] = [tutorial_text[TutorialsTexts.CLOSE]]
var tape : Array[String] = [tutorial_text[TutorialsTexts.TAPE1], tutorial_text[TutorialsTexts.TAPE2]]
var address : Array[String] = [tutorial_text[TutorialsTexts.ADDRESS]]
var alone : Array[String] = [tutorial_text[TutorialsTexts.ALONE1], tutorial_text[TutorialsTexts.ALONE2]]
var metrics : Array[String] = [tutorial_text[TutorialsTexts.METRICS1], tutorial_text[TutorialsTexts.METRICS2], tutorial_text[TutorialsTexts.METRICS3], tutorial_text[TutorialsTexts.METRICS4]]
var drinkui: Array[String] = [tutorial_text[TutorialsTexts.DRINKUI1], tutorial_text[TutorialsTexts.DRINKUI2]]
var peeui: Array[String] = [tutorial_text[TutorialsTexts.PEEUI1], tutorial_text[TutorialsTexts.PEEUI2]]

func _ready() -> void:
	Global.tutorial_manager = self
	
	start_tutorial()
	
	
func test():
	print("test")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_SHIFT and event.pressed :
		input_received.emit()

func display_overseer_text(texts : Array[String], status_update : Tutorials ):
	while is_talking == true:
		await input_received
	tutorial_status[status_update] = true
	is_talking = true
	for text in texts:
		label.text = text
		dismiss_label.show()
		await input_received
	
	tutorial_step_complete.emit()
	label.text = ""
	dismiss_label.hide()
	is_talking = false
	if status_update == Tutorials.ALONE:
		for box in Global.box_manager.boxes:
			if box.is_tutorial:
				box.current_state = Box.State.CONVEYING

func get_friend_note()->String:
	if tutorial_status[Tutorials.WATCHING] == false: 
		tutorial_status[Tutorials.WATCHING] = true
		Global.healh_manager.is_health_tracking_paused = false
		return tutorial_text[TutorialsTexts.WATCHING]
	
	elif tutorial_status[Tutorials.DRINK] == false: 
		tutorial_status[Tutorials.DRINK] = true
		
		return tutorial_text[TutorialsTexts.DRINK]
	
	elif tutorial_status[Tutorials.PEE] == false: 
		tutorial_status[Tutorials.PEE] = true
		return tutorial_text[TutorialsTexts.PEE]
	return ""

func is_more_friend_text()-> bool:
	if tutorial_status[Tutorials.WATCHING] == false or\
	tutorial_status[Tutorials.DRINK] == false or\
	tutorial_status[Tutorials.PEE] == false:
		return true
	return false

func start_tutorial():
	Global.current_boxes_per_day = 4
	Global.healh_manager.is_health_tracking_paused = true
	await display_overseer_text(welcome, Tutorials.WELCOME)
	await display_overseer_text(order, Tutorials.ORDER)
	

func end_tutorial():
	Global.current_boxes_per_day = Global.base_boxes_per_day
	Global.mertics_report.is_tutorial_day = true
	
	
