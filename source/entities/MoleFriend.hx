package entities;

import entities.Moleness.MoleTarget;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import helpers.Constants;
import flixel.util.FlxColor;

class MoleFriend extends Moleness {
	public var isFollowing:Bool = false;

	// Directly used for movement change
	var target:MoleTarget = null;
	var original:FlxPoint = null;

	// movement
	var currentTime:Float = 0;
	var timeToTarget:Float = 0;

	public function new() {
		super();
		initAnimations();
	}

	override public function update(delta:Float) {
		super.update(delta);
		if (targetValid()) {
			if (currentTime > 0) {
				moveToTarget();
				currentTime -= delta;
				if (currentTime < 0) {
					setPosition(target.x, target.y);
					target = null;
					currentTime = 0;
					timeToTarget = 0;
				}
			}
		}
	}

	public function setTarget(target:MoleTarget) {
		if (this.target == null) {
			this.target = new MoleTarget(0, 0, 0);
		}
		this.original = getPosition();
		this.target.x = target.x;
		this.target.y = target.y;
		this.target.timeToTarget = target.timeToTarget;
		currentTime = target.timeToTarget;
		timeToTarget = target.timeToTarget;
		moveFollower(MoleTarget.fromPoint(getPosition(), target.timeToTarget));
	}

	public function targetValid():Bool {
		return target != null;
	}

	public function moveToTarget() {
		var pos = original;
		var diff = FlxPoint.get(target.x - pos.x, target.y - y);
		if (timeToTarget > 0) {
			var percent = 1.0 - currentTime / timeToTarget;
			setPosition(diff.x * percent + pos.x, diff.y * percent + pos.y);
		} else {
			trace("Failed to set time to target to valid value greater than 0");
		}
	}

	public override function destroy() {
		super.destroy();
		if (moleImFollowing != null && moleFollowingMe != null) {
			// remove yourself from the chain of following moles
			moleFollowingMe.moleImFollowing = moleImFollowing;
		}
	}
}
