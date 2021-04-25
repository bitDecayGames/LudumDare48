package entities;

import flixel.FlxSprite;
import zero.extensions.StringExt;
import helpers.TileType;
import input.InputCalcuator;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import spacial.Cardinal;
import flixel.util.FlxColor;
import helpers.Constants;

using extensions.FlxPointExt;
using zero.extensions.StringExt;

class Player extends Moleness {
	private static inline var IDLE_LEFT = "idleLeft";
	private static inline var IDLE_RIGHT = "idleRight";
	private static inline var IDLE_UP = "idleUp";
	private static inline var IDLE_DOWN = "idleDown";

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

	private static inline var CHOMP_UP = "chompUp";
	private static inline var CHOMP_DOWN = "chompDown";
	private static inline var CHOMP_LEFT = "chompLeft";
	private static inline var CHOMP_RIGHT = "chompRight";

	private static inline var TAIL_LEFT = "tailLeft";
	private static inline var TAIL_RIGHT = "tailRight";
	private static inline var TAIL_UP = "tailUp";
	private static inline var TAIL_DOWN = "tailDown";

	var speed:Float = 60;
	var framerate:Int = 10;
	var moving:Bool = false;

	public var target:FlxPoint = FlxPoint.get().copyFrom(Constants.NO_TARGET);
	var targetType:TileType = EMPTY_SPACE;

	var temp:FlxVector = FlxVector.get();

	var stopped:Bool = true;
	var lastDirection:Cardinal = NONE;
	var inTransition:Bool = false;

	var molesFollowingMe:Int = 0;

	public var tail:FlxSprite;

	public function new() {
		super();
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BLUE);
		updateHitbox();

		loadGraphic(AssetPaths.Player__png, true, 32, 32);
		var row = 12;
		animation.add(IDLE_RIGHT, [for(i in 0...8) i], framerate);
		animation.add(IDLE_LEFT, [for(i in 0...8) i], framerate, true, true);
		animation.add(IDLE_UP, [7*row], framerate, true, true);
		animation.add(IDLE_DOWN, [5*row], framerate, true, true);

		animation.add(WALK_RIGHT, [for(i in row...row+8) i], framerate);
		animation.add(WALK_LEFT, [for(i in row...row+8) i], framerate, true, true);
		animation.add(WALK_DOWN, [for(i in 5*row...5*row+8) i], framerate);
		animation.add(WALK_UP, [for(i in 7*row...7*row+8) i], framerate);

		animation.add(TURN_RIGHT_TO_UP, [row+9, row+10].concat([for(i in 10*row+1...10*row+5) i]), framerate * 2, false);
		animation.add(TURN_RIGHT_TO_LEFT, [for(i in row+8...2*row) i], framerate, false);
		animation.add(TURN_RIGHT_TO_DOWN, [row+9, row+10].concat([for(i in 7*row+9...8*row) i]), framerate * 2, false);

		animation.add(TURN_LEFT_TO_UP, [2*row+9, 2*row+10].concat([for(i in 10*row+1...10*row+5) i]), framerate * 2, false);
		animation.add(TURN_LEFT_TO_RIGHT, [for(i in 2*row+8...3*row) i], framerate, false);
		animation.add(TURN_LEFT_TO_DOWN, [2*row+8, 2*row+9].concat([for(i in 7*row+9...8*row) i]), framerate * 2, false);

		animation.add(TURN_DOWN_TO_LEFT, [7*row+11, 7*row+10, row+9, row+10, row+11], framerate * 2, false);
		animation.add(TURN_DOWN_TO_UP, [for(i in 5*row+8...6*row) i], framerate, false);
		animation.add(TURN_DOWN_TO_RIGHT, [7*row+11, 7*row+10, 2*row+9, 2*row+10, 2*row+11], framerate * 2, false);

		animation.add(TURN_UP_TO_LEFT, [5*row+11, 5*row+10,row+9, row+10, row+11], framerate * 2, false);
		animation.add(TURN_UP_TO_DOWN, [for(i in 7*row+8...8*row) i], framerate, false);
		animation.add(TURN_UP_TO_RIGHT, [5*row+11, 5*row+10, 2*row+9, 2*row+10, 2*row+11], framerate * 2, false);

		animation.add(CHOMP_UP, [for(i in 8*row...8*row+8) i], framerate);
		animation.add(CHOMP_DOWN, [for(i in 6*row...6*row+8) i], framerate);
		animation.add(CHOMP_RIGHT, [for(i in 2*row...2*row+8) i], framerate);
		animation.add(CHOMP_LEFT, [for(i in 2*row...2*row+8) i], framerate, true, true);

		tail = new FlxSprite();
		tail.loadGraphic(AssetPaths.Player__png, true, 32, 32);
		tail.animation.add(TAIL_RIGHT, [for(i in 3*row...3*row+8) i], framerate);
		tail.animation.add(TAIL_LEFT, [for(i in 3*row...3*row+8) i], framerate, true, true);
		tail.animation.add(TAIL_UP, [for(i in 9*row...9*row+8) i], framerate);
		tail.animation.add(TAIL_DOWN, [for(i in 4*row...4*row+8) i], framerate);
	}

	override public function update(delta:Float) {
		super.update(delta);

		updateTail(delta);

		if (inTransition) {
			if (animation.finished) {
				inTransition = false;
			} else {
				return;
			}
		}

		molesFollowingMe = numMolesFollowingMe();

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
				return;
			}

			var moveSpeed = speed;
			if (targetType == DIRT) {
				moveSpeed *= 0.7;
			}

			x -= temp.x * moveSpeed * delta;
			y -= temp.y * moveSpeed * delta;

			switch(lastDirection) {
				case N:
					animation.play(targetType == DIRT ? CHOMP_UP : WALK_UP);
				case S:
					animation.play(targetType == DIRT ? CHOMP_DOWN : WALK_DOWN);
				case E:
					animation.play(targetType == DIRT ? CHOMP_RIGHT : WALK_RIGHT);
				case W:
					animation.play(targetType == DIRT ? CHOMP_LEFT : WALK_LEFT);
				default:
			}

			// Check if the player has now reached the next block
			// TODO: This may be causing slight jitter. Not sure if it matters once animations are in place
			if (getPosition(temp).distanceTo(target) < 1) {
				setPosition(Math.round(target.x), Math.round(target.y));
				target.copyFrom(Constants.NO_TARGET);
				stopped = true;
			}
		} else {
			// Player isn't giving input, so lets check animation stuff
			if (stopped) {
				if (!StringExt.contains(animation.name, "idle")) {
					switch(lastDirection) {
						case N:
							animation.play(IDLE_UP);
						case S:
							animation.play(IDLE_DOWN);
						case E:
							animation.play(IDLE_RIGHT);
						case W:
							animation.play(IDLE_LEFT);
						default:
					}
				}
			}
		}
	}

	private function updateTail(delta:Float) {
		tail.update(delta);

		if (animation.name != null && animation.name.contains("turn")) {
			tail.visible = false;
			return;
		}

		tail.visible = true;

		// Using 32, there are tiny gaps between rat and tail
		var tailOffsets = [
			N => FlxPoint.get(0,31),
			S => FlxPoint.get(0,-31),
			E => FlxPoint.get(-31,0),
			W => FlxPoint.get(31,0),
			NONE => FlxPoint.get(0,0),
		];

		switch(lastDirection) {
			case N:
				tail.animation.play(TAIL_UP);
			case S:
				tail.animation.play(TAIL_DOWN);
			case E:
				tail.animation.play(TAIL_RIGHT);
			case W:
				tail.animation.play(TAIL_LEFT);
			default:
		}

		tail.x = x + tailOffsets.get(lastDirection).x;
		tail.y = y + tailOffsets.get(lastDirection).y;
	}

	public function getIntention():Cardinal {
		if (hasTarget()) {
			// still chasing our target
			return Cardinal.NONE;
		} else {
			return InputCalcuator.getInputCardinal();
		}
	}

	public function hasTarget():Bool {
		return !target.equals(Constants.NO_TARGET);
	}

	public function getDepthIntention():Int {
		if (hasTarget()) {
			return 0;
		}
		return InputCalcuator.getDepthInput();
	}

	public function setTarget(t:MoveResult) {
		target.copyFrom(t.target);
		targetType = t.moveIntoType;
		moveFollower(new FlxPoint(x, y));
	}

	public function targetValid():Bool {
		return !target.equals(Constants.NO_TARGET);
	}
}
