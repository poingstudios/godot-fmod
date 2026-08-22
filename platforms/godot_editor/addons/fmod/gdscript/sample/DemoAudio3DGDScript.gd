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

@onready var player_root := $Player as Node3D
@onready var character_visual := $Player/CharacterVisual as Node3D
@onready var listener_node := $Player/Listener3D as FmodListener3D
@onready var camera_pivot := $Player/CameraPivot as Node3D
@onready var camera_node := $Player/CameraPivot/Camera3D as Camera3D

@onready var orbiting_emitter := $OrbitPivot/CarEmitter as FmodEventEmitter3D
@onready var orbit_pivot := $OrbitPivot as Node3D

# UI
@onready var status_label := $CanvasLayer/HUD/TopPanel/Margin/VBox/StatusLabel as Label
@onready var info_label := $CanvasLayer/HUD/TopPanel/Margin/VBox/InfoLabel as Label

@onready var rpm_slider := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/RPMSlider as HSlider
@onready var rpm_value := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/RPMValue as Label

@onready var speed_slider := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/SpeedSlider as HSlider
@onready var speed_value := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/SpeedValue as Label

@onready var radius_slider := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/RadiusSlider as HSlider
@onready var radius_value := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/RadiusValue as Label

@onready var height_slider := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/HeightSlider as HSlider
@onready var height_value := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/HeightValue as Label

@onready var btn_pistol := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnPistol as Button
@onready var btn_explosion := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnExplosion as Button
@onready var btn_wood := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnWood as Button
@onready var btn_toggle_car := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons2/BtnToggleCar as Button
@onready var btn_reverse_orbit := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons2/BtnReverse as Button
@onready var btn_reset_pos := $CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons2/BtnReset as Button

# Car Orbit settings
var _orbit_speed := 1.2
var _orbit_radius := 8.0
var _orbit_height := 0.4
var _orbit_direction := 1.0
var _car_playing := true

# Player Movement settings
var _walk_speed := 7.0
var _sprint_speed := 13.0
var _jump_velocity := 9.0
var _gravity := 24.0
var _vertical_velocity := 0.0
var _player_heading := 0.0
var _is_on_ground := true

# Third Person Orbit Camera settings
var _cam_yaw := 0.0
var _cam_pitch := -0.35
var _cam_distance := 7.0
var _mouse_dragging := false

func _ready() -> void:
	FmodServer.initialize()
	_load_banks()

	orbiting_emitter.event_name = "event:/Vehicles/Car Engine"
	orbiting_emitter.set_parameters({"RPM": 3000.0, "Load": 0.6})
	orbiting_emitter.play()
	_update_car_position()
	_update_camera_transform()

	rpm_slider.value_changed.connect(_on_rpm_changed)
	speed_slider.value_changed.connect(_on_speed_changed)
	radius_slider.value_changed.connect(_on_radius_changed)
	height_slider.value_changed.connect(_on_height_changed)

	btn_pistol.pressed.connect(_on_pistol_pressed)
	btn_explosion.pressed.connect(_on_explosion_pressed)
	btn_wood.pressed.connect(_on_wood_pressed)
	btn_toggle_car.pressed.connect(_on_toggle_car_pressed)
	btn_reverse_orbit.pressed.connect(_on_reverse_orbit_pressed)
	btn_reset_pos.pressed.connect(_on_reset_pos_pressed)

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
	_handle_player_movement(delta)

	if _car_playing:
		orbit_pivot.rotate_y(_orbit_speed * _orbit_direction * delta)

	var emitter_pos := orbiting_emitter.global_position
	var listener_pos := listener_node.global_position
	var dist := emitter_pos.distance_to(listener_pos)

	info_label.text = "🏃 Player: (%.1f, %.1f, %.1f) | 🚗 Car: (%.1f, %.1f, %.1f) | 📏 Distance: %.2fm" % [
		listener_pos.x, listener_pos.y, listener_pos.z,
		emitter_pos.x, emitter_pos.y, emitter_pos.z,
		dist
	]

func _handle_player_movement(delta: float) -> void:
	var move_vec := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_vec.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_vec.x += 1.0

	var speed := _sprint_speed if Input.is_key_pressed(KEY_SHIFT) else _walk_speed

	# Jumping and gravity
	if _is_on_ground:
		if Input.is_key_pressed(KEY_SPACE):
			_vertical_velocity = _jump_velocity
			_is_on_ground = false
			FmodServer.play_one_shot_3d("event:/Interactables/Wooden Collision", player_root.global_position)
	else:
		_vertical_velocity -= _gravity * delta
		player_root.global_position.y += _vertical_velocity * delta
		if player_root.global_position.y <= 0.0:
			player_root.global_position.y = 0.0
			_vertical_velocity = 0.0
			_is_on_ground = true

	if move_vec != Vector2.ZERO:
		move_vec = move_vec.normalized()

		# Camera relative directional calculation
		var cam_forward := Vector3(-sin(_cam_yaw), 0.0, -cos(_cam_yaw)).normalized()
		var cam_right := Vector3(cos(_cam_yaw), 0.0, -sin(_cam_yaw)).normalized()

		var world_dir := (cam_right * move_vec.x + cam_forward * -move_vec.y).normalized()
		player_root.global_position += world_dir * speed * delta

		# Smooth character rotation towards movement direction
		var target_heading := atan2(-world_dir.x, -world_dir.z)
		_player_heading = lerp_angle(_player_heading, target_heading, 14.0 * delta)
		character_visual.rotation.y = _player_heading
		listener_node.rotation.y = _player_heading

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			_mouse_dragging = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_cam_distance = maxf(2.0, _cam_distance - 0.6)
			_update_camera_transform()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_cam_distance = minf(30.0, _cam_distance + 0.6)
			_update_camera_transform()
		elif mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_spawn_3d_shot_at_mouse(mb.position)
	elif event is InputEventMouseMotion and _mouse_dragging:
		var mm := event as InputEventMouseMotion
		_cam_yaw -= mm.relative.x * 0.005
		_cam_pitch = clampf(_cam_pitch - mm.relative.y * 0.005, deg_to_rad(-80.0), deg_to_rad(50.0))
		_update_camera_transform()
	elif event is InputEventKey and event.pressed:
		var ke := event as InputEventKey
		if ke.keycode == KEY_1:
			_cam_distance = 7.0
			_cam_pitch = -0.35
			_update_camera_transform()
			status_label.text = "📷 3rd-Person Standard Orbit (7m)"
		elif ke.keycode == KEY_2:
			_cam_distance = 2.5
			_cam_pitch = -0.15
			_update_camera_transform()
			status_label.text = "📷 3rd-Person Over-The-Shoulder (2.5m)"
		elif ke.keycode == KEY_3:
			_cam_distance = 20.0
			_cam_pitch = -1.45
			_update_camera_transform()
			status_label.text = "📷 Top-Down Birds-Eye View (20m)"

func _update_camera_transform() -> void:
	if not camera_pivot or not camera_node:
		return
	camera_pivot.rotation = Vector3(0.0, _cam_yaw, 0.0)
	var offset_z := _cam_distance * cos(_cam_pitch)
	var offset_y := -_cam_distance * sin(_cam_pitch)
	camera_node.position = Vector3(0.0, offset_y, offset_z)
	camera_node.rotation = Vector3(_cam_pitch, 0.0, 0.0)

func _spawn_3d_shot_at_mouse(screen_pos: Vector2) -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return

	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var spawn_pos := from + dir * 6.0
	FmodServer.play_one_shot_3d("event:/Weapons/Pistol", spawn_pos)

	status_label.text = "🎯 3D One-Shot fired at: (%.1f, %.1f, %.1f)" % [spawn_pos.x, spawn_pos.y, spawn_pos.z]

func _update_car_position() -> void:
	orbiting_emitter.position = Vector3(0.0, _orbit_height, -_orbit_radius)

func _on_rpm_changed(value: float) -> void:
	rpm_value.text = "%d RPM" % int(value)
	orbiting_emitter.set_parameter("RPM", value)

func _on_speed_changed(value: float) -> void:
	_orbit_speed = value
	speed_value.text = "%.1fx" % value

func _on_radius_changed(value: float) -> void:
	_orbit_radius = value
	radius_value.text = "%.1fm" % value
	_update_car_position()

func _on_height_changed(value: float) -> void:
	_orbit_height = value
	height_value.text = "%.1fm" % value
	_update_car_position()

func _on_pistol_pressed() -> void:
	var pos := orbiting_emitter.global_position
	FmodServer.play_one_shot_3d("event:/Weapons/Pistol", pos)
	status_label.text = "🔫 Pistol 3D shot fired at Car position!"

func _on_explosion_pressed() -> void:
	var pos := orbiting_emitter.global_position
	FmodServer.play_one_shot_3d("event:/Weapons/Explosion", pos)
	status_label.text = "💥 Explosion 3D triggered at Car position!"

func _on_wood_pressed() -> void:
	var pos := listener_node.global_position + character_visual.global_transform.basis.z * -1.5
	FmodServer.play_one_shot_3d("event:/Interactables/Wooden Collision", pos)
	status_label.text = "🪵 Wooden Collision played right in front of Character!"

func _on_toggle_car_pressed() -> void:
	_car_playing = not _car_playing
	if _car_playing:
		orbiting_emitter.play()
		btn_toggle_car.text = "⏸ Pause"
	else:
		orbiting_emitter.stop(FmodServer.STOP_ALLOWFADEOUT)
		btn_toggle_car.text = "▶ Resume"

func _on_reverse_orbit_pressed() -> void:
	_orbit_direction *= -1.0
	status_label.text = "🔄 Orbit direction: %s" % ("Clockwise" if _orbit_direction > 0 else "Counter-Clockwise")

func _on_reset_pos_pressed() -> void:
	player_root.global_position = Vector3.ZERO
	_player_heading = 0.0
	_cam_yaw = 0.0
	_cam_pitch = -0.35
	_cam_distance = 7.0
	character_visual.rotation = Vector3.ZERO
	listener_node.rotation = Vector3.ZERO
	_update_camera_transform()
	status_label.text = "📍 Character reset to origin (0, 0, 0)"
