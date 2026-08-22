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
extends EditorPlugin

const CSharpService := preload("res://addons/fmod/internal/services/csharp_service.gd")
const SettingsService := preload("res://addons/fmod/internal/services/settings_service.gd")
const FmodMainScreenScene := preload("res://addons/fmod/internal/ui/fmod_main_screen.tscn")

var _main_screen_instance: Control = null

func _enter_tree() -> void:
	CSharpService.manage_visibility(self)
	SettingsService.register_settings()

	# Register FMOD Main Screen Workspace (Top Bar: 2D | 3D | Script | AssetLib | FMOD)
	if not _main_screen_instance:
		_main_screen_instance = FmodMainScreenScene.instantiate() as Control
		_main_screen_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_main_screen_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_main_screen_instance.visible = false
		get_editor_interface().get_editor_main_screen().add_child(_main_screen_instance)

	var filesystem := get_editor_interface().get_resource_filesystem()
	if filesystem and not filesystem.filesystem_changed.is_connected(_on_filesystem_changed):
		filesystem.filesystem_changed.connect(_on_filesystem_changed)

func _exit_tree() -> void:
	if _main_screen_instance:
		_main_screen_instance.queue_free()
		_main_screen_instance = null

	var filesystem := get_editor_interface().get_resource_filesystem()
	if filesystem and filesystem.filesystem_changed.is_connected(_on_filesystem_changed):
		filesystem.filesystem_changed.disconnect(_on_filesystem_changed)

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if _main_screen_instance:
		_main_screen_instance.visible = visible

func _get_plugin_name() -> String:
	return "FMOD"

func _get_plugin_icon() -> Texture2D:
	return get_editor_interface().get_base_control().get_theme_icon("AudioStreamPlayer", "EditorIcons")

func _on_filesystem_changed() -> void:
	CSharpService.manage_visibility(self)
