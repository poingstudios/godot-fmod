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

#include "fmod_vca.h"
#include "../utils/fmod_macros.h"

namespace godot {

void FmodVCA::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_valid"), &FmodVCA::is_valid);
	ClassDB::bind_method(D_METHOD("set_volume", "volume"), &FmodVCA::set_volume);
	ClassDB::bind_method(D_METHOD("get_volume"), &FmodVCA::get_volume);
}

FmodVCA::FmodVCA() {
}

FmodVCA::~FmodVCA() {
}

void FmodVCA::set_vca_handle(FMOD::Studio::VCA *p_vca) {
	vca = p_vca;
}

FMOD::Studio::VCA *FmodVCA::get_vca_handle() const {
	return vca;
}

bool FmodVCA::is_valid() const {
	return vca != nullptr && vca->isValid();
}

void FmodVCA::set_volume(float p_volume) {
	if (is_valid()) {
		FMOD_RESULT res = vca->setVolume(p_volume);
		FMOD_CHECK_ERR(res, "FmodVCA::set_volume failed");
	}
}

float FmodVCA::get_volume() const {
	if (!is_valid()) {
		return 1.0f;
	}
	float vol = 1.0f;
	FMOD_RESULT res = vca->getVolume(&vol);
	FMOD_CHECK_ERR(res, "FmodVCA::get_volume failed");
	return vol;
}

} // namespace godot
