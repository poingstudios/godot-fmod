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
using System;

public partial class DemoAudio3DCSharp : Node3D
{
	private Node3D _playerRoot;
	private Node3D _characterVisual;
	private FmodListener3D _listener;
	private Node3D _listenerNode;
	private Node3D _cameraPivot;
	private Camera3D _cameraNode;

	private FmodEventEmitter3D _orbitingEmitter;
	private Node3D _orbitingEmitterNode;
	private Node3D _orbitPivot;

	private Label _statusLabel;
	private Label _infoLabel;

	private HSlider _rpmSlider;
	private Label _rpmValue;
	private HSlider _speedSlider;
	private Label _speedValue;
	private HSlider _radiusSlider;
	private Label _radiusValue;
	private HSlider _heightSlider;
	private Label _heightValue;

	private Button _btnPistol;
	private Button _btnExplosion;
	private Button _btnWood;
	private Button _btnToggleCar;
	private Button _btnReverse;
	private Button _btnReset;

	// Orbit Car settings
	private float _orbitSpeed = 1.2f;
	private float _orbitRadius = 8.0f;
	private float _orbitHeight = 0.4f;
	private float _orbitDirection = 1.0f;
	private bool _carPlaying = true;

	// Player Movement settings
	private float _walkSpeed = 7.0f;
	private float _sprintSpeed = 13.0f;
	private float _jumpVelocity = 9.0f;
	private float _gravity = 24.0f;
	private float _verticalVelocity = 0.0f;
	private float _playerHeading = 0.0f;
	private bool _isOnGround = true;

	// Third Person Orbit Camera settings
	private float _camYaw = 0.0f;
	private float _camPitch = -0.35f;
	private float _camDistance = 7.0f;
	private bool _mouseDragging = false;

	public override void _Ready()
	{
		_playerRoot = GetNode<Node3D>("Player");
		_characterVisual = GetNode<Node3D>("Player/CharacterVisual");
		_listenerNode = GetNode<Node3D>("Player/Listener3D");
		_listener = _listenerNode.AsFmodListener3D();
		_cameraPivot = GetNode<Node3D>("Player/CameraPivot");
		_cameraNode = GetNode<Camera3D>("Player/CameraPivot/Camera3D");

		_orbitPivot = GetNode<Node3D>("OrbitPivot");
		_orbitingEmitterNode = GetNode<Node3D>("OrbitPivot/CarEmitter");
		_orbitingEmitter = _orbitingEmitterNode.AsFmodEmitter3D();

		_statusLabel = GetNode<Label>("CanvasLayer/HUD/TopPanel/Margin/VBox/StatusLabel");
		_infoLabel = GetNode<Label>("CanvasLayer/HUD/TopPanel/Margin/VBox/InfoLabel");

		_rpmSlider = GetNode<HSlider>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/RPMSlider");
		_rpmValue = GetNode<Label>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/RPMValue");

		_speedSlider = GetNode<HSlider>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/SpeedSlider");
		_speedValue = GetNode<Label>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/SpeedValue");

		_radiusSlider = GetNode<HSlider>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/RadiusSlider");
		_radiusValue = GetNode<Label>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/RadiusValue");

		_heightSlider = GetNode<HSlider>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/HeightSlider");
		_heightValue = GetNode<Label>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/GridSliders/HeightValue");

		_btnPistol = GetNode<Button>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnPistol");
		_btnExplosion = GetNode<Button>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnExplosion");
		_btnWood = GetNode<Button>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons/BtnWood");

		_btnToggleCar = GetNode<Button>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons2/BtnToggleCar");
		_btnReverse = GetNode<Button>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons2/BtnReverse");
		_btnReset = GetNode<Button>("CanvasLayer/HUD/ControlsPanel/Margin/VBox/HBoxButtons2/BtnReset");

		FmodServer.Initialize();
		LoadBanks();

		_orbitingEmitter.EventName = "event:/Vehicles/Car Engine";
		_orbitingEmitter.SetParameter("RPM", 3000.0f);
		_orbitingEmitter.SetParameter("Load", 0.6f);
		_orbitingEmitter.Play();
		UpdateCarPosition();
		UpdateCameraTransform();

		_rpmSlider.ValueChanged += OnRpmChanged;
		_speedSlider.ValueChanged += OnSpeedChanged;
		_radiusSlider.ValueChanged += OnRadiusChanged;
		_heightSlider.ValueChanged += OnHeightChanged;

		_btnPistol.Pressed += OnPistolPressed;
		_btnExplosion.Pressed += OnExplosionPressed;
		_btnWood.Pressed += OnWoodPressed;
		_btnToggleCar.Pressed += OnToggleCarPressed;
		_btnReverse.Pressed += OnReversePressed;
		_btnReset.Pressed += OnResetPressed;
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
		HandlePlayerMovement((float)delta);

		if (_carPlaying)
		{
			_orbitPivot.RotateY((float)(_orbitSpeed * _orbitDirection * delta));
		}

		Vector3 emitterPos = _orbitingEmitterNode.GlobalPosition;
		Vector3 listenerPos = _listenerNode.GlobalPosition;
		float dist = emitterPos.DistanceTo(listenerPos);

		_infoLabel.Text = $"🏃 Player: ({listenerPos.X:F1}, {listenerPos.Y:F1}, {listenerPos.Z:F1}) | 🚗 Car: ({emitterPos.X:F1}, {emitterPos.Y:F1}, {emitterPos.Z:F1}) | 📏 Distance: {dist:F2}m";
	}

	private void HandlePlayerMovement(float delta)
	{
		Vector2 moveVec = Vector2.Zero;
		if (Input.IsKeyPressed(Key.W) || Input.IsKeyPressed(Key.Up)) moveVec.Y -= 1.0f;
		if (Input.IsKeyPressed(Key.S) || Input.IsKeyPressed(Key.Down)) moveVec.Y += 1.0f;
		if (Input.IsKeyPressed(Key.A) || Input.IsKeyPressed(Key.Left)) moveVec.X -= 1.0f;
		if (Input.IsKeyPressed(Key.D) || Input.IsKeyPressed(Key.Right)) moveVec.X += 1.0f;

		float speed = Input.IsKeyPressed(Key.Shift) ? _sprintSpeed : _walkSpeed;

		// Jumping and gravity
		if (_isOnGround)
		{
			if (Input.IsKeyPressed(Key.Space))
			{
				_verticalVelocity = _jumpVelocity;
				_isOnGround = false;
				FmodServer.PlayOneShot3D("event:/Interactables/Wooden Collision", _playerRoot.GlobalPosition);
			}
		}
		else
		{
			_verticalVelocity -= _gravity * delta;
			Vector3 pos = _playerRoot.GlobalPosition;
			pos.Y += _verticalVelocity * delta;
			if (pos.Y <= 0.0f)
			{
				pos.Y = 0.0f;
				_verticalVelocity = 0.0f;
				_isOnGround = true;
			}
			_playerRoot.GlobalPosition = pos;
		}

		if (moveVec != Vector2.Zero)
		{
			moveVec = moveVec.Normalized();

			Vector3 camForward = new Vector3(-MathF.Sin(_camYaw), 0.0f, -MathF.Cos(_camYaw)).Normalized();
			Vector3 camRight = new Vector3(MathF.Cos(_camYaw), 0.0f, -MathF.Sin(_camYaw)).Normalized();

			Vector3 worldDir = (camRight * moveVec.X + camForward * -moveVec.Y).Normalized();
			_playerRoot.GlobalPosition += worldDir * speed * delta;

			float targetHeading = MathF.Atan2(-worldDir.X, -worldDir.Z);
			_playerHeading = Mathf.LerpAngle(_playerHeading, targetHeading, 14.0f * delta);
			_characterVisual.Rotation = new Vector3(0.0f, _playerHeading, 0.0f);
			_listenerNode.Rotation = new Vector3(0.0f, _playerHeading, 0.0f);
		}
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseButton mb)
		{
			if (mb.ButtonIndex == MouseButton.Right || mb.ButtonIndex == MouseButton.Middle)
			{
				_mouseDragging = mb.Pressed;
			}
			else if (mb.ButtonIndex == MouseButton.WheelUp)
			{
				_camDistance = MathF.Max(2.0f, _camDistance - 0.6f);
				UpdateCameraTransform();
			}
			else if (mb.ButtonIndex == MouseButton.WheelDown)
			{
				_camDistance = MathF.Min(30.0f, _camDistance + 0.6f);
				UpdateCameraTransform();
			}
			else if (mb.ButtonIndex == MouseButton.Left && mb.Pressed)
			{
				Spawn3DShotAtMouse(mb.Position);
			}
		}
		else if (@event is InputEventMouseMotion mm && _mouseDragging)
		{
			_camYaw -= mm.Relative.X * 0.005f;
			_camPitch = Mathf.Clamp(_camPitch - mm.Relative.Y * 0.005f, Mathf.DegToRad(-80.0f), Mathf.DegToRad(50.0f));
			UpdateCameraTransform();
		}
		else if (@event is InputEventKey ke && ke.Pressed)
		{
			if (ke.Keycode == Key.Key1)
			{
				_camDistance = 7.0f;
				_camPitch = -0.35f;
				UpdateCameraTransform();
				_statusLabel.Text = "📷 3rd-Person Standard Orbit (7m)";
			}
			else if (ke.Keycode == Key.Key2)
			{
				_camDistance = 2.5f;
				_camPitch = -0.15f;
				UpdateCameraTransform();
				_statusLabel.Text = "📷 3rd-Person Over-The-Shoulder (2.5m)";
			}
			else if (ke.Keycode == Key.Key3)
			{
				_camDistance = 20.0f;
				_camPitch = -1.45f;
				UpdateCameraTransform();
				_statusLabel.Text = "📷 Top-Down Birds-Eye View (20m)";
			}
		}
	}

	private void UpdateCameraTransform()
	{
		if (_cameraPivot == null || _cameraNode == null) return;
		_cameraPivot.Rotation = new Vector3(0.0f, _camYaw, 0.0f);
		float offsetZ = _camDistance * MathF.Cos(_camPitch);
		float offsetY = -_camDistance * MathF.Sin(_camPitch);
		_cameraNode.Position = new Vector3(0.0f, offsetY, offsetZ);
		_cameraNode.Rotation = new Vector3(_camPitch, 0.0f, 0.0f);
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

	private void UpdateCarPosition()
	{
		_orbitingEmitterNode.Position = new Vector3(0.0f, _orbitHeight, -_orbitRadius);
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

	private void OnRadiusChanged(double value)
	{
		_orbitRadius = (float)value;
		_radiusValue.Text = $"{value:F1}m";
		UpdateCarPosition();
	}

	private void OnHeightChanged(double value)
	{
		_orbitHeight = (float)value;
		_heightValue.Text = $"{value:F1}m";
		UpdateCarPosition();
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

	private void OnWoodPressed()
	{
		Vector3 pos = _listenerNode.GlobalPosition + _characterVisual.GlobalTransform.Basis.Z * -1.5f;
		FmodServer.PlayOneShot3D("event:/Interactables/Wooden Collision", pos);
		_statusLabel.Text = "🪵 Wooden Collision played right in front of Character!";
	}

	private void OnToggleCarPressed()
	{
		_carPlaying = !_carPlaying;
		if (_carPlaying)
		{
			_orbitingEmitter.Play();
			_btnToggleCar.Text = "⏸ Pause";
		}
		else
		{
			_orbitingEmitter.Stop(StopMode.AllowFadeout);
			_btnToggleCar.Text = "▶ Resume";
		}
	}

	private void OnReversePressed()
	{
		_orbitDirection *= -1.0f;
		_statusLabel.Text = $"🔄 Orbit direction: {(_orbitDirection > 0 ? "Clockwise" : "Counter-Clockwise")}";
	}

	private void OnResetPressed()
	{
		_playerRoot.GlobalPosition = Vector3.Zero;
		_playerHeading = 0.0f;
		_camYaw = 0.0f;
		_camPitch = -0.35f;
		_camDistance = 7.0f;
		_characterVisual.Rotation = Vector3.Zero;
		_listenerNode.Rotation = Vector3.Zero;
		UpdateCameraTransform();
		_statusLabel.Text = "📍 Character reset to origin (0, 0, 0)";
	}
}
