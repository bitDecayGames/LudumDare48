package levels;

import flixel.util.FlxColor;
import spacial.Cardinal;
import flixel.tile.FlxTilemap;
import helpers.TileType;
import flixel.math.FlxPoint;
import helpers.Constants;

using Math;

class LayerBuffer extends FlxTilemap {
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
	public var secondsToTarget:Float = 0.5;
	public var onReachedTarget:Void->Void;

	var originalScale:Float = 1.0;
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
	public function new(worldXTile:Int, worldYTile:Int, width:Int, height:Int, padding:Int, calc:VoxelCalculator) {
		super();
		calculator = calc;
		bufWidth = width + 2 * padding;
		bufHeight = height + 2 * padding;

		// we added padding, so the world coords of our top left need to take padding into account
		worldX = worldXTile - padding;
		worldY = worldYTile - padding;

		local = [for (i in 0...bufHeight) [for (k in 0...bufWidth) 1]];
		trace('width: ${local.length}   height: ${local[0].length}');

		loadMapFrom2DArray(localWithTerrain(), AssetPaths.tiles2__png, 32, 32);
		reload();
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
				if (onReachedTarget != null) {
					onReachedTarget();
					onReachedTarget = null;
				}
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

	public function tileIsType(X:Int, Y:Int, tileType:TileType):Bool {
		return calculator.get(worldX + X, worldY + Y, worldZ) == tileType;
	}

	public function tileIsAnyType(x:Int, y:Int, tileTypes:Array<Int>):Bool {
		for (tileType in tileTypes) {
			if (tileIsType(x, y, tileType))
				return true;
		}
		return false;
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
		if (Tile == TileType.EMPTY_SPACE)
			tileIndex += TILE_SHEET_WIDTH * 1;
		if (Tile == TileType.DUG_DIRT)
			tileIndex += TILE_SHEET_WIDTH * 2;
		if (Tile == TileType.ROCK)
			tileIndex += TILE_SHEET_WIDTH * 3;

		// figure out what tile types to compare against
		var tileTypesToCheck = new Array<Int>();
		if (Tile == TileType.EMPTY_SPACE || Tile == TileType.DUG_DIRT) {
			tileTypesToCheck.push(TileType.EMPTY_SPACE);
			tileTypesToCheck.push(TileType.DUG_DIRT);
		} else {
			tileTypesToCheck.push(Tile);
		}

		// Now, use the correct style on that row based on the type of the surrounding tiles
		if (tileIsAnyType(X, Y - 1, tileTypesToCheck))
			tileIndex += 1;
		if (tileIsAnyType(X + 1, Y, tileTypesToCheck))
			tileIndex += 2;
		if (tileIsAnyType(X, Y + 1, tileTypesToCheck))
			tileIndex += 4;
		if (tileIsAnyType(X - 1, Y, tileTypesToCheck))
			tileIndex += 8;
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
			case NONE:
			// nothing to do
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
		setEntireBufferTileTypes();
	}

	public function localWithTerrain():Array<Array<Int>> {
		return [
			for (i in 0...bufHeight) [for (k in 0...bufWidth) tileToPaintWithTerrain(i, k, local[i][k])]
		];
	}

	public function dump() {
		trace(local);
	}

	public function setEntireBufferTileTypes() {
		for (y in 0...bufHeight) {
			for (x in 0...bufWidth) {
				setTile(x, y, calculator.get(worldX + x, worldY + y, worldZ));
			}
		}
	}

	public function getTileTypeFromPoint(p:FlxPoint):Int {
		return calculator.get(worldX + (p.x / Constants.TILE_SIZE).floor(), worldY + (p.y / Constants.TILE_SIZE).floor(), worldZ);
	}
}
