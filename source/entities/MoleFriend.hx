package entities;

import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import helpers.Constants;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class MoleFriend extends Moleness {
	var speed:Float = 45;

	public var moleIdLikeToFollow:Moleness = null;

	var maxDistanceFromMILF:Float = 32;

	var catchUpToMILF:Bool = true;

	// Directly used for movement change
	var currentPosition:FlxPoint = FlxPoint.get();
	var milfPosition:FlxPoint = FlxPoint.get();
	var moveVector:FlxVector = FlxVector.get();
	var target:FlxPoint = FlxPoint.get();
	var normalTarget:FlxVector = FlxVector.get();

	var targetList:List<FlxPoint> = new List<FlxPoint>();

	// deubg
	var currentTime:Float = 0;

	public function new() {
		super();
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BROWN);

		target.copyFrom(Constants.NO_TARGET);
	}

	override public function update(delta:Float) {
		super.update(delta);

		currentTime += delta;


		// Always know where your position is
		getPosition(currentPosition);

		if (moleIdLikeToFollow != null) {
			// Always know where your milf's position is
			moleIdLikeToFollow.getPosition(milfPosition);

			// if (currentTime > 1) {
			// 	currentTime = 0;

			// 	trace('my position: (${currentPosition.x},${currentPosition.y})');
			// 	trace('MILFs posit: (${milfPosition.x},${milfPosition.y})');
			// }
			
			if (targetValid()) {
				moveToTarget(delta);

				if (currentPosition.distanceTo(target) < 1) {
					setPosition(target.x, target.y);
					target.copyFrom(Constants.NO_TARGET);
				}
			}
			// First time movement must catch up to MILF. Stop using this logic when close to milf.
			else if (catchUpToMILF) {
				if (tooFarFromMILF()) {
					moveVector.copyFrom(currentPosition).subtractPoint(milfPosition);
					moveVector.normalize();

					if (Math.abs(moveVector.x) > Math.abs(moveVector.y)) {
						if (moveVector.x > 0) {
							target.set(x - Constants.TILE_SIZE, y);
						}
						else {
							target.set(x + Constants.TILE_SIZE, y);
						}
					}
					else {
						if (moveVector.y > 0) {
							target.set(x, y - Constants.TILE_SIZE);
						}
						else {
							target.set(x, y + Constants.TILE_SIZE);
						}
					}
				}
				else {
					catchUpToMILF = true;
				}
			}
			// After caught up to milf then movement is based off next available target given from milf.
			// else if (targetAvailable()) {
			// 	target.copyFrom(targetList.pop());

			// 	moveFollower(currentPosition);
			// }
		}
	}

	public function tooFarFromMILF():Bool {
		var distanceToMILF:Float = currentPosition.distanceTo(milfPosition);
		return distanceToMILF > maxDistanceFromMILF;
	}

	public function targetValid():Bool {
		return !target.equals(Constants.NO_TARGET);
	}

	public function targetAvailable():Bool {
		clearCloseTargets();
		return targetList.length > 0;
	}

	public function clearCloseTargets() {
		if (targetList.first() != null && targetList.first().distanceTo(currentPosition) <= maxDistanceFromMILF) {
			targetList.pop();
			clearCloseTargets();
		}
	}

	public function moveToTarget(delta:Float) {
		normalTarget.copyFrom(currentPosition).subtractPoint(target).normalize();
		x -= normalTarget.x * speed * delta;
		y -= normalTarget.y * speed * delta;
	}

	public function moveFollower(target:FlxPoint) {
		// Only add to follwer target list if they are not catching up to MILF (me, I'm the milf)
		if (moleFollowingMe != null && !moleFollowingMe.catchUpToMILF) {
			moleFollowingMe.targetList.add(target);
		}
	}

	public function follow(_moleIdLikeToFollow:Moleness) {
		moleIdLikeToFollow = _moleIdLikeToFollow;
	}
}