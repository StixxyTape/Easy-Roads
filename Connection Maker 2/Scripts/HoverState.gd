extends TextureButton

@export var type : String = "Type"
var active : bool
var hover : bool
@onready var tilemap = $"../../NavigationRegion2D/TileMap"

func _ready():
	self.mouse_entered.connect(_on_button_hovered)
	self.mouse_exited.connect(_on_button_exit)
	self.pressed.connect(_on_button_press)

func _process(_delta):
	if Global.roadType != type:
		active = false
	
	if !active and !hover:
		modulate = Color("fff")

func _on_button_hovered():
	if Global.roadType != type:
		modulate = Color("c9c9c9dc")
		hover = true
		Global.overButton = true

func _on_button_exit():
	hover = false
	Global.overButton = false

func _on_button_press():
	if active:
		Global.roadType = ""
		active = false
	else:
		tilemap.tileCounter = 0
		modulate = Color("999999dc")
		active = true
		Global.roadType = type
