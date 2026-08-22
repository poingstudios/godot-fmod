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

#include "register_types.h"

#include <gdextension_interface.h>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include "fmod_server.h"
#include "nodes/fmod_event_emitter_2d.h"
#include "nodes/fmod_event_emitter_3d.h"
#include "nodes/fmod_listener_2d.h"
#include "nodes/fmod_listener_3d.h"
#include "studio/fmod_bank.h"
#include "studio/fmod_bus.h"
#include "studio/fmod_event_description.h"
#include "studio/fmod_event_instance.h"
#include "studio/fmod_vca.h"

using namespace godot;

static FmodServer *fmod_server = nullptr;

void initialize_godot_fmod_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	ClassDB::register_class<FmodBank>();
	ClassDB::register_class<FmodEventDescription>();
	ClassDB::register_class<FmodEventInstance>();
	ClassDB::register_class<FmodBus>();
	ClassDB::register_class<FmodVCA>();
	ClassDB::register_class<FmodServer>();

	ClassDB::register_class<FmodEventEmitter3D>();
	ClassDB::register_class<FmodEventEmitter2D>();
	ClassDB::register_class<FmodListener3D>();
	ClassDB::register_class<FmodListener2D>();

	fmod_server = memnew(FmodServer);
	Engine::get_singleton()->register_singleton("FmodServer", fmod_server);
}

void uninitialize_godot_fmod_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	if (fmod_server != nullptr) {
		Engine::get_singleton()->unregister_singleton("FmodServer");
		memdelete(fmod_server);
		fmod_server = nullptr;
	}
}

extern "C" {
GDExtensionBool GDE_EXPORT godot_fmod_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

	init_obj.register_initializer(initialize_godot_fmod_module);
	init_obj.register_terminator(uninitialize_godot_fmod_module);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

	return init_obj.init();
}
}
