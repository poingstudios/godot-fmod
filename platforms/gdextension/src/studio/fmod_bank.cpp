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

#include "fmod_bank.h"
#include "../utils/fmod_macros.h"

namespace godot {

void FmodBank::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_valid"), &FmodBank::is_valid);
	ClassDB::bind_method(D_METHOD("unload"), &FmodBank::unload);
	ClassDB::bind_method(D_METHOD("get_loading_state"), &FmodBank::get_loading_state);
	ClassDB::bind_method(D_METHOD("load_sample_data"), &FmodBank::load_sample_data);
	ClassDB::bind_method(D_METHOD("unload_sample_data"), &FmodBank::unload_sample_data);
	ClassDB::bind_method(D_METHOD("get_sample_loading_state"), &FmodBank::get_sample_loading_state);
}

FmodBank::FmodBank() {
}

FmodBank::~FmodBank() {
}

void FmodBank::set_bank_handle(FMOD::Studio::Bank *p_bank) {
	bank = p_bank;
}

FMOD::Studio::Bank *FmodBank::get_bank_handle() const {
	return bank;
}

bool FmodBank::is_valid() const {
	return bank != nullptr && bank->isValid();
}

void FmodBank::unload() {
	if (is_valid()) {
		FMOD_RESULT res = bank->unload();
		FMOD_CHECK_ERR(res, "FmodBank::unload failed");
		bank = nullptr;
	}
}

int FmodBank::get_loading_state() const {
	if (!is_valid()) {
		return FMOD_STUDIO_LOADING_STATE_UNLOADED;
	}
	FMOD_STUDIO_LOADING_STATE state;
	FMOD_RESULT res = bank->getLoadingState(&state);
	FMOD_CHECK_ERR(res, "FmodBank::get_loading_state failed");
	return static_cast<int>(state);
}

void FmodBank::load_sample_data() {
	if (is_valid()) {
		FMOD_RESULT res = bank->loadSampleData();
		FMOD_CHECK_ERR(res, "FmodBank::load_sample_data failed");
	}
}

void FmodBank::unload_sample_data() {
	if (is_valid()) {
		FMOD_RESULT res = bank->unloadSampleData();
		FMOD_CHECK_ERR(res, "FmodBank::unload_sample_data failed");
	}
}

int FmodBank::get_sample_loading_state() const {
	if (!is_valid()) {
		return FMOD_STUDIO_LOADING_STATE_UNLOADED;
	}
	FMOD_STUDIO_LOADING_STATE state;
	FMOD_RESULT res = bank->getSampleLoadingState(&state);
	FMOD_CHECK_ERR(res, "FmodBank::get_sample_loading_state failed");
	return static_cast<int>(state);
}

} // namespace godot
