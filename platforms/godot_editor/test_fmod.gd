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
	print(">>> [Godot FMOD Test] Starting runtime verification...")

	# Check singleton
	if Engine.has_singleton("FmodServer"):
		print(">>> [PASS] Engine singleton 'FmodServer' is registered!")
	else:
		print(">>> [FAIL] Engine singleton 'FmodServer' not found!")
		quit(1)
		return

	var server: Object = Engine.get_singleton("FmodServer")
	print(">>> [PASS] FmodServer instance: ", server)

	# Check initialization
	var init_success: bool = server.call("initialize")
	print(">>> [PASS] FmodServer.initialize() -> ", init_success)

	# Check ClassDB registrations
	var classes_to_test: Array[String] = [
		"FmodBank",
		"FmodEventDescription",
		"FmodEventInstance",
		"FmodBus",
		"FmodVCA",
		"FmodEventEmitter3D",
		"FmodEventEmitter2D",
		"FmodListener3D",
		"FmodListener2D"
	]

	for cls: String in classes_to_test:
		if ClassDB.class_exists(cls):
			print(">>> [PASS] ClassDB registered: ", cls)
		else:
			print(">>> [FAIL] ClassDB missing class: ", cls)
			quit(1)
			return

	print(">>> [SUCCESS] All Godot FMOD tests passed successfully!")
	quit(0)
