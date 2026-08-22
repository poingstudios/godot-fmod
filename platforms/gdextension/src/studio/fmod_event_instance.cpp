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

#include "fmod_event_instance.h"
#include "../utils/fmod_macros.h"
#include "../utils/fmod_types.h"

namespace godot {

void FmodEventInstance::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_valid"), &FmodEventInstance::is_valid);
	ClassDB::bind_method(D_METHOD("start"), &FmodEventInstance::start);
	ClassDB::bind_method(D_METHOD("stop", "stop_mode"), &FmodEventInstance::stop, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("get_playback_state"), &FmodEventInstance::get_playback_state);
	ClassDB::bind_method(D_METHOD("set_paused", "paused"), &FmodEventInstance::set_paused);
	ClassDB::bind_method(D_METHOD("get_paused"), &FmodEventInstance::get_paused);
	ClassDB::bind_method(D_METHOD("set_pitch", "pitch"), &FmodEventInstance::set_pitch);
	ClassDB::bind_method(D_METHOD("get_pitch"), &FmodEventInstance::get_pitch);
	ClassDB::bind_method(D_METHOD("set_volume", "volume"), &FmodEventInstance::set_volume);
	ClassDB::bind_method(D_METHOD("get_volume"), &FmodEventInstance::get_volume);
	ClassDB::bind_method(D_METHOD("set_timeline_position", "position"), &FmodEventInstance::set_timeline_position);
	ClassDB::bind_method(D_METHOD("get_timeline_position"), &FmodEventInstance::get_timeline_position);
	ClassDB::bind_method(D_METHOD("set_parameter_by_name", "name", "value", "ignore_seek_speed"), &FmodEventInstance::set_parameter_by_name, DEFVAL(false));
	ClassDB::bind_method(D_METHOD("get_parameter_by_name", "name"), &FmodEventInstance::get_parameter_by_name);
	ClassDB::bind_method(D_METHOD("set_3d_attributes", "transform", "velocity"), &FmodEventInstance::set_3d_attributes, DEFVAL(Vector3()));
	ClassDB::bind_method(D_METHOD("set_3d_attributes_2d", "transform", "velocity"), &FmodEventInstance::set_3d_attributes_2d, DEFVAL(Vector2()));
	ClassDB::bind_method(D_METHOD("release"), &FmodEventInstance::release);
}

FmodEventInstance::FmodEventInstance() {
}

FmodEventInstance::~FmodEventInstance() {
}

void FmodEventInstance::set_instance_handle(FMOD::Studio::EventInstance *p_instance) {
	event_instance = p_instance;
}

FMOD::Studio::EventInstance *FmodEventInstance::get_instance_handle() const {
	return event_instance;
}

bool FmodEventInstance::is_valid() const {
	return event_instance != nullptr && event_instance->isValid();
}

void FmodEventInstance::start() {
	if (is_valid()) {
		FMOD_RESULT res = event_instance->start();
		FMOD_CHECK_ERR(res, "FmodEventInstance::start failed");
	}
}

void FmodEventInstance::stop(int p_stop_mode) {
	if (is_valid()) {
		FMOD_STUDIO_STOP_MODE mode = static_cast<FMOD_STUDIO_STOP_MODE>(p_stop_mode);
		FMOD_RESULT res = event_instance->stop(mode);
		FMOD_CHECK_ERR(res, "FmodEventInstance::stop failed");
	}
}

int FmodEventInstance::get_playback_state() const {
	if (!is_valid()) {
		return FMOD_STUDIO_PLAYBACK_STOPPED;
	}
	FMOD_STUDIO_PLAYBACK_STATE state;
	FMOD_RESULT res = event_instance->getPlaybackState(&state);
	FMOD_CHECK_ERR(res, "FmodEventInstance::get_playback_state failed");
	return static_cast<int>(state);
}

void FmodEventInstance::set_paused(bool p_paused) {
	if (is_valid()) {
		FMOD_RESULT res = event_instance->setPaused(p_paused);
		FMOD_CHECK_ERR(res, "FmodEventInstance::set_paused failed");
	}
}

bool FmodEventInstance::get_paused() const {
	if (!is_valid()) {
		return false;
	}
	bool paused = false;
	FMOD_RESULT res = event_instance->getPaused(&paused);
	FMOD_CHECK_ERR(res, "FmodEventInstance::get_paused failed");
	return paused;
}

void FmodEventInstance::set_pitch(float p_pitch) {
	if (is_valid()) {
		FMOD_RESULT res = event_instance->setPitch(p_pitch);
		FMOD_CHECK_ERR(res, "FmodEventInstance::set_pitch failed");
	}
}

float FmodEventInstance::get_pitch() const {
	if (!is_valid()) {
		return 1.0f;
	}
	float pitch = 1.0f;
	FMOD_RESULT res = event_instance->getPitch(&pitch);
	FMOD_CHECK_ERR(res, "FmodEventInstance::get_pitch failed");
	return pitch;
}

void FmodEventInstance::set_volume(float p_volume) {
	if (is_valid()) {
		FMOD_RESULT res = event_instance->setVolume(p_volume);
		FMOD_CHECK_ERR(res, "FmodEventInstance::set_volume failed");
	}
}

float FmodEventInstance::get_volume() const {
	if (!is_valid()) {
		return 1.0f;
	}
	float vol = 1.0f;
	FMOD_RESULT res = event_instance->getVolume(&vol);
	FMOD_CHECK_ERR(res, "FmodEventInstance::get_volume failed");
	return vol;
}

void FmodEventInstance::set_timeline_position(int p_position) {
	if (is_valid()) {
		FMOD_RESULT res = event_instance->setTimelinePosition(p_position);
		FMOD_CHECK_ERR(res, "FmodEventInstance::set_timeline_position failed");
	}
}

int FmodEventInstance::get_timeline_position() const {
	if (!is_valid()) {
		return 0;
	}
	int pos = 0;
	FMOD_RESULT res = event_instance->getTimelinePosition(&pos);
	FMOD_CHECK_ERR(res, "FmodEventInstance::get_timeline_position failed");
	return pos;
}

void FmodEventInstance::set_parameter_by_name(const String &p_name, float p_value, bool p_ignore_seek_speed) {
	if (is_valid()) {
		FMOD_RESULT res = event_instance->setParameterByName(p_name.utf8().get_data(), p_value, p_ignore_seek_speed);
		FMOD_CHECK_ERR(res, "FmodEventInstance::set_parameter_by_name failed");
	}
}

float FmodEventInstance::get_parameter_by_name(const String &p_name) const {
	if (!is_valid()) {
		return 0.0f;
	}
	float val = 0.0f;
	FMOD_RESULT res = event_instance->getParameterByName(p_name.utf8().get_data(), &val);
	FMOD_CHECK_ERR(res, "FmodEventInstance::get_parameter_by_name failed");
	return val;
}

void FmodEventInstance::set_3d_attributes(const Transform3D &p_transform, const Vector3 &p_velocity) {
	if (is_valid()) {
		FMOD_3D_ATTRIBUTES attr = godot_transform3d_to_fmod(p_transform, p_velocity);
		FMOD_RESULT res = event_instance->set3DAttributes(&attr);
		FMOD_CHECK_ERR(res, "FmodEventInstance::set_3d_attributes failed");
	}
}

void FmodEventInstance::set_3d_attributes_2d(const Transform2D &p_transform, const Vector2 &p_velocity) {
	if (is_valid()) {
		FMOD_3D_ATTRIBUTES attr = godot_transform2d_to_fmod(p_transform, p_velocity);
		FMOD_RESULT res = event_instance->set3DAttributes(&attr);
		FMOD_CHECK_ERR(res, "FmodEventInstance::set_3d_attributes_2d failed");
	}
}

void FmodEventInstance::release() {
	if (is_valid()) {
		FMOD_RESULT res = event_instance->release();
		FMOD_CHECK_ERR(res, "FmodEventInstance::release failed");
		event_instance = nullptr;
	}
}

} // namespace godot
