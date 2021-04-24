package entities;

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
	var speed:Float = 60;
	var moving:Bool;

	private static var NO_TARGET = FlxPoint.get(-999, -999);
	var target:FlxPoint = FlxPoint.get();

	var temp:FlxVector = FlxVector.get();

	var moleFollowingMe:FlxSprite;

	public function new() {
		super();
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BLUE);
		updateHitbox();
	}

	override public function update(delta:Float) {
		super.update(delta);

		// Move the player to the next block
		if (targetValid()) {
			getPosition(temp).subtractPoint(target);
			temp.normalize();
			x -= temp.x * speed * delta;
			y -= temp.y * speed * delta;

			// Check if the player has now reached the next block
			// TODO: This may be causing slight jitter. Not sure if it matters once animations are in place
			if (getPosition(temp).distanceTo(target) < 1) {
				setPosition(target.x, target.y);
				target.copyFrom(NO_TARGET);
			}
		}
	}

	var intent = FlxPoint.get();
	public function getIntention():FlxPoint {
		if (!target.equals(NO_TARGET)) {
			// still chasing our target
			intent.copyFrom(target);
		} else {
			if (SimpleController.pressed(Button.UP)) {
				intent.set(x, y - Constants.TILE_SIZE);
			} else if (SimpleController.pressed(Button.DOWN)) {
				intent.set(x, y + Constants.TILE_SIZE);
			} else if (SimpleController.pressed(Button.LEFT)) {
				intent.set(x - Constants.TILE_SIZE, y);
			} else if (SimpleController.pressed(Button.RIGHT)) {
				intent.set(x + Constants.TILE_SIZE, y);
			}
		}
		return intent;
	}

	public function setTarget(t:FlxPoint) {
		target.copyFrom(t);
	}

	public function targetValid():Bool {
		return !target.equals(NO_TARGET);
	}

	public function follow(_moleFollowingMe)
	{
		moleFollowingMe = _moleFollowingMe;
	}
}
