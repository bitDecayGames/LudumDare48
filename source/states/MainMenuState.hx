package states;

import haxe.Timer;
import states.transitions.Trans;
import states.transitions.SwirlTransition;
import com.bitdecay.analytics.Bitlytics;
import config.Configure;
import flixel.FlxG;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITypedButton;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;

using extensions.FlxStateExt;

#if windows
import lime.system.System;
#end

class MainMenuState extends FlxUIState {
	var _btnPlay:FlxButton;
	var _btnCredits:FlxButton;
	var _btnExit:FlxButton;

	var lastCursorLocation:Int = -1;

	var _txtTitle:FlxText;

	override public function create():Void {
		_xml_id = "main_menu";
		if (Configure.get().menus.keyboardNavigation || Configure.get().menus.controllerNavigation) {
			_makeCursor = true;
		}

		super.create();

		// camera.scroll.y = camera.scroll.y-camera.height;

		// _txtTitle = new FlxText();
		// _txtTitle.setPosition(0, camera.height - 20);
		// _txtTitle.size = 20;
		// _txtTitle.alignment = FlxTextAlign.CENTER;
		// _txtTitle.text = "Text";

		// add(_txtTitle);

		if (_makeCursor) {
			cursor.loadGraphic(AssetPaths.pointer__png, true, 32, 32);
			cursor.animation.add("pointing", [0, 1], 3);
			cursor.animation.play("pointing");

			var keys:Int = 0;
			if (Configure.get().menus.keyboardNavigation) {
				keys |= FlxUICursor.KEYS_ARROWS | FlxUICursor.KEYS_WASD;
			}
			if (Configure.get().menus.controllerNavigation) {
				keys |= FlxUICursor.GAMEPAD_DPAD;
			}
			cursor.setDefaultKeys(keys);
		}

		FmodManager.PlaySong(FmodSongs.Title);
		bgColor = FlxColor.TRANSPARENT;
		FlxG.camera.pixelPerfectRender = true;

		#if !windows
		// Hide exit button for non-windows targets
		var test = _ui.getAsset("exit_button");
		test.visible = false;
		#end

		// Trigger our focus logic as we are just creating the scene
		this.handleFocus();

		// we will handle transitions manually
		transOut = null;
	}

	override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (name == FlxUITypedButton.CLICK_EVENT) {
			var button_action:String = params[0];

			if (button_action == "play") {
				clickPlay();
				_ui.getAsset("play_button").active = false;
			}

			if (button_action == "credits") {
				clickCredits();
				_ui.getAsset("credits_button").active = false;
			}

			#if windows
			if (button_action == "exit") {
				clickExit();
			}
			#end
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();

		if (cursor.location != lastCursorLocation) {
			if (lastCursorLocation != -1){
				FmodManager.PlaySoundOneShot(FmodSFX.MenuHover);
			}
			lastCursorLocation = cursor.location;
		}


		if (camera.scroll.y <= 0) {
			camera.scroll.set(FlxG.camera.scroll.x, FlxG.camera.scroll.y + 10);
		}

		if (FlxG.keys.pressed.D && FlxG.keys.justPressed.M) {
			// Keys D.M. for Disable Metrics
			Bitlytics.Instance().EndSession();
			FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
			trace("---------- Bitlytics Stopped ----------");
		}
	}

	function clickPlay():Void {
		FmodManager.StopSong();
		FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);

		cursor.visible = false;

		Timer.delay(() -> {
			var swirlOut = new SwirlTransition(Trans.OUT, () -> {
				// make sure our music is stopped;
				FmodManager.StopSongImmediately();
				FlxG.switchState(new MoleFactsState(new PlayState()));
			});
			openSubState(swirlOut);
		}, 500);
	}

	function clickCredits():Void {
		FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
		FmodFlxUtilities.TransitionToState(new MoleFactsState(new CreditsState()));
	}

	#if windows
	function clickExit():Void {
		System.exit(0);
	}
	#end

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
