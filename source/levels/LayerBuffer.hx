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

	public var calculator:VoxelCalculator;
	/**
	 * @param width	main buffer width
	 * @param height main buffer height
	 * @param padding number of cells on each side as padding
	**/
	public function new(width:Int, height:Int, padding:Int) {
		super();
		calculator = new VoxelCalculator();
		
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

		return super.setTile(X, Y, tileToPaintWithTerrain(X, Y, Tile), UpdateGraphics);
	}

	public function tileToPaintSimple(X:Int, Y:Int, Tile:Int):Int {
		// simple:
		switch(Tile) {
			case 0:
				return 1;
			case 1:
				return 17;
			case 2:
				return 18;
			default:
				return 0;
		}
	}

	public function tileIsDirt(X:Int, Y:Int):Bool {
		// Assume anywhere off the map is dirt
		if (X < 0 || Y < 0) {
			return true;
		}
		return calculator.get(worldX + X, worldY + Y, worldZ) == 1;
	}

	public function tileToPaintWithTerrain(X:Int, Y:Int, Tile:Int):Int {
		// See: https://web.archive.org/web/20100823062711/http://www.saltgames.com/?p=184

		// This algorithm assumes 0-based indexs, but our tile sheet uses 1-based indexes, so that we can use our own fully empty tile
		// otherwise, FlxTileMap (or something) decides we need to just paint a black square
		var offset = 1;	
		if (Tile == 2) {
			// the first 16 tiles are combinations of dirt and empty space. The last tile is the rock.
			return 17 + offset;
		}
	
	
		// if the current tile is dirt, just return dirt, 
		if (Tile == 1) {
			return 16 + offset;
		}

		// this tile is empty space, let's make it *fancy*
		var tileIndex = 0;
		// Check the tile above if it is dirt, add 1
		if (tileIsDirt(X, Y - 1)) tileIndex += 1;

		// Check the tile to the right if it is dirt, add 2
		if (tileIsDirt(X + 1, Y)) tileIndex += 2;

		// Check the tile below if it is dirt, add 4
		if (tileIsDirt(X, Y + 1)) tileIndex += 4;

		// Check the tile to the left if it is dirt, add 8
		if (tileIsDirt(X - 1, Y)) tileIndex += 8;

		tileIndex += offset;

		if (tileIndex > 17) {
			return 17;
		}
		return tileIndex;
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
		loadMapFrom2DArray(local, AssetPaths.dirtWithEdgesBitwise_v2__png, 32, 32);
	}

	public function dump() {
		trace(local);
	}
}
