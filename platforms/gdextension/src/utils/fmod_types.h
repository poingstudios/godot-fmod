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

#ifndef FMOD_TYPES_H
#define FMOD_TYPES_H

#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/variant/transform2d.hpp>
#include <godot_cpp/variant/transform3d.hpp>

#include <fmod_common.h>
#include <fmod_studio_common.h>

namespace godot {

inline FMOD_VECTOR godot_vector3_to_fmod(const Vector3 &p_vec) {
	FMOD_VECTOR fv;
	fv.x = p_vec.x;
	fv.y = p_vec.y;
	fv.z = p_vec.z;
	return fv;
}

inline Vector3 fmod_vector_to_godot(const FMOD_VECTOR &p_vec) {
	return Vector3(p_vec.x, p_vec.y, p_vec.z);
}

inline FMOD_VECTOR godot_vector2_to_fmod(const Vector2 &p_vec) {
	const float scale_2d = 0.02f; // 50 pixels = 1 meter
	FMOD_VECTOR fv;
	fv.x = p_vec.x * scale_2d;
	fv.y = 0.0f;
	fv.z = -p_vec.y * scale_2d;
	return fv;
}

inline FMOD_3D_ATTRIBUTES godot_transform3d_to_fmod(const Transform3D &p_transform, const Vector3 &p_velocity = Vector3()) {
	FMOD_3D_ATTRIBUTES attr;
	attr.position = godot_vector3_to_fmod(p_transform.origin);
	attr.velocity = godot_vector3_to_fmod(p_velocity);

	Vector3 forward = -p_transform.basis.get_column(2).normalized();
	Vector3 up = p_transform.basis.get_column(1).normalized();

	attr.forward = godot_vector3_to_fmod(forward);
	attr.up = godot_vector3_to_fmod(up);
	return attr;
}

inline FMOD_3D_ATTRIBUTES godot_transform2d_to_fmod(const Transform2D &p_transform, const Vector2 &p_velocity = Vector2()) {
	FMOD_3D_ATTRIBUTES attr;
	attr.position = godot_vector2_to_fmod(p_transform.get_origin());
	attr.velocity = godot_vector2_to_fmod(p_velocity);

	Vector2 forward_2d = -p_transform.columns[1].normalized();
	attr.forward.x = forward_2d.x;
	attr.forward.y = 0.0f;
	attr.forward.z = -forward_2d.y;

	attr.up.x = 0.0f;
	attr.up.y = 1.0f;
	attr.up.z = 0.0f;
	return attr;
}

} // namespace godot

#endif // FMOD_TYPES_H
