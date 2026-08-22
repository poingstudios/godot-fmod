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

#ifndef FMOD_SERVER_H
#define FMOD_SERVER_H

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/classes/ref.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/templates/hash_map.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/transform2d.hpp>
#include <godot_cpp/variant/transform3d.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/variant/vector3.hpp>

#include <fmod_studio.hpp>

#include "studio/fmod_bank.h"
#include "studio/fmod_bus.h"
#include "studio/fmod_event_description.h"
#include "studio/fmod_event_instance.h"
#include "studio/fmod_vca.h"

namespace godot {

class FmodServer : public Object {
	GDCLASS(FmodServer, Object);

public:
	enum StopMode {
		STOP_ALLOWFADEOUT = 0,
		STOP_IMMEDIATE = 1,
	};

	enum LoadingState {
		LOADING_STATE_UNLOADED = 0,
		LOADING_STATE_LOADING = 1,
		LOADING_STATE_LOADED = 2,
		LOADING_STATE_ERROR = 3,
		LOADING_STATE_UNLOADING = 4,
	};

	enum PlaybackState {
		PLAYBACK_PLAYING = 0,
		PLAYBACK_SUSTAINING = 1,
		PLAYBACK_STOPPED = 2,
		PLAYBACK_STARTING = 3,
		PLAYBACK_STOPPING = 4,
	};

private:
	static FmodServer *singleton;

	FMOD::Studio::System *studio_system = nullptr;
	FMOD::System *core_system = nullptr;

	HashMap<String, Ref<FmodBank>> loaded_banks;

protected:
	static void _bind_methods();

public:
	static FmodServer *get_singleton();

	FmodServer();
	~FmodServer();

	static bool initialize(int p_max_channels = 1024, int p_studio_flags = 0, int p_core_flags = 0);
	static void update();
	static void shutdown();
	static bool is_initialized();

	static Ref<FmodBank> load_bank(const String &p_path, int p_flags = 0);
	static void unload_bank(const String &p_path);
	static void unload_all_banks();
	static bool is_bank_loaded(const String &p_path);

	static Ref<FmodEventDescription> get_event_description(const String &p_path);
	static Ref<FmodEventInstance> create_event_instance(const String &p_path);

	static void play_one_shot(const String &p_path);
	static void play_one_shot_3d(const String &p_path, const Vector3 &p_position);
	static void play_one_shot_2d(const String &p_path, const Vector2 &p_position);

	static Ref<FmodBus> get_bus(const String &p_path);
	static Ref<FmodVCA> get_vca(const String &p_path);

	static void set_global_parameter_by_name(const String &p_name, float p_value, bool p_ignore_seek_speed = false);
	static float get_global_parameter_by_name(const String &p_name);

	static void set_listener_attributes_3d(int p_listener_index, const Transform3D &p_transform, const Vector3 &p_velocity = Vector3());
	static void set_listener_attributes_2d(int p_listener_index, const Transform2D &p_transform, const Vector2 &p_velocity = Vector2());

	static void pause_all_events(bool p_paused);
	static void mute_all_events(bool p_mute);
};

} // namespace godot

VARIANT_ENUM_CAST(FmodServer::StopMode);
VARIANT_ENUM_CAST(FmodServer::LoadingState);
VARIANT_ENUM_CAST(FmodServer::PlaybackState);

#endif // FMOD_SERVER_H
