extends TileMap

# How big the grid is e.g 4x4
var gridSize : int = 20
# Dictionary for storing data of all tiles
var dic : Dictionary = {}
var tileCounter : int = 0
var roadTiles = [Vector2(0, 0),
			Vector2(1, 0),
			Vector2(0, 2),
			Vector2(1, 2),
			Vector2(2, 2),
			Vector2(3, 2),
			Vector2(0, 4),
			Vector2(2, 4),
			Vector2(0, 8),
			Vector2(2, 8),
			Vector2(4, 8),
			Vector2(6, 8),]
			
func _ready():
	
	SetupStructure()
	
	# For each x coordinate
	for x in gridSize:
		# For each y coordinate
		for y in gridSize:
			pass
	
func SetupStructure():
	#var randX = randi_range(-gridSize, gridSize)
	#var randY = randi_range(-gridSize, gridSize)
	var randX = 3
	var randY = -3
	
	dic[str(Vector2(randX, randY))] = {
		"Type" : "Cinema",
		"Position" : str(Vector2(randX, randY))
	}
	dic[str(Vector2(randX - 1, randY))] = {
		"Type" : "Cinema",
		"Position" : str(Vector2(randX - 1, randY))
	}
	dic[str(Vector2(randX + 1, randY))] = {
		"Type" : "Cinema",
		"Position" : str(Vector2(randX + 1, randY))
	}
	dic[str(Vector2(randX, randY - 1))] = {
		"Type" : "Cinema",
		"Position" : str(Vector2(randX, randY - 1))
	}
	dic[str(Vector2(randX - 1, randY - 1))] = {
		"Type" : "Cinema",
		"Position" : str(Vector2(randX - 1, randY - 1))
	}
	dic[str(Vector2(randX + 1, randY - 1))] = {
		"Type" : "Cinema",
		"Position" : str(Vector2(randX + 1, randY - 1))
	}
	dic[str(Vector2(randX + 1, randY + 1))] = {
		"Type" : "Cinema",
		"Position" : str(Vector2(randX + 1, randY + 1))
	}
	dic[str(Vector2(randX - 1, randY + 1))] = {
		"Type" : "Cinema",
		"Position" : str(Vector2(randX - 1, randY + 1))
	}
	dic[str(Vector2(randX, randY + 1))] = {
		"Type" : "Cinema",
		"Position" : str(Vector2(randX, randY + 1))
	}
	
	set_cell(0, Vector2(randX, randY), 3, Vector2.ZERO)
	
	Global.cinemaPos = map_to_local(Vector2(randX, randY + 1))
	print(Global.cinemaPos)
	
func _process(delta):
	BuildSystem()

func BuildSystem():
	# Gets the tile at your mouse coordinates
	var tile = local_to_map(get_global_mouse_position())

				
	CleanupGrid()
	
	if Input.is_action_just_pressed("Interact"):
		tileCounter += 1
		if tileCounter >= 11:
			tileCounter = 0
		
	
	#if dic.has(str(tile)):
		#print(dic[str(tile)])
		
	set_cell(1, tile, 2, roadTiles[tileCounter], 1)
	if Input.is_action_just_released("Left Click"):
		set_cell(0, tile, 2, roadTiles[tileCounter])
	if Input.is_action_just_pressed("Right Click"):
		erase_cell(0, tile)

func CleanupGrid():
	# Cleans up the "preview" tile for placing by erasing every tile on the temp layer
	for x in gridSize:
		for y in gridSize:
			# We do four erases here for the four quadrants the grid expands to
			erase_cell(1, Vector2(x, y))	
			erase_cell(1, Vector2(-x, -y))	
			erase_cell(1, Vector2(x, -y))	
			erase_cell(1, Vector2(-x, y))	
