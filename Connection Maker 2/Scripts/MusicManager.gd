extends AudioStreamPlayer2D

func _process(_delta):
	if Global.music:
		volume_db = 0
	else:
		volume_db = -100
