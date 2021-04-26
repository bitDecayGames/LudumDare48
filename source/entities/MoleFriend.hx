package entities;

import flixel.math.FlxRandom;
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

	public var shouldBeVisible:Bool = true;

	private static var rnd:FlxRandom = new FlxRandom();

	public function new() {
		super();
		initAnimations();
	}

	override public function update(delta:Float) {
		super.update(delta);
		if (targetValid()) {
			if (currentTime >= 0) {
				moveToTarget();
				currentTime -= delta;
			} else {
				setPosition(target.x, target.y);
				z = target.z;
				target = null;
				currentTime = 0;
				timeToTarget = 0;
			}
		}

		if (shouldBeVisible) {
			alpha += delta * 2;
			if (alpha > 1.0) {
				alpha = 1.0;
			}
		} else {
			alpha -= delta * 2;
			if (alpha < 0.0) {
				alpha = 0.0;
			}
		}
	}

	public function setTarget(target:MoleTarget) {
		var curZ = z;
		if (this.target == null) {
			this.target = new MoleTarget(0, 0, 0, 0);
		} else {
			z = target.z;
		}
		this.original = getPosition();
		this.target.x = target.x;
		this.target.y = target.y;
		this.target.timeToTarget = target.timeToTarget;
		this.target.z = target.z;
		currentTime = target.timeToTarget;
		timeToTarget = target.timeToTarget;
		timeToTarget *= 1.0 + 0.3 * rnd.float(-1.0, 1.0);
		moveFollower(MoleTarget.fromPoint(getPosition(), target.timeToTarget, curZ));
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
