package entities;

import flixel.addons.ui.FlxUI.Rounding;
import input.InputCalcuator;
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

class Player extends Moleness {
	var speed:Float = 240;

	var target:FlxPoint = FlxPoint.get().copyFrom(Constants.NO_TARGET);

	var temp:FlxVector = FlxVector.get();

	var molesFollowingMe:Int;

	public function new() {
		super();
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BLUE);
		updateHitbox();
	}

	override public function update(delta:Float) {
		super.update(delta);

		molesFollowingMe = numMolesFollowingMe();

		// Move the player to the next block
		if (targetValid()) {
			getPosition(temp).subtractPoint(target);
			temp.normalize();
			x -= temp.x * speed * delta;
			y -= temp.y * speed * delta;

			// Check if the player has now reached the next block
			// TODO: This may be causing slight jitter. Not sure if it matters once animations are in place
			if (getPosition(temp).distanceTo(target) < 1) {
				setPosition(Math.round(target.x), Math.round(target.y));
				target.copyFrom(Constants.NO_TARGET);
			}
		}
	}

	public function getIntention():Cardinal {
		if (!target.equals(Constants.NO_TARGET)) {
			// still chasing our target
			return Cardinal.NONE;
		} else {
			return InputCalcuator.getInputCardinal();
		}
	}

	public function getDepthIntention():Int {
		return InputCalcuator.getDepthInput();
	}

	public function setTarget(t:FlxPoint) {
		target.copyFrom(t);
	}

	public function targetValid():Bool {
		return !target.equals(Constants.NO_TARGET);
	}
}
