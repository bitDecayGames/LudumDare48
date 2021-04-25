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
		}
		else {
			moleFollowingMe.setFollower(newFollower);
		}
	}

	public function numMolesFollowingMe(numMoles:Int = 0):Int {
		if (moleFollowingMe != null) {
			return moleFollowingMe.numMolesFollowingMe(numMoles++);
		}
		else {
			return numMoles;
		}
	}

	public function moveFollower(target:FlxPoint) {
		// Only add to follwer target list if they are not catching up to MILF (me, I'm the milf)
		if (moleFollowingMe != null && !moleFollowingMe.catchUpToMILF) {
			moleFollowingMe.targetList.add(target);
		}
	}
}