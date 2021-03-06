package input;

import flixel.FlxG;
import input.SimpleController.Button;
import flixel.math.FlxVector;
import spacial.Cardinal;

/**
 * General helpers for deriving information from controls
 */
class InputCalcuator {
	private static var temp = FlxVector.get();

	/**
	 * Gets the closest cardinal direction as defined by the Cardinal enum, or Cardinal.NONE
	 * if no direction is pressed
	 */
	public static function getInputCardinal(player:Int = 0, fourDirection:Bool = true):Cardinal {
		temp.set();

		if (SimpleController.pressed(Button.UP, player)) {
			temp.add(0, -1);
		}

		if (SimpleController.pressed(Button.DOWN, player)) {
			temp.add(0, 1);
		}

		if (SimpleController.pressed(Button.LEFT, player)) {
			temp.add(-1, 0);
		}

		if (SimpleController.pressed(Button.RIGHT, player)) {
			temp.add(1, 0);
		}

		if (temp.length == 0) {
			return Cardinal.NONE;
		}

		return Cardinal.closest(temp, fourDirection);
	}

	public static function getDepthInput(player:Int = 0):Int {
		if (SimpleController.just_pressed(Button.A) || FlxG.keys.justPressed.E) {
			return 1;
		} else if (SimpleController.just_pressed(Button.B) || FlxG.keys.justPressed.Q) {
			return -1;
		} else {
			return 0;
		}
	}
}
