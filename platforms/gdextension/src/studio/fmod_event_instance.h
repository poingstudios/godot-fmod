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

#ifndef FMOD_EVENT_INSTANCE_H
#define FMOD_EVENT_INSTANCE_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/transform2d.hpp>
#include <godot_cpp/variant/transform3d.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/variant/vector3.hpp>

#include <fmod_studio.hpp>

namespace godot {

class FmodEventInstance : public RefCounted {
	GDCLASS(FmodEventInstance, RefCounted);

private:
	FMOD::Studio::EventInstance *event_instance = nullptr;

protected:
	static void _bind_methods();

public:
	FmodEventInstance();
	~FmodEventInstance();

	void set_instance_handle(FMOD::Studio::EventInstance *p_instance);
	FMOD::Studio::EventInstance *get_instance_handle() const;

	bool is_valid() const;
	void start();
	void stop(int p_stop_mode = 0);
	int get_playback_state() const;
	void set_paused(bool p_paused);
	bool get_paused() const;
	void set_pitch(float p_pitch);
	float get_pitch() const;
	void set_volume(float p_volume);
	float get_volume() const;
	void set_timeline_position(int p_position);
	int get_timeline_position() const;
	void set_parameter_by_name(const String &p_name, float p_value, bool p_ignore_seek_speed = false);
	float get_parameter_by_name(const String &p_name) const;
	void set_3d_attributes(const Transform3D &p_transform, const Vector3 &p_velocity = Vector3());
	void set_3d_attributes_2d(const Transform2D &p_transform, const Vector2 &p_velocity = Vector2());
	void release();
};

} // namespace godot

#endif // FMOD_EVENT_INSTANCE_H
