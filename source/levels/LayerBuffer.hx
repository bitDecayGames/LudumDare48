package levels;

import flixel.util.FlxColor;
import spacial.Cardinal;
import flixel.tile.FlxTilemap;
import helpers.TileType;

using Math;

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

	public var targetScale:Float = 1.0;
	public var targetTint:Float = 1.0;
	public var targetAlpha:Float = 1.0;
	public var secondsToTarget:Float = 1.25;

	private var originalScale:Float = 1.0;
	private var originalTint:Float = 1.0;
	private var originalAlpha:Float = 1.0;

	private var curSeconds:Float = 0.0;

	// NOTE: This array is indexed as [y][x] due to how FlxTilemap loads them
	var local:Array<Array<Int>> = new Array<Array<Int>>();

	public var calculator:VoxelCalculator;
	/**
	 * @param width	main buffer width
	 * @param height main buffer height
	 * @param padding number of cells on each side as padding
	**/
	public function new(width:Int, height:Int, padding:Int, calc:VoxelCalculator) {
		super();
		calculator = calc;
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

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (curSeconds > 0) {
			var percent = 1.0 - (curSeconds / secondsToTarget);

			var newScale = ((targetScale - originalScale) * percent) + originalScale;
			scale.set(newScale, newScale);

			var newTint = ((((targetTint - originalTint) * percent) + originalTint) * 255).floor();
			color = FlxColor.fromRGB(newTint, newTint, newTint);

			var newAlpha = ((targetAlpha - originalAlpha) * percent) + originalAlpha;
			alpha = newAlpha;

			curSeconds -= elapsed;

			if (curSeconds <= 0) {
				setCurrent(targetScale, targetTint, targetAlpha);
			}
		}
	}

	public function setCurrent(scale:Float, tint:Float, alpha:Float) {
		this.scale.set(scale, scale);
		var targetTint255 = (tint * 255).floor();
		color = FlxColor.fromRGB(targetTint255, targetTint255, targetTint255);
		this.alpha = alpha;
	}

	public function setTarget(scale:Float, tint:Float, alpha:Float) {
		this.targetScale = scale;
		this.originalScale = this.scale.x;
		this.targetTint = tint;
		this.originalTint = this.color.blue / 255.0;
		this.targetAlpha = alpha;
		this.originalAlpha = this.alpha;
		this.curSeconds = this.secondsToTarget;
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

	public function tileIsType(X:Int, Y:Int, tileType:TileType):Bool {
		return calculator.get(worldX + X, worldY + Y, worldZ) == tileType;
	}

	public function tileToPaintWithTerrain(X:Int, Y:Int, Tile:Int):Int {
		// See: https://web.archive.org/web/20100823062711/http://www.saltgames.com/?p=184
	
		var TILE_SHEET_WIDTH = 16;
		
		if (Tile == TileType.DIRT) {
			// reglar dirt is always just dirt
			return 1;
		}

		var tileIndex = 0;

		// Use the correct row of the tile sheet for this TileType
		if (Tile == TileType.EMPTY_SPACE) {
			tileIndex += TILE_SHEET_WIDTH * 1;
		}

		if (Tile == TileType.DUG_DIRT) {
			tileIndex += TILE_SHEET_WIDTH * 2;
		}

		if (Tile == TileType.ROCK) {
			tileIndex += TILE_SHEET_WIDTH * 3;
		}
		
		// Now, use the correct style on that row based on the type of the surrounding tiles
		if (tileIsType(X, Y - 1, Tile)) tileIndex += 1;
		if (tileIsType(X + 1, Y, Tile)) tileIndex += 2;
		if (tileIsType(X, Y + 1, Tile)) tileIndex += 4;
		if (tileIsType(X - 1, Y, Tile)) tileIndex += 8;
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
		loadMapFrom2DArray(localWithTerrain(), AssetPaths.tiles2__png, 32, 32);
	}

	public function localWithTerrain():Array<Array<Int>> {
		return [for (i in 0...bufHeight) [for (k in 0...bufWidth) tileToPaintWithTerrain(i, k, local[i][k])]];
	}

	public function dump() {
		trace(local);
	}
}
