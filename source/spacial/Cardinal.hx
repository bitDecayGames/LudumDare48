package spacial;

import flixel.FlxObject;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;

/**
 * Cardinal direction handling. Directly usable as their integer value in degrees
**/
// TODO: This should work as from Float and to Float, also
enum abstract Cardinal(Int) from Int to Int {
	private static var upZeroAngle = new FlxVector(0, -1);
	private static inline var halfAngle = 22.5;
	var N = 0;
	var NE = 45;
	var E = 90;
	var SE = 135;
	var S = 180;
	var SW = 225;
	var W = 270;
	var NW = 315;
	var NONE = -1;

	/**
	 * Converts the given cardinal direction to a unit vector
	**/
	public function asVector(?v:FlxVector):FlxVector {
		if (v == null) {
			v = FlxVector.get();
		}

		v.set(0, -1).rotate(FlxPoint.weak(), this);
		return v;
	}

	/**
	 * Converts the given cardinal direction to radians
	**/
	public function asRads():Float {
		return this * FlxAngle.TO_RAD;
	}

	/**
	 * Converts the given cardinal the a Flixel facing integer
	**/
	public function asFacing():Int {
		var facing = 0;
		switch (this) {
			case NW | N | NE:
				facing |= FlxObject.UP;
			case SW | S | SE:
				facing |= FlxObject.DOWN;
		}
		switch (this) {
			case NE | E | SE:
				facing |= FlxObject.RIGHT;
			case NW | W | SW:
				facing |= FlxObject.LEFT;
		}
		return facing;
	}

	public function opposite():Cardinal {
		switch(this) {
			case N:
				return S;
			case NE:
				return SW;
			case E:
				return W;
			case SE:
				return NW;
			case S:
				return N;
			case SW:
				return NE;
			case W:
				return E;
			case NW:
				return SE;
			default:
				return NONE;
		}
	}

	public function asLetter():String {
		switch(this) {
			case N:
				return "u";
			case E:
				return "r";
			case S:
				return "d";
			case W:
				return "l";
			default:
				return "";
		}
	}

	/**
	 * Converts the cardinal direction to its opposite
	**/
	public function reverse():Cardinal {
		var vec = asVector().rotate(FlxPoint.weak(), 180);
		return closest(vec, true);
	}

	public function vertical(): Bool {
		return this == Cardinal.N || this == Cardinal.S;
	}

	public function horizontal(): Bool {
		return this == Cardinal.W || this == Cardinal.E;
	}

	/**
	 * Finds the closest cardinal for the given vector
	**/
	public static function closest(vec:FlxVector, fourDirection:Bool = false):Cardinal {
		// degrees: 0 is straight right, we want it to be straight up
		var angle = vec.degrees + 90;
		while (angle < 0) {
			angle += 360;
		}
		while (angle > 360) {
			angle -= 360;
		}

		if (fourDirection) {
			if (angle < 0 + NE) {
				return N;
			} else if (angle < 0 + SE) {
				return E;
			} else if (angle < 0 + SW) {
				return S;
			} else if (angle < 0 + NW) {
				return W;
			} else {
				return N;
			}
		} else {
			if (angle < N + halfAngle) {
				return N;
			} else if (angle < NE + halfAngle) {
				return NE;
			} else if (angle < E + halfAngle) {
				return E;
			} else if (angle < SE + halfAngle) {
				return SE;
			} else if (angle < S + halfAngle) {
				return S;
			} else if (angle < SW + halfAngle) {
				return SW;
			} else if (angle < W + halfAngle) {
				return W;
			} else if (angle < NW + halfAngle) {
				return NW;
			} else {
				return N;
			}
		}
	}
}
