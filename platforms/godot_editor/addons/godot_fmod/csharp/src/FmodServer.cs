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
	public static class FmodServer
	{
		private static GodotObject _server;

		private static GodotObject Server
		{
			get
			{
				if (_server == null && Engine.HasSingleton("FmodServer"))
				{
					_server = Engine.GetSingleton("FmodServer");
				}
				return _server;
			}
		}

		public static bool Initialize(int maxChannels = 1024, int studioFlags = 0, int coreFlags = 0)
		{
			return Server?.Call("initialize", maxChannels, studioFlags, coreFlags).AsBool() ?? false;
		}

		public static void Update()
		{
			Server?.Call("update");
		}

		public static void Shutdown()
		{
			Server?.Call("shutdown");
		}

		public static bool IsInitialized()
		{
			return Server?.Call("is_initialized").AsBool() ?? false;
		}

		public static FmodBank LoadBank(string path, int flags = 0)
		{
			var handle = Server?.Call("load_bank", path, flags).As<GodotObject>();
			return handle != null ? new FmodBank(handle) : null;
		}

		public static void UnloadBank(string path)
		{
			Server?.Call("unload_bank", path);
		}

		public static void UnloadAllBanks()
		{
			Server?.Call("unload_all_banks");
		}

		public static bool IsBankLoaded(string path)
		{
			return Server?.Call("is_bank_loaded", path).AsBool() ?? false;
		}

		public static FmodEventDescription GetEventDescription(string path)
		{
			var handle = Server?.Call("get_event_description", path).As<GodotObject>();
			return handle != null ? new FmodEventDescription(handle) : null;
		}

		public static FmodEventInstance CreateEventInstance(string path)
		{
			var handle = Server?.Call("create_event_instance", path).As<GodotObject>();
			return handle != null ? new FmodEventInstance(handle) : null;
		}

		public static void PlayOneShot(string path)
		{
			Server?.Call("play_one_shot", path);
		}

		public static void PlayOneShot3D(string path, Vector3 position)
		{
			Server?.Call("play_one_shot_3d", path, position);
		}

		public static void PlayOneShot2D(string path, Vector2 position)
		{
			Server?.Call("play_one_shot_2d", path, position);
		}

		public static FmodBus GetBus(string path)
		{
			var handle = Server?.Call("get_bus", path).As<GodotObject>();
			return handle != null ? new FmodBus(handle) : null;
		}

		public static FmodVca GetVca(string path)
		{
			var handle = Server?.Call("get_vca", path).As<GodotObject>();
			return handle != null ? new FmodVca(handle) : null;
		}

		public static void SetGlobalParameterByName(string name, float value, bool ignoreSeekSpeed = false)
		{
			Server?.Call("set_global_parameter_by_name", name, value, ignoreSeekSpeed);
		}

		public static float GetGlobalParameterByName(string name)
		{
			return Server?.Call("get_global_parameter_by_name", name).AsSingle() ?? 0.0f;
		}

		public static void SetListenerAttributes3D(int listenerIndex, Transform3D transform, Vector3 velocity = default)
		{
			Server?.Call("set_listener_attributes_3d", listenerIndex, transform, velocity);
		}

		public static void SetListenerAttributes2D(int listenerIndex, Transform2D transform, Vector2 velocity = default)
		{
			Server?.Call("set_listener_attributes_2d", listenerIndex, transform, velocity);
		}

		public static void PauseAllEvents(bool paused)
		{
			Server?.Call("pause_all_events", paused);
		}

		public static void MuteAllEvents(bool mute)
		{
			Server?.Call("mute_all_events", mute);
		}
	}
}
