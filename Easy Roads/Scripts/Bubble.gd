extends TextureProgressBar

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var camAnim : AnimationPlayer = $"../../../AnimationPlayer"

# Variables for the timer
var maxTime : int = Global.bubbleTimer
var time : float = 0

# Plays "Danger" animation when timer gets close to filling up
var dangerZone : bool = false

# For keeping track of if the timer should count
var count : bool = false

# Sets the type of structure to drive to
var type : String
var destination : Vector2
var payedFee : int

# Sets the texture as a new AtlasTexture so other instantiated bubbles don't change aswell
var atlasTexture : AtlasTexture = AtlasTexture.new()
var overTexture : CompressedTexture2D = preload("res://Art/Bubbles/Bubbles.png")

var loseSound : AudioStreamWAV = preload("res://Sounds/sfx_sounds_interaction13.wav")

func _ready():
	# Setting up the texture for the bubble
	texture_over = atlasTexture
	texture_over.atlas = overTexture
	texture_over.region = Rect2(0, 0, 16, 16)
	
	SetDestination()

func SetDestination():
	type = Global.builtStructs.pick_random()
	
	match type:
		"Store":
			SetSprite(0, 32)
			destination = Global.storePos
			payedFee = 5
		"Park":	
			SetSprite(0, 48)
			destination = Global.parkPos
			payedFee = 5
		"Library":
			SetSprite(0, 64)
			destination = Global.libraryPos
			payedFee = 10
		"Restaurant":
			SetSprite(0, 16)
			destination = Global.restaurantPos
			payedFee = 15
		"Cinema":
			SetSprite(0, 0)
			destination = Global.cinemaPos
			payedFee = 15

func SetSprite(x, y):
	# Change sprite to according destination type
	texture_over.region = Rect2(x, y, 16, 16)
		
func _process(_delta):
	value = time
	max_value = maxTime
	
	if Global.time == "play" and !count:
		Countdown()
	elif Global.time == "stop":
		count = false
	
	if time >= maxTime - 8 and !Global.gameOver:
		GameOver()
		Global.gameOver = true
	
func Countdown():
	count = true
	
	# Keeps track of the time left for the car to reach it's destination
	while time < maxTime and count:
		await get_tree().create_timer(1).timeout
		if count:
			time += 1
			
			if time > maxTime - 18 and !dangerZone:
				anim.play("Danger")
				dangerZone = true
			
			value = time

func GameOver():
	AudioManager.PlaySound(loseSound)
	camAnim.play("gameOver")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/gameOver.tscn")
