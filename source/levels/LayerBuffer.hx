package levels;

import spacial.Cardinal;
import flixel.tile.FlxTilemap;

class LayerBuffer extends FlxTilemap {
	public var tilemap:FlxTilemap;

	// the world x of the top-left corner of the buffer
	public var worldX:Int;

	// the world y of the top-left corner of the buffer
	public var worldY:Int;

	// the world z of the buffer
	public var worldZ:Int;

	public var bufWidth:Int;
	public var bufHeight:Int;

	// NOTE: This array is indexed as [y][x] due to how FlxTilemap loads them
	var local:Array<Array<Int>> = new Array<Array<Int>>();

	/**
	 * @param width	main buffer width
	 * @param height main buffer height
	 * @param padding number of cells on each side as padding
	**/
	public function new(width:Int, height:Int, padding:Int) {
		super();
		bufWidth = width + 2 * padding;
		bufHeight = height + 2 * padding;

		// we added padding, so the world coords of our top left need to take padding into account
		worldX = -padding;
		worldY = -padding;

		local = [for (i in 0...bufHeight) [for (k in 0...bufWidth) 1]];
		tilemap = new FlxTilemap();
		trace('width: ${local.length}   height: ${local[0].length}');
		reload();

		tilemap.x = -32;
		tilemap.y = -32;
	}

	public override function setTile(X:Int, Y:Int, Tile:Int, UpdateGraphics:Bool = true):Bool {
		local[Y][X] = Tile;
		return super.setTile(X, Y, Tile, UpdateGraphics);
	}

	public function pushData(dir:Cardinal, data:Array<Int>) {
		switch (dir) {
			case N:
				pushOntoTop(data);
			case S:
				pushOntoBottom(data);
			case E:
				pushOntoRight(data);
			case W:
				pushOntoLeft(data);
			default:
				throw('cannot request level data for direction ${dir}');
		}
	}

	public function pushOntoLeft(column:Array<Int>) {
		worldX--;
		for (i in 0...local.length) {
			local[i].pop();
			local[i].unshift(column[i]);
		}
		reload();
	}

	public function pushOntoRight(column:Array<Int>) {
		worldX++;
		for (i in 0...local.length) {
			local[i].shift();
			local[i].push(column[i]);
		}
		reload();
	}

	public function pushOntoTop(row:Array<Int>) {
		worldY--;
		local.pop();
		local.unshift(row);
		reload();
	}

	public function pushOntoBottom(row:Array<Int>) {
		worldY++;
		local.shift();
		local.push(row);
		reload();
	}

	public function reload() {
		loadMapFrom2DArray(local, AssetPaths.testTiles__png, 32, 32);
	}

	public function dump() {
		trace(local);
	}
}
