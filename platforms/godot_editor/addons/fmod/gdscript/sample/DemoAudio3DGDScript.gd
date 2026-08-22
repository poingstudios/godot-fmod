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

extends Node3D

@onready var listener_node := $ListenerOrigin/Listener3D as FmodListener3D
@onready var listener_origin := $ListenerOrigin as Node3D
@onready var orbiting_emitter := $OrbitPivot/CarEmitter as FmodEventEmitter3D
@onready var orbit_pivot := $OrbitPivot as Node3D

# UI
@onready var status_label := $CanvasLayer/HUD/TopPanel/Margin/VBox/StatusLabel as Label
@onready var info_label := $CanvasLayer/HUD/TopPanel/Margin/VBox/InfoLabel as Label
@onready var rpm_slider := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/RPMSlider as HSlider
@onready var rpm_value := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/RPMValue as Label
@onready var speed_slider := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/SpeedSlider as HSlider
@onready var speed_value := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/SpeedValue as Label
@onready var btn_pistol := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnPistol as Button
@onready var btn_explosion := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnExplosion as Button
@onready var btn_toggle_car := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnToggleCar as Button

var _orbit_speed := 1.2
var _car_playing := true
var _mouse_dragging := false

func _ready() -> void:
	FmodServer.initialize()
	_load_banks()

	orbiting_emitter.event_name = "event:/Vehicles/Car Engine"
	orbiting_emitter.set_parameters({"RPM": 3000.0, "Load": 0.6})
	orbiting_emitter.play()

	rpm_slider.value_changed.connect(_on_rpm_changed)
	speed_slider.value_changed.connect(_on_speed_changed)
	btn_pistol.pressed.connect(_on_pistol_pressed)
	btn_explosion.pressed.connect(_on_explosion_pressed)
	btn_toggle_car.pressed.connect(_on_toggle_car_pressed)

func _load_banks() -> void:
	var candidates: Array[String] = [
		ProjectSettings.get_setting("fmod/banks/banks_path", "res://banks/Desktop/"),
		"res://banks/Desktop/",
		"res://banks/",
		"res://"
	]
	var found_dir := "res://banks/Desktop/"
	for dir_path in candidates:
		if FileAccess.file_exists(dir_path.path_join("Master.bank")):
			found_dir = dir_path
			break

	FmodServer.load_bank(found_dir.path_join("Master.strings.bank"))
	FmodServer.load_bank(found_dir.path_join("Master.bank"))
	FmodServer.load_bank(found_dir.path_join("Vehicles.bank"))
	FmodServer.load_bank(found_dir.path_join("SFX.bank"))
	FmodServer.load_bank(found_dir.path_join("Music.bank"))

func _process(delta: float) -> void:
	FmodServer.update()

	if _car_playing:
		orbit_pivot.rotate_y(_orbit_speed * delta)

	var emitter_pos := orbiting_emitter.global_position
	var listener_pos := listener_node.global_position
	var dist := emitter_pos.distance_to(listener_pos)

	info_label.text = "🚗 Car Position: (%.1f, %.1f, %.1f) | 🎧 Distance to Listener: %.2fm" % [
		emitter_pos.x, emitter_pos.y, emitter_pos.z, dist
	]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			_mouse_dragging = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_spawn_3d_shot_at_mouse(mb.position)
	elif event is InputEventMouseMotion and _mouse_dragging:
		var mm := event as InputEventMouseMotion
		var delta_rot := mm.relative * 0.005
		listener_origin.rotate_y(-delta_rot.x)

func _spawn_3d_shot_at_mouse(screen_pos: Vector2) -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return

	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var spawn_pos := from + dir * 6.0
	FmodServer.play_one_shot_3d("event:/Weapons/Pistol", spawn_pos)

	status_label.text = "🎯 3D One-Shot fired at: (%.1f, %.1f, %.1f)" % [spawn_pos.x, spawn_pos.y, spawn_pos.z]

func _on_rpm_changed(value: float) -> void:
	rpm_value.text = "%d RPM" % int(value)
	orbiting_emitter.set_parameter("RPM", value)

func _on_speed_changed(value: float) -> void:
	_orbit_speed = value
	speed_value.text = "%.1fx" % value

func _on_pistol_pressed() -> void:
	var pos := orbiting_emitter.global_position
	FmodServer.play_one_shot_3d("event:/Weapons/Pistol", pos)
	status_label.text = "🔫 Pistol 3D shot fired at Car position!"

func _on_explosion_pressed() -> void:
	var pos := orbiting_emitter.global_position
	FmodServer.play_one_shot_3d("event:/Weapons/Explosion", pos)
	status_label.text = "💥 Explosion 3D triggered at Car position!"

func _on_toggle_car_pressed() -> void:
	_car_playing = not _car_playing
	if _car_playing:
		orbiting_emitter.play()
		btn_toggle_car.text = "⏸ Pause Engine"
	else:
		orbiting_emitter.stop(FmodServer.STOP_ALLOWFADEOUT)
		btn_toggle_car.text = "▶ Resume Engine"
