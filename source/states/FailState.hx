package states;

import metrics.Metrics;
import com.bitdecay.metrics.Common;
import com.bitdecay.analytics.Bitlytics;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUICursor;
import config.Configure;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;
import helpers.UiHelpers;
import misc.FlxTextFactory;

using extensions.FlxStateExt;

class FailState extends FlxUIState {
	var _btnDone:FlxButton;

	var _txtTitle:FlxText;

	override public function create():Void {
		_xml_id = "molefacts";
		if (Configure.get().menus.keyboardNavigation || Configure.get().menus.controllerNavigation) {
			_makeCursor = true;
		}
		super.create();
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

		bgColor = FlxColor.TRANSPARENT;
		FlxG.camera.pixelPerfectRender = true;
		this.handleFocus();
		transOut = null;
		_txtTitle = FlxTextFactory.make("Mole rats are unable\nto survive being\neaten by snakes", 40, 25, 24, FlxTextAlign.CENTER);
		_txtTitle.color = FlxColor.BLACK;

		add(_txtTitle);

		Bitlytics.Instance().Queue(Metrics.DEATH, 1);
		Bitlytics.Instance().ForceFlush();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();
	}

	override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (name == FlxUITypedButton.CLICK_EVENT) {
			var button_action:String = params[0];

			if (button_action == "next") {
				clickMainMenu();
			}
		}
	}

	function clickMainMenu():Void {
		FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
		FmodFlxUtilities.TransitionToState(new MainMenuState());
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
