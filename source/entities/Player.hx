package entities;

import flixel.math.FlxVector;
import input.SimpleController;
import flixel.math.FlxPoint;
import flixel.FlxG;
import spacial.Cardinal;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using extensions.FlxPointExt;

class Player extends FlxSprite {
	var speed:Float = 30;
	var moving:Bool;

	var target:FlxPoint = FlxPoint.get();

	var temp:FlxVector = FlxVector.get();

	var TILE_SIZE:Int;

	public function new(tileSize:Int = 32) {
		super();
		TILE_SIZE = tileSize;
		makeGraphic(tileSize, tileSize, FlxColor.BLUE);
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
				target.set(x, y - TILE_SIZE);
			} else if (SimpleController.pressed(Button.DOWN)) {
				target.set(x, y + TILE_SIZE);
			} else if (SimpleController.pressed(Button.LEFT)) {
				target.set(x - TILE_SIZE, y);
			} else if (SimpleController.pressed(Button.RIGHT)) {
				target.set(x + TILE_SIZE, y);
			} else {
				moving = false;
			}
		}
	}
}
