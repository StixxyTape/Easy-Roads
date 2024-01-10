extends TextureProgressBar

@onready var anim : AnimationPlayer = $AnimationPlayer

var maxTime : int = Global.bubbleTimer
var time : float = 0
var dangerZone : bool = false
var count : bool = false

func _process(_delta):
	if Global.time == "play" and !count:
		Countdown()
	elif Global.time == "stop":
		count = false

func Countdown():
	count = true
	value = time
	print(max_value)
	
	while time < maxTime and count:
		await get_tree().create_timer(1).timeout
		if count:
			time += 1
			
			if time > maxTime - 10 and !dangerZone:
				anim.play("Danger")
				dangerZone = true
			
			value = time
