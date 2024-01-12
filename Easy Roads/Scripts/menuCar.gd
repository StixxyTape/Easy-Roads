extends CharacterBody2D

var curScale = get_scale()
var traffic : int = 1

@onready var sprite : Sprite2D = $Icon
@onready var navAgent : NavigationAgent2D = $NavigationAgent2D
@onready var colls : Array[Area2D] = [$Front,$Back]
@onready var tileMap : TileMap = get_parent()

var destination : Vector2

func _ready():	
	# Sets the car sprite to a random variation
	sprite.frame = randi_range(0,3)
	
	await get_tree().create_timer(0.1).timeout
	
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
	print(navAgent.target_position)
func _physics_process(_delta):
	# Variables for controlling car offset
	var currentAgentPos: Vector2 = global_position
	var nextPathPos: Vector2 = navAgent.get_next_path_position()
	nextPathPos = navAgent.get_next_path_position()
	var nextTilePos : Vector2 = tileMap.local_to_map(nextPathPos)
	var carTilePos : Vector2 = tileMap.local_to_map(global_position)
	# Handles the offset
	if nextTilePos.x > carTilePos.x:
		set_scale(Vector2(curScale.x, curScale.y))
		sprite.offset.y = 1
		for col in colls:
			col.position.y = 1
	elif nextTilePos.x < carTilePos.x:
		set_scale(Vector2(curScale.x, -curScale.y))
		sprite.offset.y = -5
		for col in colls:
			col.position.y = -5
	
	if navAgent.is_target_reachable():
		look_at(nextPathPos)

	# If reached destination, don't run the rest of this code
	if navAgent.is_navigation_finished() and navAgent.target_position != Vector2.ZERO:
		queue_free()
	
	# Move towards next position in path * speed
	velocity = currentAgentPos.direction_to(nextPathPos) * Global.carSpeed * traffic
	move_and_slide()
	
func _on_area_2d_area_entered(area):
	traffic = 0
	if area.get_parent().position.y < position.y:
		await get_tree().create_timer(0.5).timeout
		traffic = 1

func _on_area_2d_area_exited(_area):
	traffic = 1
