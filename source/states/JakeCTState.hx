package states;

import helpers.Constants;
import flixel.math.FlxPoint;
import flixel.util.FlxPath;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.math.FlxVector;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import entities.snake.Snake;

using extensions.FlxStateExt;

class JakeCTState extends FlxTransitionableState {
	var snake:Snake;

	var map:FlxTilemap;
	var boi:FlxSprite;
	var goal:FlxSprite;

	/// 14 X 22

	override public function create() {
		super.create();

		FlxG.debugger.visible = true;

		// FlxG.camera.bgColor = FlxColor.WHITE;
		FlxG.camera.pixelPerfectRender = true;

		// var snakeStart = FlxVector.get(0, FlxG.height / 2);
		// snake = new Snake(snakeStart);
		// add(snake);

		map = new FlxTilemap();
		map.loadMapFromCSV(AssetPaths.pathfinding_map__txt, AssetPaths.snake_tiles__png, Constants.TILE_SIZE, Constants.TILE_SIZE, 0, 1);
		add(map);

		goal = new FlxSprite();
		goal.makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, 0xffffff00);
		goal.x = map.width - Constants.TILE_SIZE;
		goal.y = map.height - Constants.TILE_SIZE;
		add(goal);

		boi = new FlxSprite(0, 0);
		boi.makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, 0xffff0000);
		boi.path = new FlxPath();
		add(boi);

		var pathPoints:Array<FlxPoint> = map.findPath(
			FlxPoint.get(boi.x + boi.width / 2, boi.y + boi.height / 2),
			FlxPoint.get(goal.x + goal.width / 2, goal.y + goal.height / 2)
		);

		if (pathPoints == null) {
			trace("unable to find path");
			return;
		}

		boi.path.start(pathPoints);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.collide(boi, map);

		if (boi.path.finished) {
			boi.path.cancel();
		}
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}


	override public function draw():Void
	{
		super.draw();

		if (!boi.path.finished)
		{
			boi.drawDebug();
		}
	}
}
