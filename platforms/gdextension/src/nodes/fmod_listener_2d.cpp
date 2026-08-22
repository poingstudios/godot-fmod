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

#include "fmod_listener_2d.h"
#include "../fmod_server.h"

namespace godot {

void FmodListener2D::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_listener_index", "index"), &FmodListener2D::set_listener_index);
	ClassDB::bind_method(D_METHOD("get_listener_index"), &FmodListener2D::get_listener_index);

	ClassDB::bind_method(D_METHOD("set_active", "active"), &FmodListener2D::set_active);
	ClassDB::bind_method(D_METHOD("get_active"), &FmodListener2D::get_active);

	ADD_PROPERTY(PropertyInfo(Variant::INT, "listener_index"), "set_listener_index", "get_listener_index");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_active"), "set_active", "get_active");
}

FmodListener2D::FmodListener2D() {
}

FmodListener2D::~FmodListener2D() {
}

void FmodListener2D::_notification(int p_what) {
	switch (p_what) {
		case NOTIFICATION_READY: {
			last_position = get_global_position();
			set_process(true);
		} break;

		case NOTIFICATION_PROCESS: {
			if (!is_active) {
				return;
			}

			Vector2 current_pos = get_global_position();
			float delta = get_process_delta_time();
			Vector2 velocity = delta > 0.0f ? (current_pos - last_position) / delta : Vector2();
			last_position = current_pos;

			FmodServer::set_listener_attributes_2d(listener_index, get_global_transform(), velocity);
		} break;
	}
}

void FmodListener2D::set_listener_index(int p_index) {
	listener_index = p_index;
}

int FmodListener2D::get_listener_index() const {
	return listener_index;
}

void FmodListener2D::set_active(bool p_active) {
	is_active = p_active;
}

bool FmodListener2D::get_active() const {
	return is_active;
}

} // namespace godot
