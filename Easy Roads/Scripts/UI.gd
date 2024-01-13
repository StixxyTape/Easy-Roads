extends CanvasLayer

var day_text : String = "00"
var hour : int = 0
var hour_text : String = "00"
var minute : int = 0
var minute_text : String = "00"
var count : bool = false

@onready var timeLabel : Label = $InfoBoard/Time
@onready var dayLabel : Label = $InfoBoard/Day
@onready var moneyLabel : Label = $InfoBoard/Money
@onready var priceLabel : Label = $Cost/Label

func _process(_delta):
	if Global.time == "play" and !count:
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
		minute += randi_range(5,5)
		await  get_tree().create_timer(0.5).timeout
