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

#ifndef FMOD_EVENT_EMITTER_3D_H
#define FMOD_EVENT_EMITTER_3D_H

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/ref.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/string.hpp>

#include "../studio/fmod_event_instance.h"

namespace godot {

class FmodEventEmitter3D : public Node3D {
	GDCLASS(FmodEventEmitter3D, Node3D);

private:
	String event_name;
	bool auto_play = false;
	bool auto_release = false;
	float volume = 1.0f;
	float pitch = 1.0f;
	Dictionary parameters;

	Ref<FmodEventInstance> event_instance;
	Vector3 last_position;

protected:
	static void _bind_methods();
	void _notification(int p_what);

public:
	FmodEventEmitter3D();
	~FmodEventEmitter3D();

	void set_event_name(const String &p_name);
	String get_event_name() const;

	void set_auto_play(bool p_auto_play);
	bool get_auto_play() const;

	void set_auto_release(bool p_auto_release);
	bool get_auto_release() const;

	void set_volume(float p_volume);
	float get_volume() const;

	void set_pitch(float p_pitch);
	float get_pitch() const;

	void set_parameters(const Dictionary &p_params);
	Dictionary get_parameters() const;

	void play();
	void stop(int p_stop_mode = 0);
	bool is_playing() const;

	void set_parameter(const String &p_name, float p_value);
	float get_parameter(const String &p_name) const;

	Ref<FmodEventInstance> get_event_instance() const;
};

} // namespace godot

#endif // FMOD_EVENT_EMITTER_3D_H
