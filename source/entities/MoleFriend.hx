package entities;

import spacial.Cardinal;
import flixel.math.FlxRandom;
import entities.Moleness.MoleTarget;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import helpers.Constants;
import flixel.util.FlxColor;

class MoleFriend extends Moleness {
	public var isFollowing:Bool = false;

	// Directly used for movement change
	var targetBuffer:Array<MoleTarget> = new Array<MoleTarget>();

	// movement
	var currentTime:Float = 0;
	var timeToTarget:Float = 0;

	public var shouldBeVisible:Bool = true;

	private static var rnd:FlxRandom = new FlxRandom();

	// animation
	private var lastDir:Cardinal = Cardinal.NONE;

	public function new() {
		super();
		initAnimations();
		scale.set(0.8, 0.8);
		color.setRGB(200, 200, 200);
	}

	override public function update(delta:Float) {
		super.update(delta);
		if (hasValidTarget()) {
			if (currentTime >= 0) {
				moveToTarget();
				currentTime -= delta * targetBuffer.length;
			} else {
				reachTarget();
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
		var hadCurrentTarget = hasValidTarget();
		if (hadCurrentTarget) {
			var curTarget = targetBuffer[0];
			target.original = FlxPoint.get(curTarget.x, curTarget.y); // set the next targets origin to the current target's target
		} else {
			// if there is no current target, set the original position of this target to be the current position
			target.original = getPosition();
		}
		targetBuffer.push(target);
		moveFollower(MoleTarget.fromPoint(target.original, target.timeToTarget, z, target.dir));
		if (!hadCurrentTarget) {
			acquireTarget();
		}
	}

	private function acquireTarget() {
		if (hasValidTarget()) {
			timeToTarget = targetBuffer[0].timeToTarget;
			timeToTarget *= 1.0 + 0.3 * rnd.float(-1.0, 1.0);
			currentTime = timeToTarget;
			pickMoleWalkingDir(targetBuffer[0]);
		} else {
			pickMoleIdleDir();
		}
	}

	private function pickMoleWalkingDir(target:MoleTarget) {
		var dir = Cardinal.closest(FlxVector.get(target.x - target.original.x, target.y - target.original.y));
		lastDir = dir;
		animation.play((switch (dir) {
			case Cardinal.N: Moleness.WALK_UP;
			case Cardinal.S: Moleness.WALK_DOWN;
			case Cardinal.E: Moleness.WALK_RIGHT;
			case Cardinal.W: Moleness.WALK_LEFT;
			default: Moleness.WALK_LEFT;
		}));
	}

	private function pickMoleIdleDir() {
		animation.play((switch (lastDir) {
			case Cardinal.N: Moleness.IDLE_UP;
			case Cardinal.S: Moleness.IDLE_DOWN;
			case Cardinal.E: Moleness.IDLE_RIGHT;
			case Cardinal.W: Moleness.IDLE_LEFT;
			default: Moleness.IDLE_LEFT;
		}));
	}

	private function reachTarget() {
		var target = targetBuffer.shift();
		setPosition(target.x, target.y);
		z = target.z;
		currentTime = 0;
		timeToTarget = 0;
		acquireTarget();
	}

	public function hasValidTarget():Bool {
		return targetBuffer.length > 0;
	}

	public function moveToTarget() {
		if (timeToTarget > 0) {
			var target = targetBuffer[0];
			var diff = FlxPoint.get(target.x - target.original.x, target.y - target.original.y);
			var percent = 1.0 - currentTime / timeToTarget;
			setPosition(diff.x * percent + target.original.x, diff.y * percent + target.original.y);
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
