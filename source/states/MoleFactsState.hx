package states;

import flixel.math.FlxRandom;
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
import flixel.FlxState;

using extensions.FlxStateExt;

class MoleFactsState extends FlxUIState {
	public static var moleFactsIndex = -1;

	var goTo:FlxState;

	var text:FlxText;

	public function new(goTo:FlxState) {
		super();
		this.goTo = goTo;
	}

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

		text = new FlxText();
		text.setPosition(15, 35);
		text.size = 20;
		text.alignment = FlxTextAlign.LEFT;
		text.color = FlxColor.BLACK;

		setMoleFact();
		add(text);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.keys.justPressed.PLUS) {
			setMoleFact();
		}
	}

	override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (name == FlxUITypedButton.CLICK_EVENT) {
			var button_action:String = params[0];

			if (button_action == "next") {
				clickNext();
				_ui.getAsset("next").active = false;
			}
		}
	}

	private function setMoleFact() {
		var moleFacts = Configure.getMoleFacts();
		if (moleFactsIndex < 0) {
			var rnd = new FlxRandom();
			moleFactsIndex = rnd.int(0, moleFacts.length);
		}
		if (moleFactsIndex < 0 || moleFactsIndex >= moleFacts.length) {
			moleFactsIndex = 0;
		}
		var moleFact = moleFacts[moleFactsIndex];
		moleFactsIndex++;
		text.text = moleFact;
	}

	function clickNext():Void {
		FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
		FlxG.switchState(goTo);
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
