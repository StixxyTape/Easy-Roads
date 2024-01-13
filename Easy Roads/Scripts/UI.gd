extends CanvasLayer

var day_text : String = "00"
var hour : int = 0
var hour_text : String = "00"
var minute : int = 0
var minute_text : String = "00"
var count : bool = false
var tutorialCount : int = 0

@onready var timeLabel : Label = $InfoBoard/Time
@onready var dayLabel : Label = $InfoBoard/Day
@onready var moneyLabel : Label = $InfoBoard/Money
@onready var priceLabel : Label = $Cost/Label

@onready var tutorialLabel : Label = $"Tutorial Text"
@onready var tutorialbgc : TextureRect = $"Tutorial BGC"
@onready var roadArrow : Node2D = $"Arrow Road"
@onready var removeArrow : Node2D = $"Arrow Remove"
@onready var infoArrow : Node2D = $"Arrow Info"

func _ready():
	roadArrow.visible = false
	removeArrow.visible = false
	infoArrow.visible = false
	
	if Global.tutorial:
		tutorialbgc.visible = true
		tutorialLabel.visible = true
	else:
		tutorialbgc.visible = false
		tutorialLabel.visible = false
	
	tutorialLabel.text = ""

func _process(_delta):
	tutorialText()
	if Input.is_action_just_pressed("Left Click"):
		tutorialCount += 1
	
	if Global.time == "play" and !count and !Global.tutorial:
		timeCounting()
		count = true
	elif Global.time == "stop":
		count = false
	
	if hour == 24:
		Global.day += 1
		hour = 0
	
	if minute >= 60:
		hour += 1
		minute = 0
	
	if Global.day < 10:
		day_text = str("0", Global.day)
	else:
		day_text = str(Global.day)
	
	if hour < 10:
		hour_text = str("0", hour)
	else:
		hour_text = str(hour)
	
	if minute < 10:
		minute_text = str("0", minute)
	else:
		minute_text = str(minute)
	
	dayLabel.text = str("Day ", day_text)
	timeLabel.text = str(hour_text, ":", minute_text)
	moneyLabel.text = str("$ ", Global.money)
	priceLabel.text = str("Cost:\n", Global.currentPrice)

func timeCounting():
	while Global.time == "play":
		minute += randi_range(5,15)
		await  get_tree().create_timer(0.5).timeout

func tutorialText():
	match tutorialCount:
		0:
			tutorialLabel.text = "Welcome to Easy Roads"
		1: 
			tutorialLabel.text = "It's your goal to manage this city"
		2:
			tutorialLabel.text = "Each house that spawns has a different destination"
		3:
			tutorialLabel.text = "These destination are the bigger structures on the map"
		4:
			tutorialLabel.text = "You can build roads for the cars\nto drive to their destination"
			roadArrow.visible = true
		5:
			tutorialLabel.text = "Each road has a cost\nso be sure to have enough money to build"
		6:
			tutorialLabel.text = "You can place roads with left click\n you can also hold down to place multiple at once"
		7:
			tutorialLabel.text = "Roads can't be placed on trees"
		8:
			tutorialLabel.text = "While holding left click\nyou can remove roads with also holding right click"
		9:
			tutorialLabel.text = "If you misplaced a road\nyou can delete it with the remove button"
			roadArrow.visible = false
			removeArrow.visible = true
		10:
			tutorialLabel.text = "Once the car reached it destination you get money\nand the house asks for a new destination"
			removeArrow.visible = false
		11:
			tutorialLabel.text = "Your money is shown in the top right\n you also see the time and day you're on"
			infoArrow.visible = true
		12:
			tutorialLabel.text = "You can also stop time if it gets too hectic"
		13:
			tutorialLabel.text = "Don't let the cars wait or drive to long\n to reach their destination"
			infoArrow.visible = false
		14:
			tutorialLabel.text = "This was everything\nGood luck"
		15:
			tutorialbgc.visible = false
			tutorialLabel.visible = false
			Global.tutorial = false
