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
	public class FmodBus
	{
		private readonly GodotObject _handle;

		public GodotObject Handle => _handle;

		public FmodBus(GodotObject handle)
		{
			_handle = handle;
		}

		public bool IsValid => _handle != null && _handle.Call("is_valid").AsBool();

		public float Volume
		{
			get => _handle?.Call("get_volume").AsSingle() ?? 1.0f;
			set => _handle?.Call("set_volume", value);
		}

		public bool Muted
		{
			get => _handle?.Call("get_mute").AsBool() ?? false;
			set => _handle?.Call("set_mute", value);
		}

		public bool Paused
		{
			get => _handle?.Call("get_paused").AsBool() ?? false;
			set => _handle?.Call("set_paused", value);
		}

		public void StopAllEvents(StopMode stopMode = StopMode.AllowFadeout)
		{
			_handle?.Call("stop_all_events", (int)stopMode);
		}
	}
}
