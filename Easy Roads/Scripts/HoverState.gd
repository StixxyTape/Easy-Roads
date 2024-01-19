extends TextureButton

@export var type : String = "Type"
@export var price : int = 0
var active : bool
var hover : bool
@onready var tilemap = $"../../NavigationRegion2D/TileMap"
@onready var priceLabel : Label = $"../PriceLabel"

var selectSound = preload("res://Sounds/Menu.wav")

func _ready():
	self.mouse_entered.connect(_on_button_hovered)
	self.mouse_exited.connect(_on_button_exit)
	self.pressed.connect(_on_button_press)
	
	priceLabel.visible = false
	
func _process(_delta):
	if Global.roadType != type:
		active = false
	
	if !active and !hover:
		self_modulate = Color("fff")
	
	if priceLabel:
		priceLabel.global_position = Vector2(
			get_global_mouse_position().x - 20,
			get_global_mouse_position().y - 30)

func _on_button_hovered():
	if Global.roadType != type and !Global.tutorial:
		self_modulate = Color("c9c9c9dc")
		hover = true
		Global.overButton = true

func _on_button_exit():
	hover = false
	Global.overButton = false

func _on_button_press():
	if !Global.tutorial:
		if active:
			Global.roadType = ""
			priceLabel.visible = false
			Global.currentPrice = 0
			active = false
		else:
			priceLabel.visible = true
			Global.currentPrice = price
			tilemap.tileCounter = 0
			self_modulate = Color("999999dc")
			active = true
			Global.roadType = type
			AudioManager.PlaySound(selectSound)
