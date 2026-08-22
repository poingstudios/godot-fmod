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
	FmodServer.initialize()
	FmodServer.load_bank("res://banks/Desktop/Master.bank")
	FmodServer.load_bank("res://banks/Desktop/Master.strings.bank")
	FmodServer.load_bank("res://banks/Desktop/SFX.bank")
	FmodServer.load_bank("res://banks/Desktop/Vehicles.bank")

	# Check is3D for Explosion
	var desc_exp: FmodEventDescription = FmodServer.get_event_description("event:/Weapons/Explosion")
	print("Explosion is_3d: ", desc_exp.is_3d())

	var desc_car: FmodEventDescription = FmodServer.get_event_description("event:/Vehicles/Car Engine")
	print("Car Engine is_3d: ", desc_car.is_3d())

	# Create car engine instance and inspect RPM
	var car: FmodEventInstance = FmodServer.create_event_instance("event:/Vehicles/Car Engine")
	print("Car default RPM: ", car.get_parameter_by_name("RPM"))

	quit(0)
