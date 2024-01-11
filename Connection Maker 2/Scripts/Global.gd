extends Node

# Variables that store the position of each structure
var libraryPos : Vector2
var cinemaPos : Vector2
var parkPos : Vector2
var restaurantPos : Vector2
var storePos : Vector2

var builtStructs : Array = []

# What road your holding
var roadType : String
var overButton : bool

# Text of the timers state
var time : String = "play"
var carSpeed : float = 35

# Timer for how long it takes bubbles to fill up
var bubbleTimer : int = 60

# Start Stats
var day : int = 1
var money : int = 100000
var currentPrice : int = 0

# Handles pausing the game
func _process(_delta):
	if time == "play":
		carSpeed = 30
	elif time == "stop":
		carSpeed = 0
