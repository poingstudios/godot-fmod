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

#include "fmod_event_description.h"
#include "fmod_event_instance.h"
#include "../utils/fmod_macros.h"

namespace godot {

void FmodEventDescription::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_valid"), &FmodEventDescription::is_valid);
	ClassDB::bind_method(D_METHOD("create_instance"), &FmodEventDescription::create_instance);
	ClassDB::bind_method(D_METHOD("get_length"), &FmodEventDescription::get_length);
	ClassDB::bind_method(D_METHOD("is_3d"), &FmodEventDescription::is_3d);
	ClassDB::bind_method(D_METHOD("is_oneshot"), &FmodEventDescription::is_oneshot);
	ClassDB::bind_method(D_METHOD("is_snapshot"), &FmodEventDescription::is_snapshot);
	ClassDB::bind_method(D_METHOD("get_path"), &FmodEventDescription::get_path);
}

FmodEventDescription::FmodEventDescription() {
}

FmodEventDescription::~FmodEventDescription() {
}

void FmodEventDescription::set_event_desc_handle(FMOD::Studio::EventDescription *p_desc) {
	event_desc = p_desc;
}

FMOD::Studio::EventDescription *FmodEventDescription::get_event_desc_handle() const {
	return event_desc;
}

bool FmodEventDescription::is_valid() const {
	return event_desc != nullptr && event_desc->isValid();
}

Ref<FmodEventInstance> FmodEventDescription::create_instance() {
	if (!is_valid()) {
		return nullptr;
	}

	FMOD::Studio::EventInstance *inst = nullptr;
	FMOD_RESULT res = event_desc->createInstance(&inst);
	FMOD_CHECK_ERR(res, "FmodEventDescription::create_instance failed");

	if (inst != nullptr) {
		Ref<FmodEventInstance> instance;
		instance.instantiate();
		instance->set_instance_handle(inst);
		return instance;
	}

	return nullptr;
}

int FmodEventDescription::get_length() const {
	if (!is_valid()) {
		return 0;
	}
	int len = 0;
	FMOD_RESULT res = event_desc->getLength(&len);
	FMOD_CHECK_ERR(res, "FmodEventDescription::get_length failed");
	return len;
}

bool FmodEventDescription::is_3d() const {
	if (!is_valid()) {
		return false;
	}
	bool is_3d_val = false;
	FMOD_RESULT res = event_desc->is3D(&is_3d_val);
	FMOD_CHECK_ERR(res, "FmodEventDescription::is_3d failed");
	return is_3d_val;
}

bool FmodEventDescription::is_oneshot() const {
	if (!is_valid()) {
		return false;
	}
	bool oneshot = false;
	FMOD_RESULT res = event_desc->isOneshot(&oneshot);
	FMOD_CHECK_ERR(res, "FmodEventDescription::is_oneshot failed");
	return oneshot;
}

bool FmodEventDescription::is_snapshot() const {
	if (!is_valid()) {
		return false;
	}
	bool snapshot = false;
	FMOD_RESULT res = event_desc->isSnapshot(&snapshot);
	FMOD_CHECK_ERR(res, "FmodEventDescription::is_snapshot failed");
	return snapshot;
}

String FmodEventDescription::get_path() const {
	if (!is_valid()) {
		return String();
	}
	char path_buf[512];
	int retrieved = 0;
	FMOD_RESULT res = event_desc->getPath(path_buf, sizeof(path_buf), &retrieved);
	FMOD_CHECK_ERR(res, "FmodEventDescription::get_path failed");
	return String(path_buf);
}

} // namespace godot
