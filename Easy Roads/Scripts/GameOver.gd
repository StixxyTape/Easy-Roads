extends Node2D

@onready var descriptionLabel : Label = $CanvasLayer/Description

func _ready():
	if Global.day == 1:
		descriptionLabel.text = str("You made it to ", Global.day, " Day")
	else:
		descriptionLabel.text = str("You made it to ", Global.day, " Days")
