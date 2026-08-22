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

extends Control

@onready var status_label := $TopPanel/Margin/VBoxContainer/StatusLabel as Label
@onready var param_slider := $TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxParam/ParamSlider as HSlider
@onready var param_value_label := $TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxParam/ParamValue as Label
@onready var rpm_slider := $TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxRPM/RPMSlider as HSlider
@onready var rpm_value_label := $TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxRPM/RPMValue as Label
@onready var volume_slider := $TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxVolume/VolumeSlider as HSlider
@onready var volume_value_label := $TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxVolume/VolumeValue as Label
@onready var spatial_emitter := $SpatialEmitter as FmodEventEmitter2D
@onready var spatial_icon := $SpatialEmitter/Icon as Sprite2D
@onready var listener_node := $Listener as FmodListener2D

var music_instance: FmodEventInstance = null
var is_moving_emitter := true

func _ready() -> void:
	FmodServer.initialize()

	FmodServer.load_bank("res://banks/Desktop/Master.bank")
	FmodServer.load_bank("res://banks/Desktop/Master.strings.bank")
	FmodServer.load_bank("res://banks/Desktop/Music.bank")
	FmodServer.load_bank("res://banks/Desktop/SFX.bank")
	FmodServer.load_bank("res://banks/Desktop/Vehicles.bank")

	spatial_emitter.set_parameters({"RPM": 2000.0, "Load": 0.5})

	status_label.text = "Click anywhere across the full screen to test spatial sound!"

	param_slider.value_changed.connect(_on_param_slider_changed)
	rpm_slider.value_changed.connect(_on_rpm_slider_changed)
	volume_slider.value_changed.connect(_on_volume_slider_changed)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_fire_shot_at(mb.position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_fire_shot_at(mb.position)

func _process(_delta: float) -> void:
	FmodServer.update()

	if is_moving_emitter:
		var time := Time.get_ticks_msec() / 1000.0
		var screen_width := get_viewport_rect().size.x
		var x_pos := (sin(time * 1.5) * 0.4 + 0.5) * screen_width
		spatial_emitter.position.x = x_pos
		spatial_emitter.position.y = 520.0

func _fire_shot_at(click_pos: Vector2) -> void:
	# Check hit on moving emitter logo
	var emitter_pos := spatial_emitter.position
	if (click_pos - emitter_pos).length() <= 50.0:
		FmodServer.play_one_shot_2d("event:/Interactables/Wooden Collision", emitter_pos)
		status_label.text = "🎯 DIRECT HIT on Moving Logo! (Wooden Collision)"
		_punch_icon(spatial_icon, Vector2(0.4, 0.4), Vector2(0.65, 0.65))
		_spawn_visual_shot(click_pos, "DIRECT HIT!", Color(1.0, 0.9, 0.2))
		return

	# Check hit on center listener logo
	var listener_pos := listener_node.position
	if (click_pos - listener_pos).length() <= 50.0:
		var listener_icon := listener_node.get_node("ListenerIcon") as Sprite2D
		FmodServer.play_one_shot("event:/Interactables/Wooden Collision")
		status_label.text = "🎧 DIRECT HIT on Center Listener! (Wooden Collision)"
		if listener_icon != null:
			_punch_icon(listener_icon, Vector2(0.5, 0.5), Vector2(0.8, 0.8))
		_spawn_visual_shot(click_pos, "LISTENER HIT!", Color(0.3, 0.9, 1.0))
		return

	# Otherwise fire spatial pistol shot
	FmodServer.play_one_shot_2d("event:/Weapons/Pistol", click_pos)

	var dx := click_pos.x - listener_pos.x
	var distance_m := (click_pos - listener_pos).length() * 0.02

	var side_str := "Center"
	if dx < -30.0:
		side_str = "Left Ear (" + str(int(abs(dx))) + "px)"
	elif dx > 30.0:
		side_str = "Right Ear (" + str(int(dx)) + "px)"

	status_label.text = "Shot at (" + str(int(click_pos.x)) + ", " + str(int(click_pos.y)) + ") -> " + side_str + " | ~" + str(snappedf(distance_m, 0.1)) + "m"
	_spawn_visual_shot(click_pos, side_str)

func _punch_icon(sprite: Sprite2D, base_scale: Vector2, punch_scale: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "scale", punch_scale, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", base_scale, 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _spawn_visual_shot(pos: Vector2, text_info: String, shot_color: Color = Color(1.0, 0.3, 0.2, 1.0)) -> void:
	var marker := Node2D.new()
	marker.position = pos
	add_child(marker)

	var circle := ColorRect.new()
	circle.size = Vector2(16, 16)
	circle.position = Vector2(-8, -8)
	circle.color = shot_color
	marker.add_child(circle)

	var label := Label.new()
	label.text = "🎯 " + text_info
	label.position = Vector2(-75, -30)
	label.size = Vector2(150, 25)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = shot_color
	marker.add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(circle, "scale", Vector2(3.0, 3.0), 0.4)
	tween.tween_property(marker, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(marker.queue_free)

func _on_play_sfx_pressed() -> void:
	FmodServer.play_one_shot("event:/Weapons/Explosion")
	status_label.text = "Played One-Shot SFX: Weapons/Explosion (Center)"

func _on_start_music_pressed() -> void:
	if music_instance == null:
		music_instance = FmodServer.create_event_instance("event:/Music/Level 01")

	if music_instance != null:
		music_instance.start()
		status_label.text = "Started Music: Level 01"

func _on_pause_music_pressed() -> void:
	if music_instance != null:
		var current_paused := music_instance.get_paused()
		music_instance.set_paused(!current_paused)
		status_label.text = "Music Paused: " + str(!current_paused)

func _on_stop_music_pressed() -> void:
	if music_instance != null:
		music_instance.stop(FmodServer.STOP_ALLOWFADEOUT)
		status_label.text = "Music Stopped (Fadeout)"

func _on_toggle_emitter_pressed() -> void:
	if spatial_emitter.is_playing():
		spatial_emitter.stop(FmodServer.STOP_ALLOWFADEOUT)
		status_label.text = "Spatial Emitter Stopped"
	else:
		spatial_emitter.play()
		status_label.text = "Spatial Emitter Playing (Panning left/right)"

func _on_param_slider_changed(value: float) -> void:
	param_value_label.text = str(snappedf(value, 0.01))
	if music_instance != null:
		music_instance.set_parameter_by_name("Progression", value)

func _on_rpm_slider_changed(value: float) -> void:
	rpm_value_label.text = str(int(value))
	spatial_emitter.set_parameter("RPM", value)

func _on_volume_slider_changed(value: float) -> void:
	volume_value_label.text = str(snappedf(value, 0.01))
	var master_bus := FmodServer.get_bus("bus:/")
	if master_bus != null:
		master_bus.set_volume(value)

func _exit_tree() -> void:
	if music_instance != null:
		music_instance.release()
		music_instance = null
	FmodServer.shutdown()
