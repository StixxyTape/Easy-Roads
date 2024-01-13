extends Camera2D

var target_zoom : Vector2
var zoom_speed = 1.1  # Adjust this to control the speed of the zoom

func _ready():
	zoom = Vector2(2,2)

func _process(delta):
	if Input.is_action_just_pressed("Zoom In") and zoom < Vector2(3, 3):
		print("Bruh")
		zoom += Vector2.ONE * 0.1
	if Input.is_action_just_pressed("Zoom Out") and zoom > Vector2(1.2, 1.2):
		print("Bruh")
		zoom -= Vector2.ONE * 0.1
	if Input.is_action_pressed("Left") and position.x > -200:
		position -= Vector2(5, 0)
	if Input.is_action_pressed("Right") and position.x < 200:
		position += Vector2(5, 0)
	if Input.is_action_pressed("Up") and position.y > -200:
		position -= Vector2(0, 5)
	if Input.is_action_pressed("Down") and position.y < 200:
		position += Vector2(0, 5)
	# Smoothly interpolate between the current zoom and the target zoom
	if Global.day == 4:
		target_zoom = Vector2(1.7,1.7)
		zoom = lerp(zoom, target_zoom, delta * zoom_speed)
	elif Global.day == 8:
		target_zoom = Vector2(1.4,1.4)
		zoom = lerp(zoom, target_zoom, delta * zoom_speed)
	elif Global.day == 10:
		target_zoom = Vector2(1.2,1.2)
		zoom = lerp(zoom, target_zoom, delta * zoom_speed)
