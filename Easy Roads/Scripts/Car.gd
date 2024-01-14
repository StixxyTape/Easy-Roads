extends CharacterBody2D

var spawnPos : Vector2
var houseCord : Vector2
var curScale = get_scale()
var startPos : Vector2
var houseCount : Array
var obstacle : bool
var traffic : int = 1

@onready var sprite : Sprite2D = $Icon
@onready var navAgent : NavigationAgent2D = $NavigationAgent2D
@onready var tileMap : TileMap = $".."
@onready var bubble : TextureProgressBar
@onready var colls : Array[Area2D] = [$Front,$Back]

# A list which stores all the atlas coordinates of road tiles start house
var adjectedTiles : Array = [Vector2(0, 6), Vector2(1, 6), Vector2(2, 6), Vector2(3, 6)]
var adjectedTilesPos : Array
var adjectedTilePlaced : bool

var navTiles : Array = [Vector2(2, 1), Vector2(3, 1), Vector2(4, 1), Vector2(5, 1)]
var houseTiles : Array = [Vector2i(7, 0), Vector2i(8, 0), Vector2i(9, 0), Vector2i(10, 0), Vector2i(11, 0)]
# variable for the set bubble
var destination : Vector2
var payedFee : int 

# Coin
var coin : PackedScene = preload("res://Scenes/coin.tscn")

func _ready():	
	# Sets the car to be invisible until it leaves the house
	visible = false
	# Sets the car sprite to a random variation
	sprite.frame = randi_range(0,3)
	
	await get_tree().create_timer(0.1).timeout
	
	destination = bubble.destination
	payedFee = bubble.payedFee
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(destination)
	
	# Set rotation to be flat
	rotation = 0

func set_movement_target(movement_target: Vector2):
	navAgent.target_position = movement_target
		
func _physics_process(_delta):
	houseCord = tileMap.local_to_map(spawnPos)
	adjectedTilesPos = [houseCord + Vector2(1,0), houseCord - Vector2(1,0), houseCord + Vector2(0,1), houseCord - Vector2(0,1)]
	
	# Variables for controlling car offset
	var currentAgentPos: Vector2 = global_position
	var nextPathPos: Vector2 = navAgent.get_next_path_position()
	nextPathPos = navAgent.get_next_path_position()
	var nextTilePos : Vector2 = tileMap.local_to_map(nextPathPos)
	var carTilePos : Vector2 = tileMap.local_to_map(global_position)
		
	# Handles placing a tile to denote which side the car leaves the house from
	if carTilePos in adjectedTilesPos and !adjectedTilePlaced and navAgent.is_target_reachable() and tileMap.get_cell_atlas_coords(0, carTilePos) not in houseTiles:
		var i = adjectedTilesPos.find(carTilePos)
		eraseStartPoints()
		if houseCord.x < adjectedTilesPos[i].x:
			tileMap.set_cell(3, adjectedTilesPos[i], 2, adjectedTiles[3])
			tileMap.set_cell(5, houseCord, 2, navTiles[3])
		elif houseCord.x > adjectedTilesPos[i].x:
			tileMap.set_cell(3, adjectedTilesPos[i], 2, adjectedTiles[0])
			tileMap.set_cell(5, houseCord, 2, navTiles[0])
		elif houseCord.y < adjectedTilesPos[i].y:
			tileMap.set_cell(3, adjectedTilesPos[i], 2, adjectedTiles[2])
			tileMap.set_cell(5, houseCord, 2, navTiles[2])
		elif houseCord.y > adjectedTilesPos[i].y:
			tileMap.set_cell(3, adjectedTilesPos[i], 2, adjectedTiles[1])
			tileMap.set_cell(5, houseCord, 2, navTiles[1])
		startPos = adjectedTilesPos[i]
		position = tileMap.map_to_local(startPos)
		
		adjectedTilePlaced = true
		visible = true
	
	# Handles the offset
	if nextTilePos.x > carTilePos.x and nextTilePos != houseCord:
		set_scale(Vector2(curScale.x, curScale.y))
		sprite.offset.y = 1
		for col in colls:
			col.position.y = 1
	elif nextTilePos.x < carTilePos.x and nextTilePos != houseCord:
		set_scale(Vector2(curScale.x, -curScale.y))
		sprite.offset.y = -5
		for col in colls:
			col.position.y = -5
	
	# Only look at the next path position if you are able to reach the destination
	if navAgent.is_target_reachable():
		look_at(nextPathPos)
	
	
	# This is for getting the path ahead of the car
	#NavigationServer2D.map_get_path(get_world_2d().get_navigation_map(), global_position, navAgent.target_position, false)
	
	# If reached destination, don't run the rest of the code
	if navAgent.is_target_reached() and adjectedTilePlaced:
		Global.money += payedFee
		
		var inCoin = coin.instantiate()
		inCoin.position = destination
		get_parent().add_child(inCoin)
		
		tileMap.set_cell(5, houseCord, 2, Vector2i(1, 1))
		adjectedTilePlaced = false
		visible = false
		bubble.time = 0
		position = spawnPos
		
		bubble.SetDestination()
		destination = bubble.destination
		payedFee = bubble.payedFee
		
		set_movement_target(destination)
		return
		
	# If destination is not reachable and your position is not where you spawned, respawn
	elif (!navAgent.is_target_reachable() and position != spawnPos):
		tileMap.set_cell(5, houseCord, 2, Vector2i(1, 1))
		adjectedTilePlaced = false
		visible = false
		position = spawnPos

	
	if tileMap.get_cell_atlas_coords(0, nextTilePos) in houseTiles and nextTilePos != houseCord:
		return
		
	# Move towards next position in path * speed
	if navAgent.is_target_reachable():
		velocity = currentAgentPos.direction_to(nextPathPos) * Global.carSpeed * traffic
		move_and_slide()
	
func eraseStartPoints():
	for pos in adjectedTilesPos:
		tileMap.erase_cell(3, pos)

func _on_area_2d_area_entered(area):
	traffic = 0
	if area.get_parent().position.y < position.y:
		await get_tree().create_timer(0.5).timeout
		traffic = 1

func _on_area_2d_area_exited(_area):
	traffic = 1
