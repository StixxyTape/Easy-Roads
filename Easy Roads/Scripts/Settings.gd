extends TextureRect

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var musicLabel : Label = $Music/MusicButton/Label
@onready var audioLabel : Label = $Audio/AudioButton/Label
var open : bool

var selectSound = preload("res://Sounds/Menu.wav")

func _process(_delta):
	if Global.music:
		musicLabel.text = "On"
	else:
		musicLabel.text = "Off"
	
	if Global.sounds:
		audioLabel.text = "On"
	else:
		audioLabel.text = "Off"
		
func _on_settings_button_pressed():
	if open and !Global.tutorial:
		open = false
		anim.play("close")
	elif !open and !Global.tutorial:
		open = true
		anim.play("open")
	AudioManager.PlaySound(selectSound)

func _on_music_button_pressed():
	Global.music = !Global.music
	AudioManager.PlaySound(selectSound)

func _on_audio_button_pressed():
	Global.sounds = !Global.sounds
	AudioManager.PlaySound(selectSound)


func _on_settings_button_mouse_entered():
	Global.overButton = true


func _on_settings_button_mouse_exited():
	Global.overButton = false


func _on_music_button_mouse_entered():
	Global.overButton = true


func _on_music_button_mouse_exited():
	Global.overButton = false


func _on_audio_button_mouse_entered():
	Global.overButton = true


func _on_audio_button_mouse_exited():
	Global.overButton = false
