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

#ifndef FMOD_EVENT_DESCRIPTION_H
#define FMOD_EVENT_DESCRIPTION_H

#include <godot_cpp/classes/ref.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string.hpp>

#include <fmod_studio.hpp>

namespace godot {

class FmodEventInstance;

class FmodEventDescription : public RefCounted {
	GDCLASS(FmodEventDescription, RefCounted);

private:
	FMOD::Studio::EventDescription *event_desc = nullptr;

protected:
	static void _bind_methods();

public:
	FmodEventDescription();
	~FmodEventDescription();

	void set_event_desc_handle(FMOD::Studio::EventDescription *p_desc);
	FMOD::Studio::EventDescription *get_event_desc_handle() const;

	bool is_valid() const;
	Ref<FmodEventInstance> create_instance();
	int get_length() const;
	bool is_3d() const;
	bool is_oneshot() const;
	bool is_snapshot() const;
	String get_path() const;
};

} // namespace godot

#endif // FMOD_EVENT_DESCRIPTION_H
