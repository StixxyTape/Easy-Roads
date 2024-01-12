extends TextureButton

@export var type : String = "Type"
@export var price : int = 0
var active : bool
var hover : bool
@onready var tilemap = $"../../NavigationRegion2D/TileMap"
var priceLabel : TextureRect

var selectSound = preload("res://Sounds/Menu.wav")

func _ready():
	self.mouse_entered.connect(_on_button_hovered)
	self.mouse_exited.connect(_on_button_exit)
	self.pressed.connect(_on_button_press)
	if type != "remove":
		priceLabel = $"../Cost"
	
	if priceLabel:
		priceLabel.visible = false

func _process(_delta):
	if Global.roadType != type:
		active = false
	
	if !active and !hover:
		self_modulate = Color("fff")

func _on_button_hovered():
	if Global.roadType != type:
		self_modulate = Color("c9c9c9dc")
		hover = true
		Global.overButton = true

func _on_button_exit():
	hover = false
	Global.overButton = false

func _on_button_press():
	if active:
		Global.roadType = ""
		active = false
		if priceLabel:
			priceLabel.visible = false
			Global.currentPrice = 0
	else:
		if priceLabel:
			priceLabel.visible = true
			Global.currentPrice = price
		tilemap.tileCounter = 0
		self_modulate = Color("999999dc")
		active = true
		Global.roadType = type
		AudioManager.PlaySound(selectSound)
