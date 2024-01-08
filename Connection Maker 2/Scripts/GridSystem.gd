extends TileMap

# How big the grid is e.g 4x4
var gridSize : int = 5
# Dictionary for storing data of all tiles
var dic : Dictionary = {}
# A counter for checking which tile you have selected (Obsolete with UI)
var tileCounter : int = 0
# A list which stores all the atlas coordinates of road tiles
var roadTiles : Array = [Vector2(0, 0), Vector2(1, 0),	Vector2(0, 2),	
						Vector2(1, 2),	Vector2(2, 2),	Vector2(3, 2),	
						Vector2(0, 4),	Vector2(2, 4),	Vector2(0, 8),	
						Vector2(2, 8),	Vector2(4, 8),	Vector2(6, 8)]
# A list which stores all the atlas coordinates of house tiles
var houseTiles : Array = [Vector2(7,0), Vector2(8, 0), Vector2(9, 0),
						 Vector2(10, 0), Vector2(11, 0)]
# A list which stores all the ID's for structure tiles
var structIDs : Array = [3]
var mouseTile : Vector2

var car : PackedScene = preload("res://Scenes/car.tscn")

func _ready():
	
	SetupStructures()
	
	SpawnHouse()
	SpawnHouse()
	SpawnHouse()
	SpawnHouse()
	
	# For each x coordinate
	for x in gridSize:
		# For each y coordinate
		for y in gridSize:
			pass

func SpawnHouse():
	var positionTaken = false
	var randX : int
	var randY : int
	var houseType : int = randi_range(0, 4)
	
	var gridPos : Vector2
	var marginOffsets = [
		Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
		Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0),
		Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)
	]
	
	while true:
		randX = randi_range(-gridSize, gridSize)
		randY = randi_range(-gridSize, gridSize)
		
		positionTaken = false
		
		for offset in marginOffsets:
			gridPos = Vector2(randX, randY) + offset
			if dic.has(str(gridPos)):
				positionTaken = true
				break  # Stop checking further, a position is taken
		
		if not positionTaken:
			gridPos = Vector2(randX, randY)
			break  # Found an available position, exit the loop
	
	dic[str(gridPos)] = {
				"Type" : "House",
				"Position" : str(gridPos)
			}
			
	set_cell(0, gridPos, 2, houseTiles[houseType])
	
	var spawnedCar = car.instantiate()
	spawnedCar.position = map_to_local(gridPos)
	spawnedCar.spawnPos = map_to_local(gridPos)
	add_child(spawnedCar)
	
	
	
func SetupStructures():
	
	# To ensure there is atleast a one tile gap between structures
	var marginOffsets = [
		Vector2(-2, -2), Vector2(-1, -2), Vector2(0, -2), Vector2(1, -2), Vector2(2, -2),
		Vector2(-2, -1), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(2, -1),
		Vector2(-2, 0), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0),
		Vector2(-2, 1), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
		Vector2(-2, 2), Vector2(-1, 2), Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)
	]
	var gridOffsets = [
		Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
		Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0),
		Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)
	]
	
	for structure in structIDs:
		var structName : String
		
		match structure:
			3:
				structName = "Cinema"
		
		var positionTaken = false
		var randX : int
		var randY : int
		
		# Keep generating new positions until an available one is found for the current structure
		while true:
			randX = randi_range(-gridSize, gridSize)
			randY = randi_range(-gridSize, gridSize)
			
			positionTaken = false
			
			for offset in marginOffsets:
				var gridPos = Vector2(randX, randY) + offset
				if dic.has(str(gridPos)):
					positionTaken = true
					break  # Stop checking further, a position is taken
			
			if not positionTaken:
				break  # Found an available position, exit the loop
		
		# Set the tiles as the type at the available position
		for offset in gridOffsets:
			var gridPos = Vector2(randX, randY) + offset
			dic[str(gridPos)] = {
				"Type" : structName,
				"Position" : str(gridPos)
			}
		
		set_cell(0, Vector2(randX, randY), 3, Vector2.ZERO)
		
		Global.cinemaPos = map_to_local(Vector2(randX, randY + 1))

func _process(delta):
	BuildSystem()

func BuildSystem():
	# Erase the preview tile
	erase_cell(1, mouseTile)
	
	# Gets the tile at your mouse coordinates
	mouseTile = local_to_map(get_global_mouse_position())
	
	if Input.is_action_just_pressed("Interact"):
		tileCounter += 1
		if tileCounter >= 12:
			tileCounter = 0

	#if dic.has(str(mouseTile)):
		#print(dic[str(mouseTile)])
	
	# Sets a preview tile
	set_cell(1, mouseTile, 2, roadTiles[tileCounter], 1)
	
	if Input.is_action_just_released("Left Click"):
		set_cell(0, mouseTile, 2, roadTiles[tileCounter])
	if Input.is_action_just_pressed("Right Click"):
		erase_cell(0, mouseTile)
