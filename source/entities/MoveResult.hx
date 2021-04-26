package entities;

import spacial.Cardinal;
import helpers.TileType;
import flixel.math.FlxPoint;

class MoveResult {
	public var target:FlxPoint;
	public var moveIntoType:TileType;
	public var isFalling:Bool;
	public var changeInDepth:Int;
	public var dir:Cardinal;

	public function new(p:FlxPoint, type:TileType, isFalling:Bool, dir:Cardinal, changeInDepth:Int = 0) {
		target = p;
		moveIntoType = type;
		this.dir = dir;
		this.isFalling = isFalling;
		this.changeInDepth = changeInDepth;
	}
}
