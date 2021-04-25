package helpers;

import flixel.math.FlxPoint;

class Constants {
	public static var TILE_SIZE:Int = 32;
	public static var HALF_TILE_SIZE:Int = 16;

	// tile types (currently these map directly to specific tilemap tiles, but they are really more like "tilemap types")
	public static var EMPTY_SPACE:Int = 0;
	public static var DIRT:Int = 1;
	public static var ROCK:Int = 2;
	public static var DUG_DIRT:Int = 3;

	// this is the tile type that replaces the DIRT tile when you dig it out (either DUG_DIRT or EMPTY_SPACE)
	public static var AFTER_DIG:Int = DUG_DIRT;

    public static var NO_TARGET:FlxPoint = FlxPoint.get(-999, -999);
}
