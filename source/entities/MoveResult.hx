package entities;

import helpers.TileType;
import flixel.math.FlxPoint;

class MoveResult {
	public var target:FlxPoint;
	public var moveIntoType:TileType;

	public function new(p:FlxPoint, type:TileType) {
		target = p;
		moveIntoType = type;
	}
}