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

#ifndef FMOD_BUS_H
#define FMOD_BUS_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>

#include <fmod_studio.hpp>

namespace godot {

class FmodBus : public RefCounted {
	GDCLASS(FmodBus, RefCounted);

private:
	FMOD::Studio::Bus *bus = nullptr;

protected:
	static void _bind_methods();

public:
	FmodBus();
	~FmodBus();

	void set_bus_handle(FMOD::Studio::Bus *p_bus);
	FMOD::Studio::Bus *get_bus_handle() const;

	bool is_valid() const;
	void set_volume(float p_volume);
	float get_volume() const;
	void set_mute(bool p_mute);
	bool get_mute() const;
	void set_paused(bool p_paused);
	bool get_paused() const;
	void stop_all_events(int p_stop_mode = 0);
};

} // namespace godot

#endif // FMOD_BUS_H
