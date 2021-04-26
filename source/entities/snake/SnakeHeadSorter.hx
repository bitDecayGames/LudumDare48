package entities.snake;

import flixel.FlxSprite;
import flixel.util.FlxSort;

class SnakeHeadSorter {
	static var ARIBITRARY_LARGE_VALUE = 9999999;

	private static function getSpriteZ(s: FlxSprite): Int {
		return Type.getClass(s) == SnakeHead ? ARIBITRARY_LARGE_VALUE : 0;
	}

	// sort will sort things based on the CENTER-Y of their hitboxes
	public static inline function sort(order:Int, s1:FlxSprite, s2:FlxSprite):Int {
		return FlxSort.byValues(
			order,
			s1.y + (s1.height / 2) + getSpriteZ(s1),
			s2.y + (s2.height / 2) + getSpriteZ(s2)
		);
	}
}