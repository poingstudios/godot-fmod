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

#include "fmod_server.h"
#include "utils/fmod_macros.h"
#include "utils/fmod_types.h"

#include <godot_cpp/classes/project_settings.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

namespace godot {

FmodServer *FmodServer::singleton = nullptr;

FmodServer *FmodServer::get_singleton() {
	return singleton;
}

void FmodServer::_bind_methods() {
	ClassDB::bind_static_method(get_class_static(), D_METHOD("initialize", "max_channels", "studio_flags", "core_flags"), &FmodServer::initialize, DEFVAL(1024), DEFVAL(0), DEFVAL(0));
	ClassDB::bind_static_method(get_class_static(), D_METHOD("update"), &FmodServer::update);
	ClassDB::bind_static_method(get_class_static(), D_METHOD("shutdown"), &FmodServer::shutdown);
	ClassDB::bind_static_method(get_class_static(), D_METHOD("is_initialized"), &FmodServer::is_initialized);

	ClassDB::bind_static_method(get_class_static(), D_METHOD("load_bank", "path", "flags"), &FmodServer::load_bank, DEFVAL(0));
	ClassDB::bind_static_method(get_class_static(), D_METHOD("unload_bank", "path"), &FmodServer::unload_bank);
	ClassDB::bind_static_method(get_class_static(), D_METHOD("unload_all_banks"), &FmodServer::unload_all_banks);
	ClassDB::bind_static_method(get_class_static(), D_METHOD("is_bank_loaded", "path"), &FmodServer::is_bank_loaded);

	ClassDB::bind_static_method(get_class_static(), D_METHOD("get_event_description", "path"), &FmodServer::get_event_description);
	ClassDB::bind_static_method(get_class_static(), D_METHOD("create_event_instance", "path"), &FmodServer::create_event_instance);

	ClassDB::bind_static_method(get_class_static(), D_METHOD("play_one_shot", "path"), &FmodServer::play_one_shot);
	ClassDB::bind_static_method(get_class_static(), D_METHOD("play_one_shot_3d", "path", "position"), &FmodServer::play_one_shot_3d);
	ClassDB::bind_static_method(get_class_static(), D_METHOD("play_one_shot_2d", "path", "position"), &FmodServer::play_one_shot_2d);

	ClassDB::bind_static_method(get_class_static(), D_METHOD("get_bus", "path"), &FmodServer::get_bus);
	ClassDB::bind_static_method(get_class_static(), D_METHOD("get_vca", "path"), &FmodServer::get_vca);

	ClassDB::bind_static_method(get_class_static(), D_METHOD("set_global_parameter_by_name", "name", "value", "ignore_seek_speed"), &FmodServer::set_global_parameter_by_name, DEFVAL(false));
	ClassDB::bind_static_method(get_class_static(), D_METHOD("get_global_parameter_by_name", "name"), &FmodServer::get_global_parameter_by_name);

	ClassDB::bind_static_method(get_class_static(), D_METHOD("set_listener_attributes_3d", "listener_index", "transform", "velocity"), &FmodServer::set_listener_attributes_3d, DEFVAL(Vector3()));
	ClassDB::bind_static_method(get_class_static(), D_METHOD("set_listener_attributes_2d", "listener_index", "transform", "velocity"), &FmodServer::set_listener_attributes_2d, DEFVAL(Vector2()));

	ClassDB::bind_static_method(get_class_static(), D_METHOD("pause_all_events", "paused"), &FmodServer::pause_all_events);
	ClassDB::bind_static_method(get_class_static(), D_METHOD("mute_all_events", "mute"), &FmodServer::mute_all_events);

	BIND_ENUM_CONSTANT(STOP_ALLOWFADEOUT);
	BIND_ENUM_CONSTANT(STOP_IMMEDIATE);

	BIND_ENUM_CONSTANT(LOADING_STATE_UNLOADED);
	BIND_ENUM_CONSTANT(LOADING_STATE_LOADING);
	BIND_ENUM_CONSTANT(LOADING_STATE_LOADED);
	BIND_ENUM_CONSTANT(LOADING_STATE_ERROR);
	BIND_ENUM_CONSTANT(LOADING_STATE_UNLOADING);

	BIND_ENUM_CONSTANT(PLAYBACK_PLAYING);
	BIND_ENUM_CONSTANT(PLAYBACK_SUSTAINING);
	BIND_ENUM_CONSTANT(PLAYBACK_STOPPED);
	BIND_ENUM_CONSTANT(PLAYBACK_STARTING);
	BIND_ENUM_CONSTANT(PLAYBACK_STOPPING);
}

FmodServer::FmodServer() {
	singleton = this;
}

FmodServer::~FmodServer() {
	shutdown();
	if (singleton == this) {
		singleton = nullptr;
	}
}

bool FmodServer::initialize(int p_max_channels, int p_studio_flags, int p_core_flags) {
	if (singleton == nullptr) {
		return false;
	}
	if (singleton->studio_system != nullptr) {
		return true;
	}

	FMOD_RESULT res = FMOD::Studio::System::create(&singleton->studio_system, FMOD_VERSION);
	if (res == FMOD_ERR_HEADER_MISMATCH) {
		const unsigned int try_versions[] = {
			0x00020220, 0x00020217, 0x00020214, 0x00020210, 0x00020200,
			0x00020300, 0x00020301, 0x00020302, 0x00020310, 0x00020314,
			0x00020100, 0x00020000
		};
		for (unsigned int v : try_versions) {
			res = FMOD::Studio::System::create(&singleton->studio_system, v);
			if (res == FMOD_OK && singleton->studio_system != nullptr) {
				break;
			}
		}
	}

	FMOD_CHECK_ERR(res, "FMOD::Studio::System::create failed");
	if (res != FMOD_OK || singleton->studio_system == nullptr) {
		return false;
	}

	res = singleton->studio_system->getCoreSystem(&singleton->core_system);
	FMOD_CHECK_ERR(res, "getCoreSystem failed");

	res = singleton->studio_system->initialize(p_max_channels, p_studio_flags, p_core_flags, nullptr);
	FMOD_CHECK_ERR(res, "studio_system->initialize failed");

	return res == FMOD_OK;
}

void FmodServer::update() {
	if (singleton != nullptr && singleton->studio_system != nullptr) {
		singleton->studio_system->update();
	}
}

void FmodServer::shutdown() {
	if (singleton == nullptr) {
		return;
	}
	unload_all_banks();

	if (singleton->studio_system != nullptr) {
		singleton->studio_system->release();
		singleton->studio_system = nullptr;
		singleton->core_system = nullptr;
	}
}

bool FmodServer::is_initialized() {
	return singleton != nullptr && singleton->studio_system != nullptr;
}

Ref<FmodBank> FmodServer::load_bank(const String &p_path, int p_flags) {
	if (!is_initialized()) {
		initialize();
	}
	if (singleton == nullptr || singleton->studio_system == nullptr) {
		return nullptr;
	}

	if (singleton->loaded_banks.has(p_path)) {
		return singleton->loaded_banks[p_path];
	}

	String global_path = p_path;
	if (p_path.begins_with("res://") || p_path.begins_with("user://")) {
		global_path = ProjectSettings::get_singleton()->globalize_path(p_path);
	}

	FMOD::Studio::Bank *bank = nullptr;
	FMOD_RESULT res = singleton->studio_system->loadBankFile(global_path.utf8().get_data(), p_flags, &bank);
	FMOD_CHECK_ERR(res, String("Failed to load bank: ") + p_path);

	if (bank != nullptr) {
		Ref<FmodBank> bank_ref;
		bank_ref.instantiate();
		bank_ref->set_bank_handle(bank);
		singleton->loaded_banks[p_path] = bank_ref;
		return bank_ref;
	}

	return nullptr;
}

void FmodServer::unload_bank(const String &p_path) {
	if (singleton != nullptr && singleton->loaded_banks.has(p_path)) {
		Ref<FmodBank> bank_ref = singleton->loaded_banks[p_path];
		if (bank_ref.is_valid()) {
			bank_ref->unload();
		}
		singleton->loaded_banks.erase(p_path);
	}
}

void FmodServer::unload_all_banks() {
	if (singleton == nullptr) {
		return;
	}
	for (KeyValue<String, Ref<FmodBank>> &E : singleton->loaded_banks) {
		if (E.value.is_valid()) {
			E.value->unload();
		}
	}
	singleton->loaded_banks.clear();
}

bool FmodServer::is_bank_loaded(const String &p_path) {
	return singleton != nullptr && singleton->loaded_banks.has(p_path);
}

Ref<FmodEventDescription> FmodServer::get_event_description(const String &p_path) {
	if (!is_initialized()) {
		return nullptr;
	}

	FMOD::Studio::EventDescription *desc = nullptr;
	FMOD_RESULT res = singleton->studio_system->getEvent(p_path.utf8().get_data(), &desc);
	if (res != FMOD_OK && res != FMOD_ERR_EVENT_NOTFOUND) {
		FMOD_CHECK_ERR(res, String("Failed to get event description: ") + p_path);
	}

	if (desc != nullptr) {
		Ref<FmodEventDescription> desc_ref;
		desc_ref.instantiate();
		desc_ref->set_event_desc_handle(desc);
		return desc_ref;
	}

	return nullptr;
}

Ref<FmodEventInstance> FmodServer::create_event_instance(const String &p_path) {
	Ref<FmodEventDescription> desc = get_event_description(p_path);
	if (desc.is_valid()) {
		return desc->create_instance();
	}
	return nullptr;
}

void FmodServer::play_one_shot(const String &p_path) {
	Ref<FmodEventInstance> instance = create_event_instance(p_path);
	if (instance.is_valid()) {
		Ref<FmodEventDescription> desc = get_event_description(p_path);
		if (desc.is_valid() && desc->is_3d() && singleton != nullptr && singleton->studio_system != nullptr) {
			FMOD_3D_ATTRIBUTES listener_attr;
			if (singleton->studio_system->getListenerAttributes(0, &listener_attr) == FMOD_OK) {
				instance->get_instance_handle()->set3DAttributes(&listener_attr);
			}
		}
		instance->start();
		instance->release();
	}
}

void FmodServer::play_one_shot_3d(const String &p_path, const Vector3 &p_position) {
	Ref<FmodEventInstance> instance = create_event_instance(p_path);
	if (instance.is_valid()) {
		Transform3D transform;
		transform.origin = p_position;
		instance->set_3d_attributes(transform);
		instance->start();
		instance->release();
	}
}

void FmodServer::play_one_shot_2d(const String &p_path, const Vector2 &p_position) {
	Ref<FmodEventInstance> instance = create_event_instance(p_path);
	if (instance.is_valid()) {
		Transform2D transform;
		transform.set_origin(p_position);
		instance->set_3d_attributes_2d(transform);
		instance->start();
		instance->release();
	}
}

Ref<FmodBus> FmodServer::get_bus(const String &p_path) {
	if (!is_initialized()) {
		return nullptr;
	}

	FMOD::Studio::Bus *bus = nullptr;
	FMOD_RESULT res = singleton->studio_system->getBus(p_path.utf8().get_data(), &bus);
	FMOD_CHECK_ERR(res, String("Failed to get bus: ") + p_path);

	if (bus != nullptr) {
		Ref<FmodBus> bus_ref;
		bus_ref.instantiate();
		bus_ref->set_bus_handle(bus);
		return bus_ref;
	}

	return nullptr;
}

Ref<FmodVCA> FmodServer::get_vca(const String &p_path) {
	if (!is_initialized()) {
		return nullptr;
	}

	FMOD::Studio::VCA *vca = nullptr;
	FMOD_RESULT res = singleton->studio_system->getVCA(p_path.utf8().get_data(), &vca);
	FMOD_CHECK_ERR(res, String("Failed to get VCA: ") + p_path);

	if (vca != nullptr) {
		Ref<FmodVCA> vca_ref;
		vca_ref.instantiate();
		vca_ref->set_vca_handle(vca);
		return vca_ref;
	}

	return nullptr;
}

void FmodServer::set_global_parameter_by_name(const String &p_name, float p_value, bool p_ignore_seek_speed) {
	if (is_initialized()) {
		FMOD_RESULT res = singleton->studio_system->setParameterByName(p_name.utf8().get_data(), p_value, p_ignore_seek_speed);
		FMOD_CHECK_ERR(res, "Failed to set global parameter");
	}
}

float FmodServer::get_global_parameter_by_name(const String &p_name) {
	if (!is_initialized()) {
		return 0.0f;
	}
	float val = 0.0f;
	FMOD_RESULT res = singleton->studio_system->getParameterByName(p_name.utf8().get_data(), &val);
	FMOD_CHECK_ERR(res, "Failed to get global parameter");
	return val;
}

void FmodServer::set_listener_attributes_3d(int p_listener_index, const Transform3D &p_transform, const Vector3 &p_velocity) {
	if (is_initialized()) {
		FMOD_3D_ATTRIBUTES attr = godot_transform3d_to_fmod(p_transform, p_velocity);
		FMOD_RESULT res = singleton->studio_system->setListenerAttributes(p_listener_index, &attr);
		FMOD_CHECK_ERR(res, "setListenerAttributes 3D failed");
	}
}

void FmodServer::set_listener_attributes_2d(int p_listener_index, const Transform2D &p_transform, const Vector2 &p_velocity) {
	if (is_initialized()) {
		FMOD_3D_ATTRIBUTES attr = godot_transform2d_to_fmod(p_transform, p_velocity);
		FMOD_RESULT res = singleton->studio_system->setListenerAttributes(p_listener_index, &attr);
		FMOD_CHECK_ERR(res, "setListenerAttributes 2D failed");
	}
}

void FmodServer::pause_all_events(bool p_paused) {
	Ref<FmodBus> master_bus = get_bus("bus:/");
	if (master_bus.is_valid()) {
		master_bus->set_paused(p_paused);
	}
}

void FmodServer::mute_all_events(bool p_mute) {
	Ref<FmodBus> master_bus = get_bus("bus:/");
	if (master_bus.is_valid()) {
		master_bus->set_mute(p_mute);
	}
}

} // namespace godot
