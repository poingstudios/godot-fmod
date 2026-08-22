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

		_spatialEmitter?.SetParameter("RPM", 2000.0f);

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
			float screenWidth = GetViewportRect().Size.X;
			float xPos = (Mathf.Sin(time * 1.5f) * 0.4f + 0.5f) * screenWidth;
			_spatialEmitterNode.Position = new Vector2(xPos, 520.0f);
		}
	}

	public void OnPlaySfxPressed()
	{
		FmodServer.PlayOneShot("event:/Weapons/Explosion");
		_statusLabel.Text = "[C#] Played One-Shot SFX: Weapons/Explosion (Center)";
	}

	public void OnStartMusicPressed()
	{
		if (_musicInstance == null || !_musicInstance.IsValid)
		{
			_musicInstance = FmodServer.CreateEventInstance("event:/Music/Level 01");
			_musicInstance?.SetParameterByName("Progression", (float)_paramSlider.Value);
			_musicInstance?.Start();
			_statusLabel.Text = "[C#] Started Music: Level 01";
		}
		else if (_musicInstance.GetPlaybackState() == PlaybackState.Stopped)
		{
			_musicInstance.Start();
			_statusLabel.Text = "[C#] Restarted Music: Level 01";
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
			_statusLabel.Text = "[C#] Music Stopped (Fadeout)";
		}
	}

	public void OnToggleEmitterMovePressed()
	{
		if (_spatialEmitter != null && _spatialEmitter.IsPlaying)
		{
			_spatialEmitter.Stop(StopMode.AllowFadeout);
			_statusLabel.Text = "[C#] Spatial Emitter Stopped";
		}
		else if (_spatialEmitter != null)
		{
			_spatialEmitter.Play();
			_statusLabel.Text = "[C#] Spatial Emitter Playing (Panning left/right)";
		}
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
		Vector2 emitterPos = _spatialEmitterNode != null ? _spatialEmitterNode.Position : Vector2.Zero;
		if ((clickPos - emitterPos).Length() <= 50.0f)
		{
			FmodServer.PlayOneShot2D("event:/Interactables/Wooden Collision", emitterPos);
			_statusLabel.Text = "[C#] 🎯 DIRECT HIT on Moving Logo! (Wooden Collision)";
			if (_spatialIcon != null)
			{
				PunchIcon(_spatialIcon, new Vector2(0.4f, 0.4f), new Vector2(0.65f, 0.65f));
			}
			SpawnVisualShot(clickPos, "DIRECT HIT!", new Color(1.0f, 0.9f, 0.2f));
			return;
		}

		Vector2 listenerPos = _listenerNode != null ? _listenerNode.Position : new Vector2(576, 324);
		if ((clickPos - listenerPos).Length() <= 50.0f)
		{
			Sprite2D listenerIcon = _listenerNode.GetNodeOrNull<Sprite2D>("ListenerIcon");
			FmodServer.PlayOneShot("event:/Interactables/Wooden Collision");
			_statusLabel.Text = "[C#] 🎧 DIRECT HIT on Center Listener! (Wooden Collision)";
			if (listenerIcon != null)
			{
				PunchIcon(listenerIcon, new Vector2(0.5f, 0.5f), new Vector2(0.8f, 0.8f));
			}
			SpawnVisualShot(clickPos, "LISTENER HIT!", new Color(0.3f, 0.9f, 1.0f));
			return;
		}

		FmodServer.PlayOneShot2D("event:/Weapons/Pistol", clickPos);

		float dx = clickPos.X - listenerPos.X;
		float distanceM = (clickPos - listenerPos).Length() * 0.02f;

		string sideStr = "Center";
		if (dx < -30.0f)
		{
			sideStr = $"Left Ear ({(int)Mathf.Abs(dx)}px)";
		}
		else if (dx > 30.0f)
		{
			sideStr = $"Right Ear ({(int)dx}px)";
		}

		_statusLabel.Text = $"[C#] Shot at ({(int)clickPos.X}, {(int)clickPos.Y}) -> {sideStr} | ~{distanceM:0.1}m";
		SpawnVisualShot(clickPos, sideStr, new Color(1.0f, 0.3f, 0.2f, 1.0f));
	}

	private void PunchIcon(Sprite2D sprite, Vector2 baseScale, Vector2 punchScale)
	{
		Tween tween = CreateTween();
		tween.TweenProperty(sprite, "scale", punchScale, 0.08).SetTrans(Tween.TransitionType.Back).SetEase(Tween.EaseType.Out);
		tween.TweenProperty(sprite, "scale", baseScale, 0.15).SetTrans(Tween.TransitionType.Elastic).SetEase(Tween.EaseType.Out);
	}

	private void SpawnVisualShot(Vector2 pos, string textInfo, Color shotColor)
	{
		Node2D marker = new Node2D();
		marker.Position = pos;
		AddChild(marker);

		ColorRect circle = new ColorRect();
		circle.Size = new Vector2(16, 16);
		circle.Position = new Vector2(-8, -8);
		circle.Color = shotColor;
		circle.MouseFilter = Control.MouseFilterEnum.Ignore;
		marker.AddChild(circle);

		Label label = new Label();
		label.Text = "🎯 " + textInfo;
		label.Position = new Vector2(-75, -30);
		label.Size = new Vector2(150, 25);
		label.HorizontalAlignment = HorizontalAlignment.Center;
		label.Modulate = shotColor;
		label.MouseFilter = Control.MouseFilterEnum.Ignore;
		marker.AddChild(label);

		Tween tween = CreateTween();
		tween.SetParallel(true);
		tween.TweenProperty(circle, "scale", new Vector2(3.0f, 3.0f), 0.3f);
		tween.TweenProperty(marker, "modulate:a", 0.0f, 0.3f);
		tween.Chain().TweenCallback(Callable.From(marker.QueueFree));
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
