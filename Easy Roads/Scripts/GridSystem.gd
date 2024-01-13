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
var straigthTiles : Array = [Vector2i(0, 0), Vector2i(1, 0)]

# A list which stores all the atlas coordinates of road tiles turns
var turnTiles : Array = [Vector2i(0, 2), Vector2i(1, 2), Vector2i(3, 2), Vector2i(2, 2)]

# A list which stores all the atlas coordinates of road tiles T-junction
var tTiles : Array = [Vector2i(0, 8), Vector2i(6, 8), Vector2i(2, 8), Vector2i(4, 8)]

# A list which stores all the atlas coordinates of road tiles cross
var crossTile : Array = [Vector2i(0, 4)]

# A list which stores all the atlas coordinates of road tiles roundabout
var roundaboutTile : Array = [Vector2i(2, 4)]

# A list which stores all the atlas coordinates of empty tile
var emptyTile : Array = [Vector2i(0, 1)]

# A list which stores all the atlas coordinates of house tiles
var houseTiles : Array = [Vector2i(7,0), Vector2i(8, 0), Vector2i(9, 0),
						 Vector2i(10, 0), Vector2i(11, 0)]
# A list which stores all the ID's for structure tiles
var structIDs : Array = [4, 6, 1, 5, 3]
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
var playedSound : bool

# Variable to check when spawning a house
var spawningHouse : bool = true

# The cooldown between spawning houses
var houseSpawnCooldown : int = 10

# To keep track of the days and structures that have been built
var passedDays : Array = []
var structCounter : int

# Particles 
var structParticles : PackedScene = preload("res://Scenes/struct_particles.tscn")
var buildParticles : PackedScene = preload("res://Scenes/building_particles.tscn")

# Sounds
var placeSound : AudioStreamWAV = preload("res://Sounds/sfx_sounds_impact3.wav")

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
		randX = randi_range(-gridSize -8, gridSize +8)
		randY = randi_range(-gridSize, gridSize)
		
		positionTaken = false
		gridPos = Vector2(randX, randY)
		
		if dic.has(str(gridPos)) and dic[str(gridPos)]["Type"] == "House":
			positionTaken = true
			
		for offset in marginOffsets:
			gridPos = Vector2(randX, randY) + offset

			if dic.has(str(gridPos)) and dic[str(gridPos)]["Type"] != "House":
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
	set_cell(5, gridPos, 2, Vector2i(1, 1))
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
		if Global.time == "play":
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
		
func SetupStructure():
	
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
	
	var structName : String
	var structure : int
	
	# For spawning the structures in order, starting with the cheapest
	match structCounter:
		0:
			structure = structIDs[randi_range(0, 1)]
			structCounter += 1
		1:
			structure = structIDs[0]
			structCounter += 1
		2:
			structure = structIDs[0]
			structCounter += 1
		3:
			structure = structIDs[randi_range(0, 1)]
			structCounter += 1
		4: 
			structure = structIDs[0]
			structCounter += 1
			
	structIDs.remove_at(structIDs.find(structure))
	
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
	
	Global.builtStructs.append(structName)
	
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
			if (dic.has(str(gridPos)) and (dic[str(gridPos)]["Type"] != "Trees" and dic[str(gridPos)]["Type"] != "Grass")) or gridPos not in buildArea:
				positionTaken = true
				break  # Stop checking further, a position is taken
		
		if not positionTaken:
			break  # Found an available position, exit the loop
	
	# Set the tiles as the type at the available position
	for offset in gridOffsets:
		var gridPos = Vector2(randX, randY) + offset
		var leftEntrance = Vector2(randX, randY) + Vector2(-2, 1)
		var rightEntrance = Vector2(randX, randY) + Vector2(2, 1)

		erase_cell(0, gridPos)

		if dic.has(str(leftEntrance)):
			dic.erase(str(leftEntrance))
			erase_cell(0, leftEntrance)
		if dic.has(str(rightEntrance)):
			dic.erase(str(rightEntrance))
			erase_cell(0, rightEntrance)
			
		dic[str(gridPos)] = {
			"Type" : structName,
			"Position" : str(gridPos)
		}
		buildings.append(gridPos)
		
	set_cell(0, Vector2(randX, randY), structure, Vector2.ZERO)
	
	# Play Particles
	var particles = structParticles.instantiate()
	particles.global_position = map_to_local(Vector2(randX, randY))
	particles.emitting = true
	add_child(particles)
	
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
	if Global.day not in passedDays:
		if Global.day == 1:
			TimeSystem(start_x, start_y, width, height)
			TimeSystem(start_x, start_y, width, height)
		elif Global.day == 4:
			TimeSystem(start_x -2, start_y -2, width + 4, height + 4)
			gridSize = 8
		elif Global.day == 8:
			TimeSystem(start_x -5, start_y -4, width + 10, height + 8)
			gridSize = 10
			Global.bubbleTimer = 40
			houseSpawnCooldown = 8
		elif Global.day == 10:
			TimeSystem(start_x -9, start_y -7, width + 18, height + 13)
			gridSize = 12
			Global.bubbleTimer = 30
			
		passedDays.append(Global.day)
		
func TimeSystem(posx,posy,fulwidth,fulheight):
	
	# Loop through the specified area and set the tile index for each cell
	for x in range(posx, posx + fulwidth):
		# Small delay to add an effect
		await get_tree().create_timer(0.01).timeout
		for y in range(posy, posy + fulheight):
			if Vector2(x,y) not in buildArea:
				buildArea.append(Vector2(x,y))
				set_cell(4, Vector2i(x,y), 0, Vector2i(1,0))
				# For adding trees and bushes
				if randi_range(0, 10) == 0:
					var randX = randi_range(5, 6)
					var randY = randi_range(2, 5)
					set_cell(0, Vector2i(x,y), 2, Vector2i(randX, randY))
					if randY > 3:
						dic[str(Vector2i(x, y))] = {
							"Type" : "Grass",
							"Position" : str(Vector2i(x, y))
						}
					else:
						dic[str(Vector2i(x, y))] = {
							"Type" : "Trees",
							"Position" : str(Vector2i(x, y))
						}
	SetupStructure()
	
func BuildSystem():
	# Erase the preview tile
	erase_cell(1, mouseTile)
	if !Input.is_action_pressed("Left Click"):
		erase_cell(2, mouseTile)
	
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
		if Global.roadType == "remove" and mouseTile not in buildings :
			if dic.has(str(mouseTile)):
				if dic[str(mouseTile)]["Type"] != "Trees":
					dic.erase(str(mouseTile))
					erase_cell(0, mouseTile)
					erase_cell(2, mouseTile)
					erase_cell(3, mouseTile)
			else:
				erase_cell(0, mouseTile)
				erase_cell(2, mouseTile)
				erase_cell(3, mouseTile)
		else:
			placing = true
			if mouseTile not in buildings and !touchedBuilding and mouseTile in buildArea:
				if mouseTile not in roadPlaced and currentTiles[tileCounter] != get_cell_atlas_coords(0,mouseTile):
					if (dic.has(str(mouseTile)) and dic[str(mouseTile)]["Type"] != "Trees") or !dic.has(str(mouseTile)):
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
				# Play Particles
				var particles = buildParticles.instantiate()
				particles.global_position = map_to_local(pos)
				particles.emitting = true
				add_child(particles)
				
				Global.money -= Global.currentPrice
				
				if !playedSound:
					AudioManager.PlaySound(placeSound)
					playedSound = true
				
			else:
				erase_cell(2, pos)
		playedSound = false
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
