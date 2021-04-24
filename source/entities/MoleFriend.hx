package entities;

import helpers.Constants;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class MoleFriend extends FlxSprite {
	var speed:Float = 30;
	var moleImFollowing:FlxSprite;
	var moleFollowingMe:FlxSprite;

	public function new(_moleImFollowing:FlxSprite) {
		super();
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BROWN);
		x = Constants.TILE_SIZE * 3;
		y = Constants.TILE_SIZE * 3;

		moleImFollowing = _moleImFollowing;
	}

	override public function update(delta:Float) {
		super.update(delta);

	// if MoleImFollowing is more than 1 tile away move toward MoleImFollowing

	}

	public function follow(_moleFollowingMe)
	{
		moleFollowingMe = _moleFollowingMe;
	}
}
