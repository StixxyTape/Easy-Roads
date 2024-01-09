extends TextureProgressBar


var maxTime : int = Global.bubbleTimer
var time : float = 0

func _ready():
	
	Countdown()
	
func Countdown():
	max_value = maxTime
	value = time
	
	var wait = false
	
	while true:
		if time >= maxTime:
			break
		if !wait:
			wait = true
			await get_tree().create_timer(0.2).timeout	
			time += 0.2
			value = time
			wait = false
			
	queue_free()
