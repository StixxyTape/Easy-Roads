extends TileMap

# How big the grid is e.g 4x4
var gridSize : int = 5

# Define the area in tile coordinates
var start_x = -14
var start_y = -7
var width = 28
var height = 14
var buildArea : Array

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
var structIDs : Array = [1, 3, 4, 5, 6]
var mouseTile : Vector2

# Variables that store the scene for the car and bubble
var car : PackedScene = preload("res://Scenes/car.tscn")
var bubble : PackedScene = preload("res://Scenes/bubble.tscn")

var currentTiles : Array
var roadPlaced : Array[Vector2]
var buildings : Array[Vector2]
var placing : bool
var touchedBuilding : bool
var lastTilePos : Vector2
var touchedBuildingPos : Vector2

# Variable to check when spawning a house
var spawningHouse : bool = true

# The cooldown between spawning houses
var houseSpawnCooldown : int = 5

func _ready():
	SetupStructures()
	SetupBuildArea()

func SetupBuildArea():
	# Loop through the specified area and set the tile for each cell
	for x in range(start_x, start_x + width):
		for y in range(start_y, start_y + height):
			await get_tree().create_timer(0.01).timeout
			buildArea.append(Vector2(x,y))
			set_cell(4, Vector2i(x,y), 0, Vector2i(1,0))
			
func SpawnHouse():
	var positionTaken = false
	var randX : int
	var randY : int
	var houseType : int = randi_range(0, 4)
	
	var gridPos : Vector2
	# Offsets to make sure the house doesn't spawn next to another structure
	var marginOffsets = [
		Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
		Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0),
		Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)
	]
	
	# Loop that only breaks when found a suitable spawn position
	while true:
		randX = randi_range(-gridSize -6, gridSize +6)
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
	
	# Stores tile data in the dictionary
	dic[str(gridPos)] = {
				"Type" : "House",
				"Position" : str(gridPos)
			}
	
	set_cell(0, gridPos, 2, houseTiles[houseType])
	# Adds position to buildings list
	buildings.append(gridPos)
	
	# Returns spawn position
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
		
		# Instantiates bubble with offset
		var spawnedBubble = bubble.instantiate()
		spawnedBubble.position = map_to_local(housePos)
		spawnedBubble.position.y -= 25
		spawnedBubble.position.x -= 8
		add_child(spawnedBubble)
		# Instantiates Car
		var spawnedCar = car.instantiate()
		add_child(spawnedCar)
		spawnedCar.global_position = map_to_local(housePos)
		spawnedCar.spawnPos = spawnedCar.position
		spawnedCar.bubble = spawnedBubble

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
		
		# Sets the structures name
		match structure:
			1: 
				structName = "Library"
			3:
				structName = "Cinema"
			4: 
				structName = "Park"
			5:
				structName = "Restaurant"
			6: 
				structName = "Store"
		
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
		set_cell(0, Vector2(randX, randY), structure, Vector2.ZERO)
		
		# Set the Global position for the structure
		match structName:
			"Library":
				Global.libraryPos = map_to_local(Vector2(randX, randY + 1))
			"Cinema":
				Global.cinemaPos = map_to_local(Vector2(randX, randY + 1))
			"Park":
				Global.parkPos = map_to_local(Vector2(randX, randY + 1))
			"Restaurant":
				Global.restaurantPos = map_to_local(Vector2(randX, randY + 1))
			"Store":
				Global.storePos = map_to_local(Vector2(randX, randY + 1))

func _process(_delta):
	BuildSystem()
	HouseManager()
	DayGridUpdate()

func DayGridUpdate():
	if Global.day == 1:
		TimeSystem(start_x, start_y, width, height)
	elif Global.day == 2:
		TimeSystem(start_x -2, start_y -2, width + 4, height + 4)
		gridSize = 8
	elif Global.day == 4:
		TimeSystem(start_x -5, start_y -4, width + 10, height + 8)
		gridSize = 10
	elif Global.day == 6:
		TimeSystem(start_x -9, start_y -7, width + 18, height + 13)
		gridSize = 12
		
func TimeSystem(posx,posy,fulwidth,fulheight):
	
	# Loop through the specified area and set the tile index for each cell
	for x in range(posx, posx + fulwidth):
		for y in range(posy, posy + fulheight):
			# Small time to add an effect
			await get_tree().create_timer(0.005).timeout
			if Vector2(x,y) not in buildArea:
				buildArea.append(Vector2(x,y))
				set_cell(4, Vector2i(x,y), 0, Vector2i(1,0))

func BuildSystem():
	# Erase the preview tile
	erase_cell(1, mouseTile)
	
	# Gets the tile at your mouse coordinates
	mouseTile = local_to_map(get_global_mouse_position())
	
	# Handles rotating tile
	if Input.is_action_just_pressed("Rotate") and !placing:
		tileCounter += 1
	
	# Sets selected tile type
	SetTile()
	

	if tileCounter >= maxtiles:
		tileCounter = 0
		
	# Shows preview tile 
	set_cell(1, mouseTile, 2, currentTiles[tileCounter], 1)
	
	# For setting tiles to be built or demolished
	if Input.is_action_pressed("Left Click") and !Global.overButton and Global.roadType != "":
		if Global.roadType == "remove" and mouseTile not in buildings:
			erase_cell(0, mouseTile)
			erase_cell(2, mouseTile)
			erase_cell(3, mouseTile)
		else:
			placing = true
			if mouseTile not in buildings and !touchedBuilding and mouseTile in buildArea:
				if mouseTile not in roadPlaced:
					roadPlaced.append(mouseTile)
					dic[str(mouseTile)] = {
						"Type" : "Road",
						"Position" : str(mouseTile)
						}
					set_cell(2, mouseTile, 2, currentTiles[tileCounter], 1)
					erase_cell(3, mouseTile)
			else:
				touchedBuilding = true
				
	# For removing preview tiles
	if Input.is_action_pressed("Right Click") and !Global.overButton and Global.roadType != "":
		if mouseTile in roadPlaced:
					erase_cell(2, mouseTile)
					var i = roadPlaced.find(mouseTile)
					roadPlaced.pop_at(i)
	# For building preview tiles
	if Input.is_action_just_released("Left Click") and !Global.overButton:
		for pos in roadPlaced:
			if Global.currentPrice <= Global.money:
				set_cell(0, pos, 2, currentTiles[tileCounter])
				dic[str(pos)] = {
					"Type" : "Road",
					"Position" : str(pos)
					}
				Global.money -= Global.currentPrice
			else:
				erase_cell(2, pos)
		roadPlaced = []
		touchedBuilding = false
		placing = false

func SetTile():
	# Sets tile based on roadtype selected
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
