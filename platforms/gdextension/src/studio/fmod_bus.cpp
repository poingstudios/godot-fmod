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

#include "fmod_bus.h"
#include "../utils/fmod_macros.h"

namespace godot {

void FmodBus::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_valid"), &FmodBus::is_valid);
	ClassDB::bind_method(D_METHOD("set_volume", "volume"), &FmodBus::set_volume);
	ClassDB::bind_method(D_METHOD("get_volume"), &FmodBus::get_volume);
	ClassDB::bind_method(D_METHOD("set_mute", "mute"), &FmodBus::set_mute);
	ClassDB::bind_method(D_METHOD("get_mute"), &FmodBus::get_mute);
	ClassDB::bind_method(D_METHOD("set_paused", "paused"), &FmodBus::set_paused);
	ClassDB::bind_method(D_METHOD("get_paused"), &FmodBus::get_paused);
	ClassDB::bind_method(D_METHOD("stop_all_events", "stop_mode"), &FmodBus::stop_all_events, DEFVAL(0));
}

FmodBus::FmodBus() {
}

FmodBus::~FmodBus() {
}

void FmodBus::set_bus_handle(FMOD::Studio::Bus *p_bus) {
	bus = p_bus;
}

FMOD::Studio::Bus *FmodBus::get_bus_handle() const {
	return bus;
}

bool FmodBus::is_valid() const {
	return bus != nullptr && bus->isValid();
}

void FmodBus::set_volume(float p_volume) {
	if (is_valid()) {
		FMOD_RESULT res = bus->setVolume(p_volume);
		FMOD_CHECK_ERR(res, "FmodBus::set_volume failed");
	}
}

float FmodBus::get_volume() const {
	if (!is_valid()) {
		return 1.0f;
	}
	float vol = 1.0f;
	FMOD_RESULT res = bus->getVolume(&vol);
	FMOD_CHECK_ERR(res, "FmodBus::get_volume failed");
	return vol;
}

void FmodBus::set_mute(bool p_mute) {
	if (is_valid()) {
		FMOD_RESULT res = bus->setMute(p_mute);
		FMOD_CHECK_ERR(res, "FmodBus::set_mute failed");
	}
}

bool FmodBus::get_mute() const {
	if (!is_valid()) {
		return false;
	}
	bool mute = false;
	FMOD_RESULT res = bus->getMute(&mute);
	FMOD_CHECK_ERR(res, "FmodBus::get_mute failed");
	return mute;
}

void FmodBus::set_paused(bool p_paused) {
	if (is_valid()) {
		FMOD_RESULT res = bus->setPaused(p_paused);
		FMOD_CHECK_ERR(res, "FmodBus::set_paused failed");
	}
}

bool FmodBus::get_paused() const {
	if (!is_valid()) {
		return false;
	}
	bool paused = false;
	FMOD_RESULT res = bus->getPaused(&paused);
	FMOD_CHECK_ERR(res, "FmodBus::get_paused failed");
	return paused;
}

void FmodBus::stop_all_events(int p_stop_mode) {
	if (is_valid()) {
		FMOD_STUDIO_STOP_MODE mode = static_cast<FMOD_STUDIO_STOP_MODE>(p_stop_mode);
		FMOD_RESULT res = bus->stopAllEvents(mode);
		FMOD_CHECK_ERR(res, "FmodBus::stop_all_events failed");
	}
}

} // namespace godot
