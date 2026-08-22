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

using Godot;

namespace PoingStudios.GodotFmod
{
    public class FmodEventInstance
    {
        private readonly GodotObject _handle;

        public GodotObject Handle => _handle;

        public FmodEventInstance(GodotObject handle)
        {
            _handle = handle;
        }

        public bool IsValid => _handle != null && _handle.Call("is_valid").AsBool();

        public void Start()
        {
            _handle?.Call("start");
        }

        public void Stop(StopMode stopMode = StopMode.AllowFadeout)
        {
            _handle?.Call("stop", (int)stopMode);
        }

        public PlaybackState GetPlaybackState()
        {
            return (PlaybackState)(_handle?.Call("get_playback_state").AsInt32() ?? (int)PlaybackState.Stopped);
        }

        public bool Paused
        {
            get => _handle?.Call("get_paused").AsBool() ?? false;
            set => _handle?.Call("set_paused", value);
        }

        public float Pitch
        {
            get => _handle?.Call("get_pitch").AsSingle() ?? 1.0f;
            set => _handle?.Call("set_pitch", value);
        }

        public float Volume
        {
            get => _handle?.Call("get_volume").AsSingle() ?? 1.0f;
            set => _handle?.Call("set_volume", value);
        }

        public int TimelinePosition
        {
            get => _handle?.Call("get_timeline_position").AsInt32() ?? 0;
            set => _handle?.Call("set_timeline_position", value);
        }

        public void SetParameterByName(string name, float value, bool ignoreSeekSpeed = false)
        {
            _handle?.Call("set_parameter_by_name", name, value, ignoreSeekSpeed);
        }

        public float GetParameterByName(string name)
        {
            return _handle?.Call("get_parameter_by_name", name).AsSingle() ?? 0.0f;
        }

        public void Set3DAttributes(Transform3D transform, Vector3 velocity = default)
        {
            _handle?.Call("set_3d_attributes", transform, velocity);
        }

        public void Set3DAttributes2D(Transform2D transform, Vector2 velocity = default)
        {
            _handle?.Call("set_3d_attributes_2d", transform, velocity);
        }

        public void Release()
        {
            _handle?.Call("release");
        }
    }
}
