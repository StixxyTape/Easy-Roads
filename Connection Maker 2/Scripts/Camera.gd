extends Camera2D

var target_zoom : Vector2
var zoom_speed = 1.1  # Adjust this to control the speed of the zoom

func _ready():
	zoom = Vector2(2,2)

func _process(delta):
	# Smoothly interpolate between the current zoom and the target zoom
	if Global.day == 2:
		target_zoom = Vector2(1.7,1.7)
		zoom = lerp(zoom, target_zoom, delta * zoom_speed)
	elif Global.day == 4:
		target_zoom = Vector2(1.4,1.4)
		zoom = lerp(zoom, target_zoom, delta * zoom_speed)
	elif Global.day == 6:
		target_zoom = Vector2(1.2,1.2)
		zoom = lerp(zoom, target_zoom, delta * zoom_speed)
