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
using PoingStudios.GodotFmod;

public partial class DemoAudioCSharp : Control
{
	private Label _statusLabel;
	private HSlider _paramSlider;
	private Label _paramValueLabel;
	private HSlider _rpmSlider;
	private Label _rpmValueLabel;
	private HSlider _volumeSlider;
	private Label _volumeValueLabel;
	private FmodEventEmitter2D _spatialEmitter;
	private Node2D _spatialEmitterNode;
	private Sprite2D _spatialIcon;
	private FmodListener2D _listener;
	private Node2D _listenerNode;

	private FmodEventInstance _musicInstance;
	private bool _isMovingEmitter = true;

	public override void _Ready()
	{
		_statusLabel = GetNode<Label>("TopPanel/Margin/VBoxContainer/StatusLabel");
		_paramSlider = GetNode<HSlider>("TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxParam/ParamSlider");
		_paramValueLabel = GetNode<Label>("TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxParam/ParamValue");
		_rpmSlider = GetNode<HSlider>("TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxRPM/RPMSlider");
		_rpmValueLabel = GetNode<Label>("TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxRPM/RPMValue");
		_volumeSlider = GetNode<HSlider>("TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxVolume/VolumeSlider");
		_volumeValueLabel = GetNode<Label>("TopPanel/Margin/VBoxContainer/HBoxSliders/HBoxVolume/VolumeValue");
		_spatialEmitterNode = GetNode<Node2D>("SpatialEmitter");
		_spatialEmitter = _spatialEmitterNode.AsFmodEmitter2D();
		_spatialIcon = GetNode<Sprite2D>("SpatialEmitter/Icon");
		_listenerNode = GetNode<Node2D>("Listener");
		_listener = _listenerNode.AsFmodListener2D();

		FmodServer.Initialize();

		FmodServer.LoadBank("res://banks/Desktop/Master.bank");
		FmodServer.LoadBank("res://banks/Desktop/Master.strings.bank");
		FmodServer.LoadBank("res://banks/Desktop/Music.bank");
		FmodServer.LoadBank("res://banks/Desktop/SFX.bank");
		FmodServer.LoadBank("res://banks/Desktop/Vehicles.bank");

		_statusLabel.Text = "[C#] Click anywhere across the screen to test spatial audio!";

		_paramSlider.ValueChanged += OnParamSliderChanged;
		_rpmSlider.ValueChanged += OnRpmSliderChanged;
		_volumeSlider.ValueChanged += OnVolumeSliderChanged;
	}

	public override void _GuiInput(InputEvent @event)
	{
		if (@event is InputEventMouseButton mb && mb.ButtonIndex == MouseButton.Left && mb.Pressed)
		{
			FireShotAt(mb.Position);
		}
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseButton mb && mb.ButtonIndex == MouseButton.Left && mb.Pressed)
		{
			FireShotAt(mb.Position);
		}
	}

	public override void _Process(double delta)
	{
		FmodServer.Update();

		if (_isMovingEmitter && _spatialEmitterNode != null)
		{
			float time = (float)Time.GetTicksMsec() / 1000.0f;
			Vector2 center = new Vector2(576, 324);
			float radiusX = 350.0f;
			float radiusY = 160.0f;
			_spatialEmitterNode.Position = new Vector2(
				center.X + Mathf.Cos(time * 0.7f) * radiusX,
				center.Y + Mathf.Sin(time * 0.7f) * radiusY
			);
		}
	}

	public void OnPlaySfxPressed()
	{
		FmodServer.PlayOneShot("event:/Weapons/Explosion");
		_statusLabel.Text = "[C#] SFX Played: event:/Weapons/Explosion (2D Global)";
	}

	public void OnStartMusicPressed()
	{
		if (_musicInstance == null || !_musicInstance.IsValid)
		{
			_musicInstance = FmodServer.CreateEventInstance("event:/Music/Level 01");
			_musicInstance?.SetParameterByName("Progression", (float)_paramSlider.Value);
			_musicInstance?.Start();
			_statusLabel.Text = "[C#] Music Started: Level 01";
		}
		else if (_musicInstance.GetPlaybackState() == PlaybackState.Stopped)
		{
			_musicInstance.Start();
			_statusLabel.Text = "[C#] Music Restarted: Level 01";
		}
	}

	public void OnPauseResumeMusicPressed()
	{
		if (_musicInstance != null && _musicInstance.IsValid)
		{
			bool paused = _musicInstance.Paused;
			_musicInstance.Paused = !paused;
			_statusLabel.Text = !paused ? "[C#] Music Paused" : "[C#] Music Resumed";
		}
	}

	public void OnFadeoutMusicPressed()
	{
		if (_musicInstance != null && _musicInstance.IsValid)
		{
			_musicInstance.Stop(StopMode.AllowFadeout);
			_statusLabel.Text = "[C#] Music Stopping with Fadeout...";
		}
	}

	public void OnToggleEmitterMovePressed()
	{
		_isMovingEmitter = !_isMovingEmitter;
		_statusLabel.Text = _isMovingEmitter ? "[C#] Car Emitter: Moving Orbit" : "[C#] Car Emitter: Stationary";
	}

	private void OnParamSliderChanged(double value)
	{
		_paramValueLabel.Text = value.ToString("0.0");
		if (_musicInstance != null && _musicInstance.IsValid)
		{
			_musicInstance.SetParameterByName("Progression", (float)value);
			_statusLabel.Text = $"[C#] Level 01 Progression: {value:0.0}";
		}
	}

	private void OnRpmSliderChanged(double value)
	{
		_rpmValueLabel.Text = $"{value:0} RPM";
		_spatialEmitter?.SetParameter("RPM", (float)value);
		_statusLabel.Text = $"[C#] Car Engine RPM: {value:0}";
	}

	private void OnVolumeSliderChanged(double value)
	{
		_volumeValueLabel.Text = $"{Mathf.RoundToInt((float)value * 100)}%";
		FmodBus masterBus = FmodServer.GetBus("bus:/");
		if (masterBus != null && masterBus.IsValid)
		{
			masterBus.Volume = (float)value;
			_statusLabel.Text = $"[C#] Master Bus Volume: {Mathf.RoundToInt((float)value * 100)}%";
		}
	}

	private void FireShotAt(Vector2 clickPos)
	{
		FmodServer.PlayOneShot2D("event:/Weapons/Pistol", clickPos);
		Vector2 center = _listenerNode != null ? _listenerNode.Position : new Vector2(576, 324);
		float distMeters = (clickPos - center).Length() * 0.02f;
		string side = clickPos.X < center.X ? "LEFT" : "RIGHT";
		_statusLabel.Text = $"[C#] 🔫 Pistol Shot at ({clickPos.X:0}, {clickPos.Y:0}) — {distMeters:0.1}m {side}";
	}

	public override void _ExitTree()
	{
		if (_musicInstance != null && _musicInstance.IsValid)
		{
			_musicInstance.Stop(StopMode.Immediate);
			_musicInstance.Release();
			_musicInstance = null;
		}
		FmodServer.UnloadAllBanks();
		FmodServer.Shutdown();
	}
}
