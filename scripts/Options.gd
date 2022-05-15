extends Node

var sound_on = true

func toggle_sound(value):
	sound_on = value

func serialize():
	return {
		id = "Options",
		sound_on = sound_on
	}

func deserialize(options):
	sound_on = options.get("sound_on", true)

func apply():
	print_debug(sound_on)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !sound_on)
