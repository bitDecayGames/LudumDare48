package entities.snake;

import spacial.Cardinal;
import flixel.FlxSprite;

class NewSegment extends FlxSprite {
	public static var row = 10;

	public static inline var framerate = 15;

	// simple map of what directions the segment touches
	public static var frameData = [
		"lr" => [for (i in 0...4) i],
		"ud" => [for (i in row...row+4) i],
		"rr" => [for (i in 2*row...2*row+4) i],
		"dd" => [for (i in 3*row...3*row+4) i],
		"dr" => [for (i in 4*row...4*row+4) i],
		"dl" => [for (i in 5*row...5*row+4) i],
		"ur" => [for (i in 6*row...6*row+4) i],
		"ul" => [for (i in 7*row...7*row+4) i],
	];

	// simple map of inDir->outDir of snake
	public static var animData = [
		"ll" => new AnimData("lr", true),
		"rr" => new AnimData("lr", false),
		"uu" => new AnimData("ud", true),
		"dd" => new AnimData("ud", false),
		"lr" => new AnimData("rr", false),
		"rl" => new AnimData("rr", false, true),
		"ud" => new AnimData("dd", false),
		"du" => new AnimData("dd", false, false, true),
		"ur" => new AnimData("dr", false),
		"ld" => new AnimData("dr", true),
		"ul" => new AnimData("dl", true),
		"rd" => new AnimData("dl", false),
		"dr" => new AnimData("ur", false),
		"lu" => new AnimData("ur", true),
		"dl" => new AnimData("ul", true),
		"ru" => new AnimData("ul", false),
	];
	public function new(x:Float, y:Float, inDir:Cardinal, outDir:Cardinal) {
		super(x, y);
		loadGraphic(AssetPaths.snakeSprites__png, true, 32, 32);
		var data = animData.get(inDir.asLetter() + outDir.asLetter());
		animation.add("frames", frameData.get(data.key), framerate, true, data.flipX, data.flipY);
		animation.play("frames", false, data.reverse);

		immovable = true;
	}
}

class AnimData {
	public var key = "";
	public var reverse = false;
	public var flipX = false;
	public var flipY = false;

	public function new(k:String, r:Bool, flipX:Bool=false, flipY:Bool=false) {
		key = k;
		reverse = r;
		this.flipX = flipX;
		this.flipY = flipY;
	}
}