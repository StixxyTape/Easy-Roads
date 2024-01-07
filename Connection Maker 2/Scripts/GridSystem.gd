extends TileMap

# How big the grid is e.g 4x4
var gridSize : int = 20
# Dictionary for storing data of all tiles
var dic : Dictionary = {}

func _ready():
	# For each x coordinate
	for x in gridSize:
		# For each y coordinate
		for y in gridSize:
			pass
	

func _process(delta):
	# Gets the tile at your mouse coordinates
	var tile = local_to_map(get_global_mouse_position())
	
	# Cleans up the "preview" tile for placing by erasing every tile on the temp layer
	for x in gridSize:
		for y in gridSize:
			erase_cell(1, Vector2(x, y))	
	
	# Placement system Work In Progress - Comment everything here to disable it
	
	#if dic.has(str(tile)):
	set_cell(1, tile, 0, Vector2(0, 0), 0)
	if Input.is_action_just_released("Left Click"):
		set_cell(0, tile, 0, Vector2(0, 0), 0)
	if Input.is_action_just_pressed("Right Click"):
		erase_cell(0, tile)
