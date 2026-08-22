// MIT License
//
// Copyright (c) 2026 Poing Studios
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "fmod_event_emitter_2d.h"
#include "../fmod_server.h"

namespace godot {

void FmodEventEmitter2D::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_event_name", "name"), &FmodEventEmitter2D::set_event_name);
	ClassDB::bind_method(D_METHOD("get_event_name"), &FmodEventEmitter2D::get_event_name);

	ClassDB::bind_method(D_METHOD("set_auto_play", "auto_play"), &FmodEventEmitter2D::set_auto_play);
	ClassDB::bind_method(D_METHOD("get_auto_play"), &FmodEventEmitter2D::get_auto_play);

	ClassDB::bind_method(D_METHOD("set_auto_release", "auto_release"), &FmodEventEmitter2D::set_auto_release);
	ClassDB::bind_method(D_METHOD("get_auto_release"), &FmodEventEmitter2D::get_auto_release);

	ClassDB::bind_method(D_METHOD("set_volume", "volume"), &FmodEventEmitter2D::set_volume);
	ClassDB::bind_method(D_METHOD("get_volume"), &FmodEventEmitter2D::get_volume);

	ClassDB::bind_method(D_METHOD("set_pitch", "pitch"), &FmodEventEmitter2D::set_pitch);
	ClassDB::bind_method(D_METHOD("get_pitch"), &FmodEventEmitter2D::get_pitch);

	ClassDB::bind_method(D_METHOD("set_parameters", "parameters"), &FmodEventEmitter2D::set_parameters);
	ClassDB::bind_method(D_METHOD("get_parameters"), &FmodEventEmitter2D::get_parameters);

	ClassDB::bind_method(D_METHOD("play"), &FmodEventEmitter2D::play);
	ClassDB::bind_method(D_METHOD("stop", "stop_mode"), &FmodEventEmitter2D::stop, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("is_playing"), &FmodEventEmitter2D::is_playing);

	ClassDB::bind_method(D_METHOD("set_parameter", "name", "value"), &FmodEventEmitter2D::set_parameter);
	ClassDB::bind_method(D_METHOD("get_parameter", "name"), &FmodEventEmitter2D::get_parameter);

	ClassDB::bind_method(D_METHOD("get_event_instance"), &FmodEventEmitter2D::get_event_instance);

	ADD_PROPERTY(PropertyInfo(Variant::STRING, "event_name"), "set_event_name", "get_event_name");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "auto_play"), "set_auto_play", "get_auto_play");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "auto_release"), "set_auto_release", "get_auto_release");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "volume", PROPERTY_HINT_RANGE, "0.0, 1.0, 0.01"), "set_volume", "get_volume");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "pitch", PROPERTY_HINT_RANGE, "0.0, 4.0, 0.01"), "set_pitch", "get_pitch");
	ADD_PROPERTY(PropertyInfo(Variant::DICTIONARY, "parameters"), "set_parameters", "get_parameters");
}

FmodEventEmitter2D::FmodEventEmitter2D() {
}

FmodEventEmitter2D::~FmodEventEmitter2D() {
	stop(1);
}

void FmodEventEmitter2D::_notification(int p_what) {
	switch (p_what) {
		case NOTIFICATION_READY: {
			last_position = get_global_position();
			set_process(true);
			if (auto_play && !event_name.is_empty()) {
				play();
			}
		} break;

		case NOTIFICATION_PROCESS: {
			if (event_instance.is_valid() && is_playing()) {
				Vector2 current_pos = get_global_position();
				float delta = get_process_delta_time();
				Vector2 velocity = delta > 0.0f ? (current_pos - last_position) / delta : Vector2();
				last_position = current_pos;

				event_instance->set_3d_attributes_2d(get_global_transform(), velocity);
			}
		} break;

		case NOTIFICATION_EXIT_TREE: {
			stop(1);
		} break;
	}
}

void FmodEventEmitter2D::set_event_name(const String &p_name) {
	event_name = p_name;
}

String FmodEventEmitter2D::get_event_name() const {
	return event_name;
}

void FmodEventEmitter2D::set_auto_play(bool p_auto_play) {
	auto_play = p_auto_play;
}

bool FmodEventEmitter2D::get_auto_play() const {
	return auto_play;
}

void FmodEventEmitter2D::set_auto_release(bool p_auto_release) {
	auto_release = p_auto_release;
}

bool FmodEventEmitter2D::get_auto_release() const {
	return auto_release;
}

void FmodEventEmitter2D::set_volume(float p_volume) {
	volume = p_volume;
	if (event_instance.is_valid()) {
		event_instance->set_volume(volume);
	}
}

float FmodEventEmitter2D::get_volume() const {
	return volume;
}

void FmodEventEmitter2D::set_pitch(float p_pitch) {
	pitch = p_pitch;
	if (event_instance.is_valid()) {
		event_instance->set_pitch(pitch);
	}
}

float FmodEventEmitter2D::get_pitch() const {
	return pitch;
}

void FmodEventEmitter2D::set_parameters(const Dictionary &p_params) {
	parameters = p_params;
	if (event_instance.is_valid()) {
		Array keys = parameters.keys();
		for (int i = 0; i < keys.size(); i++) {
			String key = keys[i];
			float val = parameters[key];
			event_instance->set_parameter_by_name(key, val);
		}
	}
}

Dictionary FmodEventEmitter2D::get_parameters() const {
	return parameters;
}

void FmodEventEmitter2D::play() {
	if (event_name.is_empty()) {
		return;
	}

	if (!event_instance.is_valid()) {
		event_instance = FmodServer::create_event_instance(event_name);
	}

	if (event_instance.is_valid()) {
		event_instance->set_volume(volume);
		event_instance->set_pitch(pitch);
		event_instance->set_3d_attributes_2d(get_global_transform());

		Array keys = parameters.keys();
		for (int i = 0; i < keys.size(); i++) {
			String key = keys[i];
			float val = parameters[key];
			event_instance->set_parameter_by_name(key, val);
		}

		event_instance->start();
	}
}

void FmodEventEmitter2D::stop(int p_stop_mode) {
	if (event_instance.is_valid()) {
		event_instance->stop(p_stop_mode);
		if (auto_release) {
			event_instance->release();
			event_instance = nullptr;
		}
	}
}

bool FmodEventEmitter2D::is_playing() const {
	if (!event_instance.is_valid()) {
		return false;
	}
	int state = event_instance->get_playback_state();
	return state == FmodServer::PLAYBACK_PLAYING || state == FmodServer::PLAYBACK_STARTING || state == FmodServer::PLAYBACK_SUSTAINING;
}

void FmodEventEmitter2D::set_parameter(const String &p_name, float p_value) {
	parameters[p_name] = p_value;
	if (event_instance.is_valid()) {
		event_instance->set_parameter_by_name(p_name, p_value);
	}
}

float FmodEventEmitter2D::get_parameter(const String &p_name) const {
	if (event_instance.is_valid()) {
		return event_instance->get_parameter_by_name(p_name);
	}
	if (parameters.has(p_name)) {
		return parameters[p_name];
	}
	return 0.0f;
}

Ref<FmodEventInstance> FmodEventEmitter2D::get_event_instance() const {
	return event_instance;
}

} // namespace godot
