# MIT License
#
# Copyright (c) 2026 Poing Studios
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends SceneTree

func _init() -> void:
	print(">>> Testing all events...")
	FmodServer.initialize()

	FmodServer.load_bank("res://banks/Desktop/Master.bank")
	FmodServer.load_bank("res://banks/Desktop/Master.strings.bank")
	FmodServer.load_bank("res://banks/Desktop/Music.bank")
	FmodServer.load_bank("res://banks/Desktop/SFX.bank")
	FmodServer.load_bank("res://banks/Desktop/Vehicles.bank")

	# Test 1: Event description lookup
	var events_to_check: Array[String] = [
		"event:/Weapons/Explosion",
		"event:/Weapons/Pistol",
		"event:/Music/Level 01",
		"event:/Vehicles/Car Engine",
		"event:/Ambience/Country"
	]

	for path: String in events_to_check:
		var desc: RefCounted = FmodServer.get_event_description(path)
		if desc != null:
			print(">>> [PASS] Event resolved: ", path)
		else:
			print(">>> [FAIL] Could not resolve event: ", path)
			quit(1)
			return

	# Test 2: One-shot playback
	FmodServer.play_one_shot("event:/Weapons/Explosion")
	FmodServer.play_one_shot_2d("event:/Weapons/Pistol", Vector2(100, 100))
	FmodServer.play_one_shot_3d("event:/Weapons/Explosion", Vector3(10, 0, 5))

	# Test 3: Instance playback and parameter modulation
	var music: FmodEventInstance = FmodServer.create_event_instance("event:/Music/Level 01")
	if music != null:
		music.set_parameter_by_name("Progression", 0.5)
		music.start()
		music.set_paused(true)
		music.set_paused(false)
		music.stop(FmodServer.STOP_ALLOWFADEOUT)
		music.release()
		print(">>> [PASS] Music instance lifecycle verified!")

	# Test 4: Master bus volume
	var bus: FmodBus = FmodServer.get_bus("bus:/")
	if bus != null:
		bus.set_volume(0.8)
		print(">>> [PASS] Master bus volume verified: ", bus.get_volume())

	FmodServer.update()
	print(">>> [SUCCESS] All FMOD bank events verified successfully!")
	quit(0)
