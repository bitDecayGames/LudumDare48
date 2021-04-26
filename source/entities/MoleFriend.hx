package entities;

import entities.Moleness.MoleTarget;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import helpers.Constants;
import flixel.util.FlxColor;

class MoleFriend extends Moleness {
	public var moleIdLikeToFollow:Moleness = null;
	public var targetList:Array<MoleTarget> = new Array<MoleTarget>();

	// Directly used for movement change
	var target:MoleTarget = null;

	// movement
	var currentTime:Float = 0;
	var timeToTarget:Float = 0;

	public function new() {
		super();
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BROWN);
	}

	override public function update(delta:Float) {
		super.update(delta);
		if (targetValid()) {
			if (currentTime > 0) {
				moveToTarget();
				currentTime -= delta;
				if (currentTime < 0) {
					setPosition(target.x, target.y);
					target.copyFrom(Constants.NO_TARGET);
					currentTime = 0;
				}
			}
		} else if (targetAvailable()) {
			acquireTarget();
		}
	}

	public function acquireTarget():Bool {
		if (targetAvailable()) {
			if (target == null) {
				target = new MoleTarget(0, 0, 0);
			}
			var newTarget = targetList.pop();
			target.x = newTarget.x;
			target.y = newTarget.y;
			target.timeToTarget = newTarget.timeToTarget;
			currentTime = target.timeToTarget;
			moveFollower(MoleTarget.fromPoint(getPosition(), target.timeToTarget));
			return true;
		}
		return false;
	}

	public function targetValid():Bool {
		return target != null;
	}

	public function targetAvailable():Bool {
		return targetList.length > 0;
	}

	public function moveToTarget() {
		var pos = getPosition();
		var diff = FlxPoint.get(target.x - pos.x, target.y - y);
		if (timeToTarget > 0) {
			var percent = currentTime / timeToTarget;
			setPosition(diff.x * percent + pos.x, diff.y * percent + pos.y);
		} else {
			trace("Failed to set time to target to valid value greater than 0");
		}
	}

	public function follow(_moleIdLikeToFollow:Moleness) {
		moleIdLikeToFollow = _moleIdLikeToFollow;
	}
}
