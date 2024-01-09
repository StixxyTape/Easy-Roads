extends CharacterBody2D

# Speed
var speed : float = 20.0
var spawnPos : Vector2

@onready var navAgent : NavigationAgent2D = $NavigationAgent2D

func _ready():
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	await get_tree().create_timer(1).timeout
	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(Global.cinemaPos)

func set_movement_target(movement_target: Vector2):
	navAgent.target_position = movement_target

func _physics_process(_delta):
	var currentAgentPos: Vector2 = global_position
	var nextPathPos: Vector2 = navAgent.get_next_path_position()
	
	# If reached destination, don't run the rest of this code
	if navAgent.is_navigation_finished():
		return
	elif (!navAgent.is_target_reachable() and position != spawnPos):
		position = spawnPos
	
	# Move towards next position in path * speed
	velocity = currentAgentPos.direction_to(nextPathPos) * speed
	move_and_slide()
