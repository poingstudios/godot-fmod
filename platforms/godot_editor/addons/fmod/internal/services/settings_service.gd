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
extends RefCounted

const SETTINGS := [
	{
		"name": "fmod/general/auto_initialize",
		"type": TYPE_BOOL,
		"default": true,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true
	},
	{
		"name": "fmod/banks/banks_path",
		"type": TYPE_STRING,
		"default": "res://",
		"hint": PROPERTY_HINT_DIR,
		"hint_string": "",
		"basic": true
	},
	{
		"name": "fmod/banks/auto_load_banks",
		"type": TYPE_BOOL,
		"default": true,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true
	},
	{
		"name": "fmod/banks/preload_sample_data",
		"type": TYPE_BOOL,
		"default": false,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true
	},
	{
		"name": "fmod/audio/real_channels",
		"type": TYPE_INT,
		"default": 64,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1,1024,1",
		"basic": true
	},
	{
		"name": "fmod/audio/sample_rate",
		"type": TYPE_INT,
		"default": 48000,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Default:0,24000:24000,44100:44100,48000:48000",
		"basic": true
	},
	{
		"name": "fmod/live_update/enable_in_editor",
		"type": TYPE_BOOL,
		"default": true,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": false
	},
	{
		"name": "fmod/live_update/enable_in_debug",
		"type": TYPE_BOOL,
		"default": true,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": false
	},
	{
		"name": "fmod/live_update/live_update_port",
		"type": TYPE_INT,
		"default": 9264,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1024,65535,1",
		"basic": false
	}
]

static func register_settings() -> void:
	var needs_save := false

	for setting in SETTINGS:
		var name: String = setting["name"]
		var default_val: Variant = setting["default"]
		var type: int = setting["type"]
		var hint: int = setting["hint"]
		var hint_string: String = setting["hint_string"]
		var is_basic: bool = setting["basic"]

		if not ProjectSettings.has_setting(name):
			ProjectSettings.set_setting(name, default_val)
			needs_save = true

		ProjectSettings.set_initial_value(name, default_val)

		var property_info := {
			"name": name,
			"type": type,
			"hint": hint,
			"hint_string": hint_string
		}

		ProjectSettings.add_property_info(property_info)
		ProjectSettings.set_as_basic(name, is_basic)

	if needs_save:
		ProjectSettings.save()

static func get_setting(name: String, default_value: Variant = null) -> Variant:
	if ProjectSettings.has_setting(name):
		return ProjectSettings.get_setting(name)
	return default_value

static func set_setting(name: String, value: Variant) -> void:
	ProjectSettings.set_setting(name, value)
	ProjectSettings.save()
