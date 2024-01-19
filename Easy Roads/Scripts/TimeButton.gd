extends TextureButton

@export var action : String
var currentScale = get_scale()
var selectSound = preload("res://Sounds/Menu.wav")

func _ready():
	self.mouse_entered.connect(_on_button_hovered)
	self.mouse_exited.connect(_on_button_exit)
	self.pressed.connect(_on_button_press)

func _process(_delta):
	if Global.time == action:
		modulate = Color("8f8f8f")
	else:
		modulate = Color("fff")

func _on_button_hovered():
	if Global.time != action and !Global.tutorial:
		Global.overButton = true
		set_scale(currentScale + Vector2(0.1, 0.1))

func _on_button_exit():
	if Global.time != action:
		Global.overButton = false
		set_scale(currentScale)

func _on_button_press():
	if Global.time != action and !Global.tutorial:
		AudioManager.PlaySound(selectSound)
		modulate = Color("8f8f8f")
		set_scale(currentScale)
		Global.time = action
