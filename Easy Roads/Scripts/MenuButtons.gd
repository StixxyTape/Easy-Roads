extends TextureButton

@export var action : String = "Action"
var selectSound = preload("res://Sounds/Menu.wav")
var startSound = preload("res://Sounds/Select.wav")

func _ready():
	self.mouse_entered.connect(_on_button_hovered)
	self.mouse_exited.connect(_on_button_exit)
	self.pressed.connect(_on_button_press)

func _on_button_hovered():
	self_modulate = Color("c9c9c9dc")

func _on_button_exit():
	self_modulate = Color("fff")

func _on_button_press():
	self_modulate = Color("999999dc")
	if action == "quit":
		AudioManager.PlaySound(selectSound)
		await get_tree().create_timer(0.2).timeout
		get_tree().quit()
	elif action == "play":
		AudioManager.PlaySound(startSound)
		Global.Reset()
		if !Global.tutorialCompleted:
			Global.tutorial = true
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
