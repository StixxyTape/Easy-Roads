extends TextureProgressBar


var maxTime : int = Global.bubbleTimer
var time : float = 0

func _ready():
	Countdown()

func Countdown():
	max_value = maxTime
	value = time
	
	while time < maxTime:
			await get_tree().create_timer(1).timeout	
			time += 1
			value = time
	queue_free()
