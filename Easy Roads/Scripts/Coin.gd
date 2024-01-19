extends Node2D

var currentPos : Vector2
var achieved : bool
var coinSound : AudioStreamWAV = preload("res://Sounds/sfx_coin_double4.wav")

func _ready():
	currentPos = global_position
	AudioManager.PlaySound(coinSound)
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _process(delta):
	if currentPos + Vector2(0,-20) != position and !achieved:
		position = position.move_toward(Vector2(currentPos.x, currentPos.y - 20), 50 * delta)
	else:
		achieved = true
		#position = position.move_toward(Vector2(currentPos.x, currentPos.y), 50 * delta)
