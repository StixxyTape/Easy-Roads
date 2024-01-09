extends TextureButton

@export var action : String

func _ready():
	self.pressed.connect(_on_button_press)

func _process(_delta):
	if Global.time == action:
		modulate = Color("8f8f8f")
	else:
		modulate = Color("fff")

func _on_button_press():
	modulate = Color("8f8f8f")
	Global.time = action
