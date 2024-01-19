extends Node2D

@onready var tileMap : TileMap = $NavigationRegion2D/TileMap

var car : PackedScene = preload("res://Scenes/menuCar.tscn")
var spawning : bool = true

var spawnPositions : Array = [Vector2(440, 328), Vector2(648, 232),
							  Vector2(648, 88), Vector2(552, -8),
							  Vector2(376, -8), Vector2(184, -8),
							  Vector2(104, -8), Vector2(-8, 120),
							  Vector2(8, 328), Vector2(104, 328)]
							
@onready var descriptionLabel : Label = $CanvasLayer/Description

func _ready():
	SpawnCars()
	print("Bruh")
	if Global.day == 1:
		descriptionLabel.text = str("You made it to ", Global.day, " Day")
	else:
		descriptionLabel.text = str("You made it to ", Global.day, " Days")

func SpawnCars():
	while true:
		if spawning:
			spawning = false
			await get_tree().create_timer(randf_range(0.5, 1.5)).timeout
			var spawnedCar = car.instantiate()
			tileMap.add_child(spawnedCar)
			spawnedCar.position = spawnPositions.pick_random()
			spawnedCar.destination = spawnPositions.pick_random() * 2
			spawning = true
