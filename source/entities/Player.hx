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

	var TILE_SIZE = 32;

	public function new() {
		super();
		makeGraphic(32, 32, FlxColor.BLUE);

	}

	override public function update(delta:Float) {
		super.update(delta);

		// Move the player to the next block
		if (moving) {
			temp.copyFrom(target).subtractPoint(getPosition());
			temp.normalize();
			x += temp.x * speed * delta;
			y += temp.y * speed * delta;

			// Check if the player has now reached the next block
			getPosition(temp);
			if (temp.distanceTo(target) < 0.1) {
				setPosition(target.x, target.y);
				moving = false;
			}
		} else {
			moving = true;
			switch (InputCalcuator.getInputCardinal()) {
				case N:
					target.set(x, y - TILE_SIZE);
				case S:
					target.set(x, y + TILE_SIZE);
				case E:
					target.set(x + TILE_SIZE, y);
				case W:
					target.set(x - TILE_SIZE, y);
				default:
					moving = false;
			}
		}
	}
}
