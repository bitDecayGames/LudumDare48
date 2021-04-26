package entities;

import flixel.math.FlxPoint;
import flixel.FlxSprite;
import entities.MoleFriend;

class Moleness extends FlxSprite {
	var moleFollowingMe:MoleFriend;

	public function setFollower(newFollower:MoleFriend) {
		if (moleFollowingMe == null) {
			moleFollowingMe = newFollower;
			moleFollowingMe.follow(this);
		} else {
			moleFollowingMe.setFollower(newFollower);
		}
	}

	public function numMolesFollowingMe(numMoles:Int = 0):Int {
		if (moleFollowingMe != null) {
			return moleFollowingMe.numMolesFollowingMe(numMoles++);
		} else {
			return numMoles;
		}
	}

	public function moveFollower(target:MoleTarget) {
		// Only add to follwer target list if they are not catching up to MILF (me, I'm the milf)
		if (moleFollowingMe != null) {
			moleFollowingMe.targetList.push(target);
		}
	}
}

class MoleTarget extends FlxPoint {
	public var timeToTarget:Float;

	public function new(x:Float, y:Float, timeToTarget:Float) {
		super(x, y);
		this.timeToTarget = timeToTarget;
	}

	public static function fromPoint(p:FlxPoint, timeToTarget:Float):MoleTarget {
		return new MoleTarget(p.x, p.y, timeToTarget);
	}
}
