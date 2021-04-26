package entities.snake;

import flixel.FlxSprite;
import levels.VoxelCalculator;
import helpers.Constants;
import flixel.tile.FlxTilemap;

using extensions.FloatExt;

class SnakeSearch {

	// in tiles
	private static var HEIGHT_BUFFER = 40;
	private static var WIDTH_BUFFER = 20;

	public var tileset:FlxTilemap;

	public function new() {
		tileset = new FlxTilemap();
		tileset.setCustomTileMappings([0, 1, 2, 0]);
	}

	// may just be able to do this every 10 player moves
	public function updateSearchSpace(snake:SnakeHead, t:FlxSprite) {
		// search space should include the snake, the player, and a sufficient buffer around the two
		var sPos = snake.getPosition();
		var pPos = t.getPosition();

		// raw world coordinates
		var xMin = Math.min(sPos.x, pPos.x);
		var xMax = Math.max(sPos.x, pPos.x);
		var yMin = Math.min(sPos.y, pPos.y);
		var yMax = Math.max(sPos.y, pPos.y);

		var xMinTile = (xMin / Constants.TILE_SIZE).floor();
		var xMaxTile = (xMax / Constants.TILE_SIZE).ceil();
		var yMinTile = (yMin / Constants.TILE_SIZE).floor();
		var yMaxTile = (yMax / Constants.TILE_SIZE).ceil();

		// Just search the whole width of our playfield
		xMinTile = -10;
		xMaxTile = 10;

		var spaceX = xMinTile - WIDTH_BUFFER;
		var spaceY = yMinTile - HEIGHT_BUFFER;
		var spaceWidth = xMaxTile-xMinTile+(2*WIDTH_BUFFER);
		var spaceHeight = yMaxTile-yMinTile+(2*HEIGHT_BUFFER);

		#if debug
		trace('search space is from (${spaceX}, ${spaceY}) size ${spaceWidth}x${spaceHeight}');
		#end

		tileset.loadMapFrom2DArray(VoxelCalculator.instance.getBlock(spaceX, spaceY, snake.z, spaceWidth, spaceHeight), AssetPaths.testTiles__png);

		// position this so it renders properly if needed
		tileset.x = (spaceX+1) * Constants.TILE_SIZE;
		tileset.y = (spaceY+1) * Constants.TILE_SIZE;

		#if debug
		trace('tileset Pos: (${tileset.x}, ${tileset.y})');
		tileset.visible = true;
		tileset.alpha = 0.5;
		#else
		tileset.visible = false;
		#end
	}
}