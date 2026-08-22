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

public partial class DemoAudio3DCSharp : Node3D
{
	private FmodListener3D _listener;
	private Node3D _listenerNode;
	private Node3D _listenerOrigin;
	private FmodEventEmitter3D _orbitingEmitter;
	private Node3D _orbitingEmitterNode;
	private Node3D _orbitPivot;

	private Label _statusLabel;
	private Label _infoLabel;
	private HSlider _rpmSlider;
	private Label _rpmValue;
	private HSlider _speedSlider;
	private Label _speedValue;
	private Button _btnPistol;
	private Button _btnExplosion;
	private Button _btnToggleCar;

	private float _orbitSpeed = 1.2f;
	private bool _carPlaying = true;
	private bool _mouseDragging = false;

	public override void _Ready()
	{
		_listenerOrigin = GetNode<Node3D>("ListenerOrigin");
		_listenerNode = GetNode<Node3D>("ListenerOrigin/Listener3D");
		_listener = _listenerNode.AsFmodListener3D();

		_orbitPivot = GetNode<Node3D>("OrbitPivot");
		_orbitingEmitterNode = GetNode<Node3D>("OrbitPivot/CarEmitter");
		_orbitingEmitter = _orbitingEmitterNode.AsFmodEmitter3D();

		_statusLabel = GetNode<Label>("CanvasLayer/HUD/TopPanel/Margin/VBox/StatusLabel");
		_infoLabel = GetNode<Label>("CanvasLayer/HUD/TopPanel/Margin/VBox/InfoLabel");
		_rpmSlider = GetNode<HSlider>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/RPMSlider");
		_rpmValue = GetNode<Label>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/RPMValue");
		_speedSlider = GetNode<HSlider>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/SpeedSlider");
		_speedValue = GetNode<Label>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/SpeedValue");
		_btnPistol = GetNode<Button>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnPistol");
		_btnExplosion = GetNode<Button>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnExplosion");
		_btnToggleCar = GetNode<Button>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnToggleCar");

		FmodServer.Initialize();
		LoadBanks();

		_orbitingEmitter.EventName = "event:/Vehicles/Car Engine";
		_orbitingEmitter.SetParameter("RPM", 3000.0f);
		_orbitingEmitter.SetParameter("Load", 0.6f);
		_orbitingEmitter.Play();

		_rpmSlider.ValueChanged += OnRpmChanged;
		_speedSlider.ValueChanged += OnSpeedChanged;
		_btnPistol.Pressed += OnPistolPressed;
		_btnExplosion.Pressed += OnExplosionPressed;
		_btnToggleCar.Pressed += OnToggleCarPressed;
	}

	private void LoadBanks()
	{
		string[] candidates = new string[]
		{
			(string)ProjectSettings.GetSetting("fmod/banks/banks_path", "res://banks/Desktop/"),
			"res://banks/Desktop/",
			"res://banks/",
			"res://"
		};

		string foundDir = "res://banks/Desktop/";
		foreach (string dirPath in candidates)
		{
			string testPath = dirPath.EndsWith("/") ? dirPath + "Master.bank" : dirPath + "/Master.bank";
			if (FileAccess.FileExists(testPath))
			{
				foundDir = dirPath.EndsWith("/") ? dirPath : dirPath + "/";
				break;
			}
		}

		FmodServer.LoadBank(foundDir + "Master.strings.bank");
		FmodServer.LoadBank(foundDir + "Master.bank");
		FmodServer.LoadBank(foundDir + "Vehicles.bank");
		FmodServer.LoadBank(foundDir + "SFX.bank");
		FmodServer.LoadBank(foundDir + "Music.bank");
	}

	public override void _Process(double delta)
	{
		FmodServer.Update();

		if (_carPlaying)
		{
			_orbitPivot.RotateY((float)(_orbitSpeed * delta));
		}

		Vector3 emitterPos = _orbitingEmitterNode.GlobalPosition;
		Vector3 listenerPos = _listenerNode.GlobalPosition;
		float dist = emitterPos.DistanceTo(listenerPos);

		_infoLabel.Text = $"🚗 Car Position: ({emitterPos.X:F1}, {emitterPos.Y:F1}, {emitterPos.Z:F1}) | 🎧 Distance to Listener: {dist:F2}m";
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseButton mb)
		{
			if (mb.ButtonIndex == MouseButton.Right || mb.ButtonIndex == MouseButton.Middle)
			{
				_mouseDragging = mb.Pressed;
			}
			else if (mb.ButtonIndex == MouseButton.Left && mb.Pressed)
			{
				Spawn3DShotAtMouse(mb.Position);
			}
		}
		else if (@event is InputEventMouseMotion mm && _mouseDragging)
		{
			Vector2 deltaRot = mm.Relative * 0.005f;
			_listenerOrigin.RotateY(-deltaRot.X);
		}
	}

	private void Spawn3DShotAtMouse(Vector2 screenPos)
	{
		Camera3D camera = GetViewport().GetCamera3D();
		if (camera == null) return;

		Vector3 from = camera.ProjectRayOrigin(screenPos);
		Vector3 dir = camera.ProjectRayNormal(screenPos);
		Vector3 spawnPos = from + dir * 6.0f;

		FmodServer.PlayOneShot3D("event:/Weapons/Pistol", spawnPos);

		_statusLabel.Text = $"🎯 3D One-Shot fired at: ({spawnPos.X:F1}, {spawnPos.Y:F1}, {spawnPos.Z:F1})";
	}

	private void OnRpmChanged(double value)
	{
		_rpmValue.Text = $"{(int)value} RPM";
		_orbitingEmitter.SetParameter("RPM", (float)value);
	}

	private void OnSpeedChanged(double value)
	{
		_orbitSpeed = (float)value;
		_speedValue.Text = $"{value:F1}x";
	}

	private void OnPistolPressed()
	{
		Vector3 pos = _orbitingEmitterNode.GlobalPosition;
		FmodServer.PlayOneShot3D("event:/Weapons/Pistol", pos);
		_statusLabel.Text = "🔫 Pistol 3D shot fired at Car position!";
	}

	private void OnExplosionPressed()
	{
		Vector3 pos = _orbitingEmitterNode.GlobalPosition;
		FmodServer.PlayOneShot3D("event:/Weapons/Explosion", pos);
		_statusLabel.Text = "💥 Explosion 3D triggered at Car position!";
	}

	private void OnToggleCarPressed()
	{
		_carPlaying = !_carPlaying;
		if (_carPlaying)
		{
			_orbitingEmitter.Play();
			_btnToggleCar.Text = "⏸ Pause Engine";
		}
		else
		{
			_orbitingEmitter.Stop(StopMode.AllowFadeout);
			_btnToggleCar.Text = "▶ Resume Engine";
		}
	}
}
