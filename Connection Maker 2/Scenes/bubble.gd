extends TextureProgressBar

@onready var anim : AnimationPlayer = $AnimationPlayer

# Variables for the timer
var maxTime : int = Global.bubbleTimer
var time : float = 0

# Plays "Danger" animation when timer gets close to filling up
var dangerZone : bool = false

# For keeping track of if the timer should count
var count : bool = false

# Sets the type of structure to drive to
var type : int = randi_range(0, 4)
var destination : Vector2

# Sets the texture as a new AtlasTexture so other instantiated bubbles don't change aswell
var atlasTexture : AtlasTexture = AtlasTexture.new()
var overTexture : CompressedTexture2D = preload("res://Art/Bubbles/Bubbles.png")

func _ready():
	# Setting up the texture for the bubble
	texture_over = atlasTexture
	texture_over.atlas = overTexture
	texture_over.region = Rect2(0, 0, 16, 16)
	
	match type:
		0:
			SetSprite(0, 0)
			destination = Global.cinemaPos
		1:
			SetSprite(0, 16)
			destination = Global.restaurantPos
		2:
			SetSprite(0, 32)
			destination = Global.storePos
		3:
			SetSprite(0, 48)
			destination = Global.parkPos
		4:
			SetSprite(0, 64)
			destination = Global.libraryPos

func SetSprite(x, y):
	# Change sprite to according destination type
	texture_over.region = Rect2(x, y, 16, 16)
		
func _process(_delta):
	if Global.time == "play" and !count:
		Countdown()
	elif Global.time == "stop":
		count = false

func Countdown():
	count = true
	value = time
	max_value = maxTime
	
	# Keeps track of the time left for the car to reach it's destination
	while time < maxTime and count:
		await get_tree().create_timer(1).timeout
		if count:
			time += 1
			
			if time > maxTime - 10 and !dangerZone:
				anim.play("Danger")
				dangerZone = true
			
			value = time
