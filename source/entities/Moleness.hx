package entities;

import metrics.Metrics;
import helpers.Constants;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import entities.MoleFriend;
import flixel.util.FlxColor;

class Moleness extends FlxSprite {
	private static inline var IDLE_LEFT = "idleLeft";
	private static inline var IDLE_RIGHT = "idleRight";
	private static inline var IDLE_UP = "idleUp";
	private static inline var IDLE_DOWN = "idleDown";

	private static inline var WALK_RIGHT = "walkRight";
	private static inline var WALK_LEFT = "walkLeft";
	private static inline var TURN_RIGHT_TO_LEFT = "turnRightLeft";
	private static inline var TURN_LEFT_TO_RIGHT = "turnLeftRight";

	private static inline var WALK_IN = "walkIn";
	private static inline var WALK_OUT = "walkOut";

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

	// Same frames as the walk animations for these two
	private static inline var CHOMP_IN = "walkIn";
	private static inline var CHOMP_OUT = "walkOut";

	private static inline var FALLING = "falling";

	private static inline var TAIL_LEFT = "tailLeft";
	private static inline var TAIL_RIGHT = "tailRight";
	private static inline var TAIL_UP = "tailUp";
	private static inline var TAIL_DOWN = "tailDown";

	public static inline var SLOW = "Slow";

	var framerate:Int = 10;

	var moleFollowingMe:MoleFriend;
	var moleImFollowing:Moleness;

	public var tail:FlxSprite;
	public var z:Int;

	public function initAnimations() {
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BLUE);
		updateHitbox();
		loadGraphic(AssetPaths.Player__png, true, 32, 32);
		var row = 12;

		animation.add(IDLE_RIGHT, [for (i in 0...8) i], framerate);
		animation.add(IDLE_LEFT, [for (i in 0...8) i], framerate, true, true);
		animation.add(IDLE_UP, [for (i in 9 * row + 9...10 * row) i], framerate, true, true);
		animation.add(IDLE_DOWN, [for (i in 4 * row + 9...5 * row) i], framerate, true, true);
		animation.add(WALK_RIGHT, [for (i in row...row + 8) i], framerate);
		animation.add(WALK_LEFT, [for (i in row...row + 8) i], framerate, true, true);
		animation.add(WALK_DOWN, [for (i in 5 * row...5 * row + 8) i], framerate);
		animation.add(WALK_UP, [for (i in 7 * row...7 * row + 8) i], framerate);
		animation.add(WALK_IN, [for (i in 8 * row + 8...9 * row) i], framerate);
		animation.add(WALK_OUT, [for (i in 10 * row + 5...10 * row + 9) i], framerate);
		animation.add(TURN_RIGHT_TO_UP, [row + 9, row + 10].concat([for (i in 10 * row + 1...10 * row + 5) i]), framerate * 2, false);
		animation.add(TURN_RIGHT_TO_LEFT, [for (i in row + 8...2 * row) i], framerate, false);
		animation.add(TURN_RIGHT_TO_DOWN, [row + 9, row + 10].concat([for (i in 7 * row + 9...8 * row) i]), framerate * 2, false);
		animation.add(TURN_LEFT_TO_UP, [2 * row + 9, 2 * row + 10].concat([for (i in 10 * row + 1...10 * row + 5) i]), framerate * 2, false);
		animation.add(TURN_LEFT_TO_RIGHT, [for (i in 2 * row + 8...3 * row) i], framerate, false);
		animation.add(TURN_LEFT_TO_DOWN, [2 * row + 8, 2 * row + 9].concat([for (i in 7 * row + 9...8 * row) i]), framerate * 2, false);
		animation.add(TURN_DOWN_TO_LEFT, [7 * row + 11, 7 * row + 10, row + 9, row + 10, row + 11], framerate * 2, false);
		animation.add(TURN_DOWN_TO_UP, [for (i in 5 * row + 8...6 * row) i], framerate, false);
		animation.add(TURN_DOWN_TO_RIGHT, [7 * row + 11, 7 * row + 10, 2 * row + 9, 2 * row + 10, 2 * row + 11], framerate * 2, false);
		animation.add(TURN_UP_TO_LEFT, [5 * row + 11, 5 * row + 10, row + 9, row + 10, row + 11], framerate * 2, false);
		animation.add(TURN_UP_TO_DOWN, [for (i in 7 * row + 8...8 * row) i], framerate, false);
		animation.add(TURN_UP_TO_RIGHT, [5 * row + 11, 5 * row + 10, 2 * row + 9, 2 * row + 10, 2 * row + 11], framerate * 2, false);
		animation.add(CHOMP_UP, [for (i in 8 * row...8 * row + 8) i], framerate);
		animation.add(CHOMP_DOWN, [for (i in 6 * row...6 * row + 8) i], framerate);
		animation.add(CHOMP_RIGHT, [for (i in 2 * row...2 * row + 8) i], framerate);
		animation.add(CHOMP_LEFT, [for (i in 2 * row...2 * row + 8) i], framerate, true, true);
		animation.add(FALLING, [for (i in 11 * row...11 * row + 9) i], framerate);
		tail = new FlxSprite();
		tail.loadGraphic(AssetPaths.Player__png, true, 32, 32);
		tail.animation.add(TAIL_RIGHT, [for (i in 3 * row...3 * row + 8) i], framerate);
		tail.animation.add(TAIL_RIGHT + SLOW, [for (i in 3 * row...3 * row + 8) i], framerate / 5);
		tail.animation.add(TAIL_LEFT, [for (i in 3 * row...3 * row + 8) i], framerate, true, true);
		tail.animation.add(TAIL_LEFT + SLOW, [for (i in 3 * row...3 * row + 8) i], framerate / 5, true, true);
		tail.animation.add(TAIL_UP, [for (i in 9 * row...9 * row + 8) i], framerate);
		tail.animation.add(TAIL_UP + SLOW, [for (i in 9 * row...9 * row + 8) i], framerate / 5);
		tail.animation.add(TAIL_DOWN, [for (i in 4 * row...4 * row + 8) i], framerate);
		tail.animation.add(TAIL_DOWN + SLOW, [for (i in 4 * row...4 * row + 8) i], framerate / 5);
	}

	public function setFollower(newFollower:MoleFriend, depth:Int) {
		if (newFollower.isFollowing) {
			return; // this mole is already following someone
		} else {
			if (moleFollowingMe != null) {
				moleFollowingMe.moleImFollowing = newFollower;
				newFollower.moleFollowingMe = moleFollowingMe;
			}
			moleFollowingMe = newFollower;
			newFollower.moleImFollowing = this;
			newFollower.isFollowing = true;
			newFollower.alpha = 1.0 - (newFollower.numMolesFollowingMe() * 0.3);
			newFollower.z = this.z;
			FmodManager.PlaySoundOneShot(FmodSFX.BabyMoleCollect);
		}
	}

	public function numMolesFollowingMe(numMoles:Int = 0):Int {
		if (moleFollowingMe != null) {
			return moleFollowingMe.numMolesFollowingMe(numMoles) + 1;
		} else {
			return numMoles;
		}
	}

	public function moveFollower(target:MoleTarget) {
		// Only add to follwer target list if they are not catching up to MILF (me, I'm the milf)
		if (moleFollowingMe != null) {
			moleFollowingMe.setTarget(target);
		}
	}
}

class MoleTarget extends FlxPoint {
	public var timeToTarget:Float;
	public var z:Int;

	public function new(x:Float, y:Float, timeToTarget:Float, z:Int) {
		super(x, y);
		this.timeToTarget = timeToTarget;
		this.z = z;
	}

	public static function fromPoint(p:FlxPoint, timeToTarget:Float, z:Int):MoleTarget {
		return new MoleTarget(p.x, p.y, timeToTarget, z);
	}
}
