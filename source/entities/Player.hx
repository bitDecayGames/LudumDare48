package entities;

import haxe.macro.Expr.Constant;
import flixel.math.FlxVector;
import input.SimpleController;
import flixel.math.FlxPoint;
import flixel.FlxG;
import spacial.Cardinal;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

import helpers.Constants;

using extensions.FlxPointExt;

class Player extends FlxSprite {
	var speed:Float = 30;
	var moving:Bool;

	var target:FlxPoint = FlxPoint.get();

	var temp:FlxVector = FlxVector.get();

	var moleFollowingMe:FlxSprite;

	public function new() {
		super();
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BLUE);
	}

	override public function update(delta:Float) {
		super.update(delta);

		// Move the player to the next block
		if (moving) {
			getPosition(temp).subtractPoint(target);
			temp.normalize();
			x -= temp.x * speed * delta;
			y -= temp.y * speed * delta;

			// Check if the player has now reached the next block
			// TODO: This may be causing slight jitter. Not sure if it matters once animations are in place
			if (getPosition(temp).distanceTo(target) < 0.1) {
				setPosition(target.x, target.y);
				moving = false;
			}
		} else {
			moving = true;
			if (SimpleController.pressed(Button.UP)) {
				target.set(x, y - Constants.TILE_SIZE);
			} else if (SimpleController.pressed(Button.DOWN)) {
				target.set(x, y + Constants.TILE_SIZE);
			} else if (SimpleController.pressed(Button.LEFT)) {
				target.set(x - Constants.TILE_SIZE, y);
			} else if (SimpleController.pressed(Button.RIGHT)) {
				target.set(x + Constants.TILE_SIZE, y);
			} else {
				moving = false;
			}
		}
	}

	public function follow(_moleFollowingMe)
	{
		moleFollowingMe = _moleFollowingMe;
	}
}
