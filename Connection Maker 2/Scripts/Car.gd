extends CharacterBody2D

var spawnPos : Vector2
var houseCord : Vector2
var curScale = get_scale()


@onready var sprite : Sprite2D = $Icon
@onready var navAgent : NavigationAgent2D = $NavigationAgent2D
@onready var tileMap : TileMap = $".."

# A list which stores all the atlas coordinates of road tiles start house
var adjectedTiles : Array = [Vector2(0, 6), Vector2(1, 6), Vector2(2, 6), Vector2(3, 6)]
var adjectedTilesPos : Array
var adjectedTilePlaced : bool

# variable for the set bubble
var bubble : TextureProgressBar

func _ready():
	visible = false
	sprite.frame = randi_range(0,3)
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(Global.cinemaPos)
	# Set rotation to be flat
	rotation = 0

func set_movement_target(movement_target: Vector2):
	navAgent.target_position = movement_target

func _physics_process(_delta):
	houseCord = tileMap.local_to_map(spawnPos)
	adjectedTilesPos = [houseCord + Vector2(1,0), houseCord - Vector2(1,0), houseCord + Vector2(0,1), houseCord - Vector2(0,1)]
	
	var currentAgentPos: Vector2 = global_position
	var nextPathPos: Vector2 = navAgent.get_next_path_position()
	var nextTilePos : Vector2 = tileMap.local_to_map(nextPathPos)
	var carTilePos : Vector2 = tileMap.local_to_map(global_position)
	
	if carTilePos in adjectedTilesPos and !adjectedTilePlaced:
		var i = adjectedTilesPos.find(carTilePos)
		eraseStartPoints()
		if houseCord.x < adjectedTilesPos[i].x:
			tileMap.set_cell(3, adjectedTilesPos[i], 2, adjectedTiles[3])
		elif houseCord.x > adjectedTilesPos[i].x:
			tileMap.set_cell(3, adjectedTilesPos[i], 2, adjectedTiles[0])
		elif houseCord.y < adjectedTilesPos[i].y:
			tileMap.set_cell(3, adjectedTilesPos[i], 2, adjectedTiles[2])
		elif houseCord.y > adjectedTilesPos[i].y:
			tileMap.set_cell(3, adjectedTilesPos[i], 2, adjectedTiles[1])
		visible = true
		adjectedTilePlaced = true
	
	if nextTilePos.x > carTilePos.x:
		set_scale(Vector2(curScale.x, curScale.y))
		sprite.offset.y = 1
	elif nextTilePos.x < carTilePos.x:
		set_scale(Vector2(curScale.x, -curScale.y))
		sprite.offset.y = -5
	
	#print(global_position.distance_to(nextPathPos))
	# Only look at the next path position if you are able to reach the destination
	if navAgent.is_target_reachable():
		look_at(nextPathPos)

	# If reached destination, don't run the rest of this code
	if navAgent.is_navigation_finished():
		bubble.queue_free()
		queue_free()
		return
	elif (!navAgent.is_target_reachable() and position != spawnPos):
		adjectedTilePlaced = false
		visible = false
		position = spawnPos
	
	# Move towards next position in path * speed
	velocity = currentAgentPos.direction_to(nextPathPos) * Global.carSpeed
	move_and_slide()

func eraseStartPoints():
	for pos in adjectedTilesPos:
		tileMap.erase_cell(3, pos)
