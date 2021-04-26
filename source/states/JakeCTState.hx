package states;

import helpers.Constants;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.math.FlxVector;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import entities.snake.Snake;

using extensions.FlxStateExt;

class JakeCTState extends FlxTransitionableState {
	var map:FlxTilemap;
	var goal:FlxSprite;

	var snake:Snake;

	override public function create() {
		super.create();

		FlxG.camera.pixelPerfectRender = true;

		// FlxG.debugger.visible = true;
		// FlxG.camera.bgColor = FlxColor.WHITE;

		map = new FlxTilemap();
		map.loadMapFromCSV(AssetPaths.pathfinding_map__txt, AssetPaths.snake_tiles__png, Constants.TILE_SIZE, Constants.TILE_SIZE, 0, 1);
		add(map);

		var snakeStart = FlxVector.get(0, 0);
		snake = new Snake(snakeStart);
		add(snake);

		goal = new FlxSprite();
		goal.makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, 0xffffff00);
		goal.x = map.width - Constants.TILE_SIZE;
		goal.y = map.height - Constants.TILE_SIZE;
		add(goal);

		// snake.setMap(map);
		// snake.setTarget(goal);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
