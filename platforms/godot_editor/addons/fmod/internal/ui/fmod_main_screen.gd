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
extends PanelContainer

# Top Bar
@onready var status_badge := $Margin/VBox/TopBar/Margin/HBox/StatusBadge as Label
@onready var btn_reload_banks := $Margin/VBox/TopBar/Margin/HBox/BtnReloadBanks as Button
@onready var btn_panic_stop := $Margin/VBox/TopBar/Margin/HBox/BtnPanicStop as Button

# Left Browser
@onready var search_input := $Margin/VBox/HSplit/LeftPanel/Margin/VBox/SearchInput as LineEdit
@onready var event_tree := $Margin/VBox/HSplit/LeftPanel/Margin/VBox/EventTree as Tree
@onready var bank_list := $Margin/VBox/HSplit/LeftPanel/Margin/VBox/BankList as ItemList

# Right Tabs
@onready var right_tab_container := $Margin/VBox/HSplit/RightPanel/TabContainer as TabContainer

# Tab 1: Event Audition Station
@onready var selected_event_title := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/EventTitle as Label
@onready var event_meta_label := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/EventMeta as Label
@onready var btn_play := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/TransportHBox/BtnPlay as Button
@onready var btn_pause := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/TransportHBox/BtnPause as Button
@onready var btn_stop := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/TransportHBox/BtnStop as Button
@onready var timeline_slider := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/TimelineHBox/TimelineSlider as HSlider
@onready var timeline_label := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/TimelineHBox/TimeLabel as Label
@onready var pitch_slider := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/SlidersGrid/PitchSlider as HSlider
@onready var pitch_value := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/SlidersGrid/PitchVal as Label
@onready var vol_slider := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/SlidersGrid/VolSlider as HSlider
@onready var vol_value := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/SlidersGrid/VolVal as Label
@onready var custom_event_param_input := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/ParamSection/VBox/HBoxAddParam/ParamInput as LineEdit
@onready var btn_add_event_param := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/ParamSection/VBox/HBoxAddParam/BtnAddParam as Button
@onready var param_container := $Margin/VBox/HSplit/RightPanel/TabContainer/Audition/Margin/VBox/ParamSection/VBox/ParamVBox as VBoxContainer

# Tab 2: Mixing Console (Buses & VCAs)
@onready var bus_container := $Margin/VBox/HSplit/RightPanel/TabContainer/Mixer/Scroll/VBox/BusesSection/BusGrid as VBoxContainer
@onready var custom_bus_input := $Margin/VBox/HSplit/RightPanel/TabContainer/Mixer/Scroll/VBox/BusesSection/HBoxAdd/BusInput as LineEdit
@onready var btn_add_bus := $Margin/VBox/HSplit/RightPanel/TabContainer/Mixer/Scroll/VBox/BusesSection/HBoxAdd/BtnAddBus as Button
@onready var vca_container := $Margin/VBox/HSplit/RightPanel/TabContainer/Mixer/Scroll/VBox/VCASection/VCAGrid as VBoxContainer
@onready var custom_vca_input := $Margin/VBox/HSplit/RightPanel/TabContainer/Mixer/Scroll/VBox/VCASection/HBoxAdd/VCAInput as LineEdit
@onready var btn_add_vca := $Margin/VBox/HSplit/RightPanel/TabContainer/Mixer/Scroll/VBox/VCASection/HBoxAdd/BtnAddVCA as Button

# Tab 3: Global Parameters
@onready var global_param_container := $Margin/VBox/HSplit/RightPanel/TabContainer/Globals/Scroll/VBox/ParamGrid as VBoxContainer
@onready var custom_param_input := $Margin/VBox/HSplit/RightPanel/TabContainer/Globals/Scroll/VBox/HBoxAdd/ParamInput as LineEdit
@onready var btn_add_global_param := $Margin/VBox/HSplit/RightPanel/TabContainer/Globals/Scroll/VBox/HBoxAdd/BtnAddParam as Button

# Tab 4: Banks Lifecycle
@onready var bank_cards_container := $Margin/VBox/HSplit/RightPanel/TabContainer/Banks/Scroll/VBox/BankGrid as VBoxContainer

# State
var _active_instance: FmodEventInstance = null
var _selected_event_path := ""
var _loaded_banks: Dictionary = {}
var _discovered_bank_paths: Array[String] = []
var _user_events: Array[String] = []
var _user_buses: Array[String] = []
var _user_vcas: Array[String] = []
var _user_globals: Array[String] = []
var _param_sliders: Dictionary = {}

const SettingsService := preload("res://addons/fmod/internal/services/settings_service.gd")
const CONFIG_FILE_PATH := "user://fmod_studio_workspace_settings.cfg"

func _ready() -> void:
	if not Engine.is_editor_hint():
		return

	SettingsService.register_settings()
	_load_persistent_settings()
	_init_fmod_system()
	_scan_and_load_project_banks()
	_populate_event_tree("")
	_build_bus_strips()
	_build_vca_strips()
	_build_global_param_strips()
	_build_bank_lifecycle_cards()

	search_input.text_changed.connect(_on_search_text_changed)
	btn_play.pressed.connect(_on_play_pressed)
	btn_pause.pressed.connect(_on_pause_pressed)
	btn_stop.pressed.connect(_on_stop_pressed)
	btn_reload_banks.pressed.connect(_on_reload_banks_pressed)
	btn_panic_stop.pressed.connect(_on_panic_stop_pressed)

	pitch_slider.value_changed.connect(_on_pitch_changed)
	vol_slider.value_changed.connect(_on_vol_changed)
	timeline_slider.value_changed.connect(_on_timeline_seek)

	btn_add_event_param.pressed.connect(_on_add_event_parameter)
	btn_add_bus.pressed.connect(_on_add_custom_bus)
	btn_add_vca.pressed.connect(_on_add_custom_vca)
	btn_add_global_param.pressed.connect(_on_add_custom_global_param)

	if not _user_events.is_empty():
		_select_event(_user_events[0])

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() or not ClassDB.class_exists("FmodServer"):
		return

	FmodServer.update()

	if _active_instance and _active_instance.is_valid():
		var pos_ms := _active_instance.get_timeline_position()
		var desc := FmodServer.get_event_description(_selected_event_path)
		var total_ms := desc.get_length() if desc and desc.is_valid() else 0

		if not timeline_slider.has_focus() and total_ms > 0:
			timeline_slider.max_value = float(total_ms)
			timeline_slider.value = float(pos_ms)
			timeline_label.text = "%s / %s" % [_format_time(pos_ms), _format_time(total_ms)]

		var is_paused := _active_instance.get_paused()
		var state := _active_instance.get_playback_state()
		if state == FmodServer.PLAYBACK_PLAYING:
			status_badge.text = "● PLAYING (%s)" % ("PAUSED" if is_paused else "ACTIVE")
			status_badge.modulate = Color(1.0, 0.8, 0.2) if is_paused else Color(0.3, 0.9, 0.4)
		elif state == FmodServer.PLAYBACK_STOPPED:
			status_badge.text = "● FMOD READY"
			status_badge.modulate = Color(0.3, 0.9, 0.4)

func _init_fmod_system() -> void:
	if ClassDB.class_exists("FmodServer"):
		FmodServer.initialize()
		status_badge.text = "● FMOD READY"
		status_badge.modulate = Color(0.3, 0.9, 0.4)
	else:
		status_badge.text = "● GDExtension Unloaded"
		status_badge.modulate = Color(0.9, 0.3, 0.3)

# --- Configuration & Discovery ---

func _load_persistent_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG_FILE_PATH)
	if err == OK:
		_user_events = cfg.get_value("workspace", "events", [])
		_user_buses = cfg.get_value("workspace", "buses", ["bus:/"])
		_user_vcas = cfg.get_value("workspace", "vcas", ["vca:/"])
		_user_globals = cfg.get_value("workspace", "globals", [])
	else:
		_user_buses = ["bus:/"]
		_user_vcas = ["vca:/"]
		_user_events = []
		_user_globals = []

func _save_persistent_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("workspace", "events", _user_events)
	cfg.set_value("workspace", "buses", _user_buses)
	cfg.set_value("workspace", "vcas", _user_vcas)
	cfg.set_value("workspace", "globals", _user_globals)
	cfg.save(CONFIG_FILE_PATH)

func _scan_and_load_project_banks() -> void:
	bank_list.clear()
	_discovered_bank_paths.clear()

	var search_dir: String = SettingsService.get_setting("fmod/banks/banks_path", "res://")
	if search_dir.is_empty():
		search_dir = "res://"

	_find_bank_files_recursive(search_dir, _discovered_bank_paths)

	# Always load Master.strings.bank first if present
	for bpath in _discovered_bank_paths:
		if "strings" in bpath.to_lower():
			var sbank := FmodServer.load_bank(bpath)
			if sbank and sbank.is_valid():
				_loaded_banks[bpath] = sbank

	for bpath in _discovered_bank_paths:
		if not _loaded_banks.has(bpath):
			var bank := FmodServer.load_bank(bpath)
			if bank and bank.is_valid():
				_loaded_banks[bpath] = bank
				bank_list.add_item("✔ " + bpath.get_file())
			else:
				bank_list.add_item("✖ " + bpath.get_file())
		else:
			bank_list.add_item("✔ " + bpath.get_file())

	_discover_project_audio_elements()

func _find_bank_files_recursive(dir_path: String, out_paths: Array[String]) -> void:
	if not DirAccess.dir_exists_absolute(dir_path):
		return
	var dir := DirAccess.open(dir_path)
	if not dir:
		return

	dir.list_dir_begin()
	var item := dir.get_next()
	while item != "":
		if item.begins_with("."):
			item = dir.get_next()
			continue
		var full_path := dir_path.path_join(item)
		if dir.current_is_dir():
			if not item.begins_with(".") and item != "tmp" and item != ".godot":
				_find_bank_files_recursive(full_path, out_paths)
		elif item.ends_with(".bank"):
			out_paths.append(full_path)
		item = dir.get_next()

func _discover_project_audio_elements() -> void:
	var regex := RegEx.new()
	regex.compile("(event|bus|vca):/[a-zA-Z0-9_/ -]+")

	var script_files: Array[String] = []
	_find_source_files_recursive("res://", script_files)

	var has_new := false
	for fpath in script_files:
		var f := FileAccess.open(fpath, FileAccess.READ)
		if f:
			var content := f.get_as_text()
			var matches := regex.search_all(content)
			for m in matches:
				var path_found := m.get_string()
				if path_found.begins_with("event:/") and not _user_events.has(path_found):
					_user_events.append(path_found)
					has_new = true
				elif path_found.begins_with("bus:/") and not _user_buses.has(path_found):
					_user_buses.append(path_found)
					has_new = true
				elif path_found.begins_with("vca:/") and not _user_vcas.has(path_found):
					_user_vcas.append(path_found)
					has_new = true

	if has_new:
		_save_persistent_settings()

func _find_source_files_recursive(dir_path: String, out_paths: Array[String]) -> void:
	if not DirAccess.dir_exists_absolute(dir_path):
		return
	var dir := DirAccess.open(dir_path)
	if not dir:
		return

	dir.list_dir_begin()
	var item := dir.get_next()
	while item != "":
		if item.begins_with(".") or item == "tmp" or item == ".godot":
			item = dir.get_next()
			continue
		var full_path := dir_path.path_join(item)
		if dir.current_is_dir():
			_find_source_files_recursive(full_path, out_paths)
		elif item.ends_with(".gd") or item.ends_with(".cs") or item.ends_with(".tscn"):
			out_paths.append(full_path)
		item = dir.get_next()

# --- Event Explorer ---

func _populate_event_tree(filter_text: String) -> void:
	event_tree.clear()
	var root := event_tree.create_item()
	event_tree.hide_root = true

	var query := filter_text.strip_edges().to_lower()

	for path in _user_events:
		if not query.is_empty() and not query in path.to_lower():
			continue

		var item := event_tree.create_item(root)
		item.set_text(0, path)
		item.set_metadata(0, path)

	if not event_tree.item_selected.is_connected(_on_event_tree_item_selected):
		event_tree.item_selected.connect(_on_event_tree_item_selected)

func _on_search_text_changed(new_text: String) -> void:
	_populate_event_tree(new_text)

func _on_event_tree_item_selected() -> void:
	var selected := event_tree.get_selected()
	if selected:
		var path: String = selected.get_metadata(0)
		_select_event(path)

func _select_event(path: String) -> void:
	_selected_event_path = path
	selected_event_title.text = "Event: " + path

	var desc := FmodServer.get_event_description(path)
	if desc and desc.is_valid():
		var is_3d := desc.is_3d()
		var is_oneshot := desc.is_oneshot()
		var len_ms := desc.get_length()
		event_meta_label.text = "Duration: %s (%d ms) | Mode: %s | Type: %s" % [
			_format_time(len_ms),
			len_ms,
			"3D Spatial" if is_3d else "2D Panned",
			"One-Shot" if is_oneshot else "Continuous"
		]
		timeline_slider.max_value = float(len_ms)
	else:
		event_meta_label.text = "Bank not loaded or event description not found."

func _on_add_event_parameter() -> void:
	var pname := custom_event_param_input.text.strip_edges()
	if not pname.is_empty():
		_create_event_param_slider(pname, 0.0, 1.0, 0.01, 0.0)
		custom_event_param_input.text = ""

func _create_event_param_slider(pname: String, pmin: float, pmax: float, pstep: float, pdef: float) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var lbl := Label.new()
	lbl.text = pname + ":"
	lbl.custom_minimum_size = Vector2(90, 0)
	hbox.add_child(lbl)

	var slider := HSlider.new()
	slider.min_value = pmin
	slider.max_value = pmax
	slider.step = pstep
	slider.value = pdef
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(slider)

	var val_lbl := Label.new()
	val_lbl.text = str(slider.value)
	val_lbl.custom_minimum_size = Vector2(45, 0)
	hbox.add_child(val_lbl)

	slider.value_changed.connect(func(v: float):
		val_lbl.text = "%.2f" % v if pstep < 1.0 else str(int(v))
		if _active_instance and _active_instance.is_valid():
			_active_instance.set_parameter_by_name(pname, v)
	)

	_param_sliders[pname] = slider
	param_container.add_child(hbox)

# --- Mixer (Buses & VCAs) ---

func _build_bus_strips() -> void:
	for child in bus_container.get_children():
		child.queue_free()

	for bus_path in _user_buses:
		_create_bus_strip(bus_path)

func _create_bus_strip(bus_path: String) -> void:
	var card := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	var name_lbl := Label.new()
	name_lbl.text = bus_path
	name_lbl.custom_minimum_size = Vector2(140, 0)
	hbox.add_child(name_lbl)

	var slider := HSlider.new()
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(slider)

	var val_lbl := Label.new()
	val_lbl.text = "100%"
	val_lbl.custom_minimum_size = Vector2(45, 0)
	hbox.add_child(val_lbl)

	var btn_mute := Button.new()
	btn_mute.text = "🔊 Mute"
	hbox.add_child(btn_mute)

	var btn_pause_bus := Button.new()
	btn_pause_bus.text = "⏸ Pause"
	hbox.add_child(btn_pause_bus)

	var btn_stop_bus := Button.new()
	btn_stop_bus.text = "⏹ Stop All"
	hbox.add_child(btn_stop_bus)

	slider.value_changed.connect(func(val: float):
		val_lbl.text = "%d%%" % int(val * 100)
		var bus := FmodServer.get_bus(bus_path)
		if bus and bus.is_valid():
			bus.set_volume(val)
	)

	btn_mute.pressed.connect(func():
		var bus := FmodServer.get_bus(bus_path)
		if bus and bus.is_valid():
			var is_muted := bus.get_mute()
			bus.set_mute(not is_muted)
			btn_mute.text = "🔇 Unmute" if not is_muted else "🔊 Mute"
	)

	btn_pause_bus.pressed.connect(func():
		var bus := FmodServer.get_bus(bus_path)
		if bus and bus.is_valid():
			var is_paused := bus.get_paused()
			bus.set_paused(not is_paused)
			btn_pause_bus.text = "▶ Resume" if not is_paused else "⏸ Pause"
	)

	btn_stop_bus.pressed.connect(func():
		var bus := FmodServer.get_bus(bus_path)
		if bus and bus.is_valid():
			bus.stop_all_events(FmodServer.STOP_ALLOWFADEOUT)
	)

	bus_container.add_child(card)

func _on_add_custom_bus() -> void:
	var path := custom_bus_input.text.strip_edges()
	if not path.is_empty():
		if not path.begins_with("bus:/"):
			path = "bus:/" + path
		if not _user_buses.has(path):
			_user_buses.append(path)
			_save_persistent_settings()
			_create_bus_strip(path)
		custom_bus_input.text = ""

func _build_vca_strips() -> void:
	for child in vca_container.get_children():
		child.queue_free()

	for vca_path in _user_vcas:
		_create_vca_strip(vca_path)

func _create_vca_strip(vca_path: String) -> void:
	var card := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	var name_lbl := Label.new()
	name_lbl.text = vca_path
	name_lbl.custom_minimum_size = Vector2(140, 0)
	hbox.add_child(name_lbl)

	var slider := HSlider.new()
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(slider)

	var val_lbl := Label.new()
	val_lbl.text = "100%"
	val_lbl.custom_minimum_size = Vector2(45, 0)
	hbox.add_child(val_lbl)

	slider.value_changed.connect(func(val: float):
		val_lbl.text = "%d%%" % int(val * 100)
		var vca := FmodServer.get_vca(vca_path)
		if vca and vca.is_valid():
			vca.set_volume(val)
	)

	vca_container.add_child(card)

func _on_add_custom_vca() -> void:
	var path := custom_vca_input.text.strip_edges()
	if not path.is_empty():
		if not path.begins_with("vca:/"):
			path = "vca:/" + path
		if not _user_vcas.has(path):
			_user_vcas.append(path)
			_save_persistent_settings()
			_create_vca_strip(path)
		custom_vca_input.text = ""

# --- Global Parameters ---

func _build_global_param_strips() -> void:
	for child in global_param_container.get_children():
		child.queue_free()

	for pname in _user_globals:
		_create_global_param_strip(pname, 0.0, 1.0, 0.01, 0.0)

func _create_global_param_strip(pname: String, pmin: float, pmax: float, pstep: float, pdef: float) -> void:
	var card := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	var name_lbl := Label.new()
	name_lbl.text = pname + ":"
	name_lbl.custom_minimum_size = Vector2(140, 0)
	hbox.add_child(name_lbl)

	var slider := HSlider.new()
	slider.min_value = pmin
	slider.max_value = pmax
	slider.step = pstep
	slider.value = pdef
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(slider)

	var val_lbl := Label.new()
	val_lbl.text = "%.2f" % pdef
	val_lbl.custom_minimum_size = Vector2(50, 0)
	hbox.add_child(val_lbl)

	slider.value_changed.connect(func(val: float):
		val_lbl.text = "%.2f" % val
		if ClassDB.class_exists("FmodServer"):
			FmodServer.set_global_parameter_by_name(pname, val)
	)

	global_param_container.add_child(card)

func _on_add_custom_global_param() -> void:
	var pname := custom_param_input.text.strip_edges()
	if not pname.is_empty():
		if not _user_globals.has(pname):
			_user_globals.append(pname)
			_save_persistent_settings()
			_create_global_param_strip(pname, 0.0, 1.0, 0.01, 0.0)
		custom_param_input.text = ""

# --- Banks Lifecycle ---

func _build_bank_lifecycle_cards() -> void:
	for child in bank_cards_container.get_children():
		child.queue_free()

	for bpath in _discovered_bank_paths:
		_create_bank_card(bpath)

func _create_bank_card(bpath: String) -> void:
	var card := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	var title := Label.new()
	title.text = "📦 " + bpath.get_file()
	title.custom_minimum_size = Vector2(160, 0)
	hbox.add_child(title)

	var state_lbl := Label.new()
	var is_loaded := _loaded_banks.has(bpath)
	state_lbl.text = "● LOADED" if is_loaded else "○ UNLOADED"
	state_lbl.modulate = Color(0.3, 0.9, 0.4) if is_loaded else Color(0.6, 0.65, 0.75)
	state_lbl.custom_minimum_size = Vector2(90, 0)
	hbox.add_child(state_lbl)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var btn_load := Button.new()
	btn_load.text = "📥 Load"
	hbox.add_child(btn_load)

	var btn_unload := Button.new()
	btn_unload.text = "📤 Unload"
	hbox.add_child(btn_unload)

	var btn_load_samples := Button.new()
	btn_load_samples.text = "⚡ Samples"
	hbox.add_child(btn_load_samples)

	btn_load.pressed.connect(func():
		var bank := FmodServer.load_bank(bpath)
		if bank and bank.is_valid():
			_loaded_banks[bpath] = bank
			state_lbl.text = "● LOADED"
			state_lbl.modulate = Color(0.3, 0.9, 0.4)
			_scan_and_load_project_banks()
	)

	btn_unload.pressed.connect(func():
		if _loaded_banks.has(bpath):
			var bank: FmodBank = _loaded_banks[bpath]
			if bank and bank.is_valid():
				bank.unload()
			_loaded_banks.erase(bpath)
			state_lbl.text = "○ UNLOADED"
			state_lbl.modulate = Color(0.6, 0.65, 0.75)
			_scan_and_load_project_banks()
	)

	btn_load_samples.pressed.connect(func():
		if _loaded_banks.has(bpath):
			var bank: FmodBank = _loaded_banks[bpath]
			if bank and bank.is_valid():
				bank.load_sample_data()
				state_lbl.text = "● SAMPLES READY"
				state_lbl.modulate = Color(0.3, 0.8, 1.0)
	)

	bank_cards_container.add_child(card)

# --- Audition Transport ---

func _on_play_pressed() -> void:
	if _selected_event_path.is_empty():
		return

	if _active_instance and _active_instance.is_valid():
		_active_instance.stop(FmodServer.STOP_IMMEDIATE)
		_active_instance.release()
		_active_instance = null

	_active_instance = FmodServer.create_event_instance(_selected_event_path)
	if _active_instance and _active_instance.is_valid():
		_active_instance.set_pitch(pitch_slider.value)
		_active_instance.set_volume(vol_slider.value)

		for pname in _param_sliders:
			var s: HSlider = _param_sliders[pname]
			_active_instance.set_parameter_by_name(pname, s.value)

		_active_instance.start()
		status_badge.text = "▶ PLAYING: " + _selected_event_path.get_file()
		status_badge.modulate = Color(0.3, 0.9, 0.4)

func _on_pause_pressed() -> void:
	if _active_instance and _active_instance.is_valid():
		var is_paused := _active_instance.get_paused()
		_active_instance.set_paused(not is_paused)

func _on_stop_pressed() -> void:
	if _active_instance and _active_instance.is_valid():
		_active_instance.stop(FmodServer.STOP_ALLOWFADEOUT)

func _on_timeline_seek(val: float) -> void:
	if _active_instance and _active_instance.is_valid() and timeline_slider.has_focus():
		_active_instance.set_timeline_position(int(val))

func _on_pitch_changed(val: float) -> void:
	pitch_value.text = "%.2fx" % val
	if _active_instance and _active_instance.is_valid():
		_active_instance.set_pitch(val)

func _on_vol_changed(val: float) -> void:
	vol_value.text = "%d%%" % int(val * 100)
	if _active_instance and _active_instance.is_valid():
		_active_instance.set_volume(val)

func _on_reload_banks_pressed() -> void:
	if _active_instance and _active_instance.is_valid():
		_active_instance.stop(FmodServer.STOP_IMMEDIATE)
		_active_instance.release()
		_active_instance = null

	FmodServer.unload_all_banks()
	_loaded_banks.clear()
	_scan_and_load_project_banks()
	_populate_event_tree(search_input.text)
	_build_bus_strips()
	_build_vca_strips()
	_build_bank_lifecycle_cards()

	if not _user_events.is_empty() and _selected_event_path.is_empty():
		_select_event(_user_events[0])

	status_badge.text = "● BANKS RELOADED"
	status_badge.modulate = Color(0.3, 0.9, 0.5)

func _on_panic_stop_pressed() -> void:
	if _active_instance and _active_instance.is_valid():
		_active_instance.stop(FmodServer.STOP_IMMEDIATE)
		_active_instance.release()
		_active_instance = null

	var bus := FmodServer.get_bus("bus:/")
	if bus and bus.is_valid():
		bus.stop_all_events(FmodServer.STOP_IMMEDIATE)

	status_badge.text = "● ALL AUDIO STOPPED"
	status_badge.modulate = Color(1.0, 0.3, 0.3)

func _format_time(ms: int) -> String:
	var total_sec := int(ms / 1000)
	var mins := int(total_sec / 60)
	var secs := total_sec % 60
	return "%02d:%02d" % [mins, secs]

func _exit_tree() -> void:
	if _active_instance and _active_instance.is_valid():
		_active_instance.stop(FmodServer.STOP_IMMEDIATE)
		_active_instance.release()
		_active_instance = null
