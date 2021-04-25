package entities;

import input.InputCalcuator;
import haxe.macro.Expr.Constant;
import flixel.math.FlxVector;
import input.SimpleController;
import flixel.math.FlxPoint;
import flixel.FlxG;
import spacial.Cardinal;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import helpers.Constants;

using extensions.FlxPointExt;

class Player extends FlxSprite {
	private static inline var IDLE = "idle";
	private static inline var WALK_RIGHT = "walkRight";
	private static inline var WALK_LEFT = "walkLeft";
	private static inline var TURN_RIGHT_TO_LEFT = "turnRightLeft";
	private static inline var TURN_LEFT_TO_RIGHT = "turnLeftRight";

	private static inline var WALK_UP = "walkUp";
	private static inline var WALK_DOWN = "walkDown";
	private static inline var TURN_UP_TO_DOWN = "turnUpDown";
	private static inline var TURN_DOWN_TO_UP = "turnDownUp";

	private static inline var TURN_UP_TO_RIGHT = "turnUpRight";
	private static inline var TURN_UP_TO_LEFT = "turnUpLeft";

	private static inline var TURN_DOWN_TO_RIGHT = "turnDownRight";
	private static inline var TURN_DOWN_TO_LEFT = "turnDownLeft";

	private static inline var TURN_LEFT_TO_UP = "turnLeftUp";
	private static inline var TURN_LEFT_TO_DOWN = "turnLeftDown";

	private static inline var TURN_RIGHT_TO_UP = "turnRightUp";
	private static inline var TURN_RIGHT_TO_DOWN = "turnRightDown";

	var speed:Float = 240;
	var framerate:Int = 10;
	var moving:Bool;

	private static var NO_TARGET = FlxPoint.get(-999, -999);

	public var target:FlxPoint = FlxPoint.get().copyFrom(NO_TARGET);

	var temp:FlxVector = FlxVector.get();

	var stopped:Bool = true;
	var lastDirection:Cardinal = NONE;
	var inTransition:Bool = false;

	var moleFollowingMe:FlxSprite;

	public function new() {
		super();
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BLUE);
		updateHitbox();

		loadGraphic(AssetPaths.Player__png, true, 32, 32);
		var row = 12;
		animation.add("idle", [0]);

		animation.add(WALK_RIGHT, [for(i in row...row+8) i], framerate);
		animation.add(WALK_LEFT, [for(i in row...row+8) i], framerate, true, true);
		animation.add(WALK_DOWN, [for(i in 5*row...5*row+8) i], framerate);
		animation.add(WALK_UP, [for(i in 7*row...7*row+8) i], framerate);

		animation.add(TURN_RIGHT_TO_UP, [0], framerate, false);
		animation.add(TURN_RIGHT_TO_LEFT, [for(i in row+8...2*row) i], framerate, false);
		animation.add(TURN_RIGHT_TO_DOWN, [0], framerate, false);

		animation.add(TURN_LEFT_TO_UP, [0], framerate, false);
		animation.add(TURN_LEFT_TO_RIGHT, [for(i in 2*row+8...3*row) i], framerate, false);
		animation.add(TURN_LEFT_TO_DOWN, [0], framerate, false);

		animation.add(TURN_DOWN_TO_LEFT, [0], framerate, false);
		animation.add(TURN_DOWN_TO_UP, [for(i in 5*row+8...6*row) i], framerate, false);
		animation.add(TURN_DOWN_TO_RIGHT, [0], framerate, false);

		animation.add(TURN_UP_TO_LEFT, [0], framerate, false);
		animation.add(TURN_UP_TO_DOWN, [for(i in 7*row+8...8*row) i], framerate, false);
		animation.add(TURN_UP_TO_RIGHT, [0], framerate, false);
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (inTransition) {
			if (animation.finished) {
				inTransition = false;
			} else {
				return;
			}
		}

		// Move the player to the next block
		if (targetValid()) {
			getPosition(temp).subtractPoint(target);
			temp.normalize();

			var travelDir = Cardinal.closest(temp, true).opposite();
			if (travelDir != lastDirection) {
				// need to play animation and wait for it to finish
				switch(lastDirection) {
					case N:
						switch(travelDir) {
							case E:
								animation.play(TURN_UP_TO_RIGHT);
							case S:
								animation.play(TURN_UP_TO_DOWN);
							case W:
								animation.play(TURN_UP_TO_LEFT);
							default:
						}
					case E:
						switch(travelDir) {
							case S:
								animation.play(TURN_RIGHT_TO_DOWN);
							case W:
								animation.play(TURN_RIGHT_TO_LEFT);
							case N:
								animation.play(TURN_RIGHT_TO_UP);
							default:
						}
					case S:
						switch(travelDir) {
							case W:
								animation.play(TURN_DOWN_TO_LEFT);
							case N:
								animation.play(TURN_DOWN_TO_UP);
							case E:
								animation.play(TURN_DOWN_TO_RIGHT);
							default:
						}
					case W:
						switch(travelDir) {
							case N:
								animation.play(TURN_LEFT_TO_UP);
								case E:
								animation.play(TURN_LEFT_TO_RIGHT);
							case S:
								animation.play(TURN_LEFT_TO_DOWN);
							default:
						}
					default:
				}

				inTransition = true;
				lastDirection = travelDir;
				trace('started ${animation.name}');
				return;
			}

			x -= temp.x * speed * delta;
			y -= temp.y * speed * delta;

			switch(lastDirection) {
				case N:
					trace("playing up");
					animation.play(WALK_UP);
				case S:
					animation.play(WALK_DOWN);
				case E:
					animation.play(WALK_RIGHT);
				case W:
					animation.play(WALK_LEFT);
				default:
			}

			// Check if the player has now reached the next block
			// TODO: This may be causing slight jitter. Not sure if it matters once animations are in place
			if (getPosition(temp).distanceTo(target) < 1) {
				setPosition(target.x, target.y);
				target.copyFrom(NO_TARGET);
				stopped = true;
			}
		} else {
			// Player isn't giving input, so lets check animation stuff
			if (stopped) {
				if (animation.name != IDLE) {
					trace("playing idle");
					animation.play(IDLE);
				}
			}
		}
	}

	public function getIntention():Cardinal {
		if (!target.equals(NO_TARGET)) {
			// still chasing our target
			return Cardinal.NONE;
		} else {
			return InputCalcuator.getInputCardinal();
		}
	}

	public function setTarget(t:FlxPoint) {
		target.copyFrom(t);
	}

	public function targetValid():Bool {
		return !target.equals(NO_TARGET);
	}

	public function follow(_moleFollowingMe) {
		moleFollowingMe = _moleFollowingMe;
	}
}
