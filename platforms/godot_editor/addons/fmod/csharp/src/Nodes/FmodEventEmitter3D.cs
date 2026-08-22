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
    public class FmodEventEmitter3D
    {
        private readonly GodotObject _handle;

        public GodotObject Handle => _handle;

        public FmodEventEmitter3D(GodotObject handle)
        {
            _handle = handle;
        }

        public string EventName
        {
            get => _handle?.Call("get_event_name").AsString() ?? string.Empty;
            set => _handle?.Call("set_event_name", value);
        }

        public bool AutoPlay
        {
            get => _handle?.Call("get_auto_play").AsBool() ?? false;
            set => _handle?.Call("set_auto_play", value);
        }

        public bool AutoRelease
        {
            get => _handle?.Call("get_auto_release").AsBool() ?? false;
            set => _handle?.Call("set_auto_release", value);
        }

        public float Volume
        {
            get => _handle?.Call("get_volume").AsSingle() ?? 1.0f;
            set => _handle?.Call("set_volume", value);
        }

        public float Pitch
        {
            get => _handle?.Call("get_pitch").AsSingle() ?? 1.0f;
            set => _handle?.Call("set_pitch", value);
        }

        public void Play()
        {
            _handle?.Call("play");
        }

        public void Stop(StopMode stopMode = StopMode.AllowFadeout)
        {
            _handle?.Call("stop", (int)stopMode);
        }

        public bool IsPlaying => _handle != null && _handle.Call("is_playing").AsBool();

        public void SetParameter(string name, float value)
        {
            _handle?.Call("set_parameter", name, value);
        }

        public float GetParameter(string name)
        {
            return _handle?.Call("get_parameter", name).AsSingle() ?? 0.0f;
        }

        public FmodEventInstance GetEventInstance()
        {
            var inst = _handle?.Call("get_event_instance").As<GodotObject>();
            return inst != null ? new FmodEventInstance(inst) : null;
        }
    }
}
