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
    public class FmodEventDescription
    {
        private readonly GodotObject _handle;

        public GodotObject Handle => _handle;

        public FmodEventDescription(GodotObject handle)
        {
            _handle = handle;
        }

        public bool IsValid => _handle != null && _handle.Call("is_valid").AsBool();

        public FmodEventInstance CreateInstance()
        {
            var instanceHandle = _handle?.Call("create_instance").As<GodotObject>();
            return instanceHandle != null ? new FmodEventInstance(instanceHandle) : null;
        }

        public int Length => _handle?.Call("get_length").AsInt32() ?? 0;

        public bool Is3D => _handle != null && _handle.Call("is_3d").AsBool();

        public bool IsOneshot => _handle != null && _handle.Call("is_oneshot").AsBool();

        public bool IsSnapshot => _handle != null && _handle.Call("is_snapshot").AsBool();

        public string Path => _handle?.Call("get_path").AsString() ?? string.Empty;
    }
}
