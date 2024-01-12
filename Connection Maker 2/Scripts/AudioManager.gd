extends Node

func PlaySound(stream: AudioStream):
	if Global.sounds:
		var streamPlayer = AudioStreamPlayer.new()
		streamPlayer.stream = stream
		streamPlayer.finished.connect(RemoveNode.bind(streamPlayer))
		add_child(streamPlayer)
		streamPlayer.volume_db = -5
		streamPlayer.play()

func RemoveNode(instance: AudioStreamPlayer):
	instance.queue_free()
