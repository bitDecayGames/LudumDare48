package entities;

import helpers.TileType;
import flixel.math.FlxPoint;

class MoveResult {
	public var target:FlxPoint;
	public var moveIntoType:TileType;
	public var isFalling:Bool;
	public var changeInDepth:Int;

	public function new(p:FlxPoint, type:TileType, isFalling:Bool, changeInDepth:Int = 0) {
		target = p;
		moveIntoType = type;
		this.isFalling = isFalling;
		this.changeInDepth = changeInDepth;
	}
}
