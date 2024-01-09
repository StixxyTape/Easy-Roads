extends TileMap

# How big the grid is e.g 4x4
var gridSize : int = 5
# Dictionary for storing data of all tiles
var dic : Dictionary = {}
# A counter for checking which tile you have selected (Obsolete with UI)
var tileCounter : int = 0
var maxtiles : int = 0

# A list which stores all the atlas coordinates of road tiles straights
var straigthTiles : Array = [Vector2(0, 0), Vector2(1, 0)]

# A list which stores all the atlas coordinates of road tiles turns
var turnTiles : Array = [Vector2(0, 2), Vector2(1, 2), Vector2(3, 2), Vector2(2, 2)]

# A list which stores all the atlas coordinates of road tiles T-junction
var tTiles : Array = [Vector2(0, 8), Vector2(6, 8), Vector2(2, 8), Vector2(4, 8)]

# A list which stores all the atlas coordinates of road tiles cross
var crossTile : Array = [Vector2(0, 4)]

# A list which stores all the atlas coordinates of road tiles roundabout
var roundaboutTile : Array = [Vector2(2, 4)]

# A list which stores all the atlas coordinates of empty tile
var emptyTile : Array = [Vector2(0, 1)]

# A list which stores all the atlas coordinates of house tiles
var houseTiles : Array = [Vector2(7,0), Vector2(8, 0), Vector2(9, 0),
						 Vector2(10, 0), Vector2(11, 0)]
# A list which stores all the ID's for structure tiles
var structIDs : Array = [3]
var mouseTile : Vector2

var car : PackedScene = preload("res://Scenes/car.tscn")
var bubble : PackedScene = preload("res://Scenes/bubble.tscn")

var currentTiles : Array
var roadPlaced : Array[Vector2]
var buildings : Array[Vector2]
var placing : bool

var spawningHouse : bool = true

# The cooldown between spawning houses
var houseSpawnCooldown : int = 5

func _ready():
	
	SetupStructures()
	
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
	buildings.append(gridPos)
	
	return gridPos
	
func HouseManager():
	var housePos : Vector2
	
	# Spawn a car after every houseSpawnCooldown seconds
	if spawningHouse == true:
		spawningHouse = false
		await get_tree().create_timer(houseSpawnCooldown).timeout
		housePos = SpawnHouse()
		spawningHouse = true
	
	# Spawn a bubble and car at the house
	if housePos:
		var spawnedBubble = bubble.instantiate()
		spawnedBubble.position = map_to_local(housePos)
		spawnedBubble.position.y -= 20
		spawnedBubble.position.x -= 8
		add_child(spawnedBubble)
		
		var spawnedCar = car.instantiate()
		spawnedBubble.add_child(spawnedCar)
		spawnedCar.global_position = map_to_local(housePos)
		spawnedCar.spawnPos = spawnedCar.position
	
	
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
			buildings.append(gridPos)
		set_cell(0, Vector2(randX, randY), 3, Vector2.ZERO)
		
		Global.cinemaPos = map_to_local(Vector2(randX, randY + 1))
		#buildings.append_array([Vector2(randX, randY), Vector2(randX, randY + 1), 
							#Vector2(randX +1, randY), Vector2(randX +1, randY + 1),
							#Vector2(randX -1, randY), Vector2(randX -1, randY + 1)])

func _process(_delta):
	BuildSystem()
	HouseManager()

func BuildSystem():
	# Erase the preview tile
	erase_cell(1, mouseTile)
	
	# Gets the tile at your mouse coordinates
	mouseTile = local_to_map(get_global_mouse_position())
	
	if Input.is_action_just_pressed("Rotate") and !placing:
		tileCounter += 1

	#if dic.has(str(mouseTile)):
		#print(dic[str(mouseTile)])
	
	# Sets selected tile type
	SetTile()
	
	if tileCounter >= maxtiles:
		tileCounter = 0
		
	# Shows preview tile 
	set_cell(1, mouseTile, 2, currentTiles[tileCounter], 1)
	
	
	if Input.is_action_pressed("Left Click") and !Global.overButton and Global.roadType != "":
		if Global.roadType == "remove" and mouseTile not in buildings:
			erase_cell(0, mouseTile)
			erase_cell(2, mouseTile)
		else:
			placing = true
			if mouseTile not in buildings:
				if mouseTile not in roadPlaced:
					roadPlaced.append(mouseTile)
					dic[str(mouseTile)] = {
						"Type" : "Road",
						"Position" : str(mouseTile)
						}
					set_cell(2, mouseTile, 2, currentTiles[tileCounter], 1)
					
	if Input.is_action_pressed("Right Click") and !Global.overButton and Global.roadType != "":
		if mouseTile in roadPlaced:
					erase_cell(2, mouseTile)
					var i = roadPlaced.find(mouseTile)
					roadPlaced.pop_at(i)
	if Input.is_action_just_released("Left Click") and !Global.overButton:
		for pos in roadPlaced:
				set_cell(0, pos, 2, currentTiles[tileCounter])
				dic[str(pos)] = {
					"Type" : "Road",
					"Position" : str(pos)
					}
				
		roadPlaced = []
		placing = false

func SetTile():
	match Global.roadType:
		"straigth":
			maxtiles = straigthTiles.size()
			currentTiles = straigthTiles
		"turn":
			maxtiles = turnTiles.size()
			currentTiles = turnTiles
		"tjunction":
			maxtiles = tTiles.size()
			currentTiles = tTiles
		"cross":
			maxtiles = crossTile.size()
			currentTiles = crossTile
		"roundabout":
			maxtiles = roundaboutTile.size()
			currentTiles = roundaboutTile
		_:
			maxtiles = emptyTile.size()
			currentTiles = emptyTile
