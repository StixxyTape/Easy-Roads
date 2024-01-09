extends CharacterBody2D

# Speed
var speed : float = 20.0
var spawnPos : Vector2
var curScale = get_scale()

@onready var sprite : Sprite2D = $Icon
@onready var navAgent : NavigationAgent2D = $NavigationAgent2D

func _ready():
	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	rotation = 0

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
	
	if nextPathPos.x > position.x:
		set_scale(Vector2(curScale.x,curScale.y))
		sprite.offset.y = 1
	else:
		sprite.offset.y = -5
		set_scale(Vector2(curScale.x,-curScale.y))
	
	look_at(nextPathPos)
	
	# If reached destination, don't run the rest of this code
	if navAgent.is_navigation_finished():
		return
	elif (!navAgent.is_target_reachable() and position != spawnPos):
		position = spawnPos
	
	# Move towards next position in path * speed
	velocity = currentAgentPos.direction_to(nextPathPos) * speed
	move_and_slide()
