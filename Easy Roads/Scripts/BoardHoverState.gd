extends TextureRect

func _ready():
	self.mouse_entered.connect(_on_button_hovered)
	self.mouse_exited.connect(_on_button_exit)

func _on_button_hovered():
	if !Global.tutorial:
		Global.overButton = true

func _on_button_exit():
	if !Global.tutorial:
		Global.overButton = false
