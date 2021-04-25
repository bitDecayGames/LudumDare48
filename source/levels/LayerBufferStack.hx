package levels;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import helpers.Constants;
import spacial.Cardinal;
import flixel.tile.FlxTilemap;

using extensions.FlxStateExt;
using zero.flixel.extensions.FlxTilemapExt;
using Math;

class LayerBufferStack extends FlxTypedGroup<LayerBuffer> {
	public var layers:Array<LayerBuffer> = new Array<LayerBuffer>();

	public var calculator:VoxelCalculator;

	public function new(width:Int, height:Int, padding:Int) {
		super();
		calculator = new VoxelCalculator();
		for (i in 0...3) {
			var l = new LayerBuffer(width, height, padding + (2 * i));
			l.worldZ = i;
			var scale = 1.0 - i * 0.1;
			l.scale.set(scale, scale);
			var tint = (255 * (1 - i * 0.3)).floor();
			l.color = FlxColor.fromRGB(tint, tint, tint);
			setEntireBufferTileTypes(l);
			layers.push(l);
		}
		for (i in 0...3) {
			add(layers[layers.length - 1 - i]);
		}
	}

	public function movePlayer(dir:Cardinal, playerPos:FlxPoint):FlxPoint {
		var main = layers[0];
		var tileMovement = dir.asVector().scale(Constants.TILE_SIZE);

		// figure out the world coordinates of where the player wants to be
		var worldTarget = new FlxPoint(playerPos.x, playerPos.y);
		worldTarget.addPoint(tileMovement);

		// figure out the tilemap coordinates within the buffer
		var bufferTarget = FlxPoint.get().copyFrom(worldTarget);
		bufferTarget.subtract(main.worldX * Constants.TILE_SIZE, main.worldY * Constants.TILE_SIZE);
		bufferTarget.x -= 10;
		bufferTarget.y -= 10;

		var targetTile = main.get_index_from_point(bufferTarget);

		// 2 is rocks for now... can't move into those
		if (targetTile != Constants.ROCK) {
			if (targetTile == Constants.DIRT) {
				var x = (bufferTarget.x / main.get_tile_width()).floor();
				var y = (bufferTarget.y / main.get_tile_height()).floor();
				main.setTile(x, y, Constants.AFTER_DIG);
				calculator.set(((worldTarget.x - 10) / Constants.TILE_SIZE).floor(), ((worldTarget.y - 10) / Constants.TILE_SIZE).floor(), main.worldZ,
					Constants.AFTER_DIG);
			}
			for (i in 0...layers.length) {
				layers[i].pushData(dir, getNextLevelData(dir, layers[i]));
			}

			// buffer is slightly bigger than screen, so we position it so it's centered correctly
			var x = worldTarget.x - 8 * Constants.TILE_SIZE;
			var y = worldTarget.y - 12 * Constants.TILE_SIZE;
			for (i in 0...layers.length) {
				// TODO: MW instead of setting position, if we lerp to this new xy it will smooth out the snappy tilemap
				layers[i].setPosition(x, y);
			}
			return worldTarget;
		}
		return null;
	}

	public function switchLayer(dir:Int) {
		if (dir != -1 && dir != 1) {
			trace("You are not allowed to move more than one layer at a time");
			return;
		}
		for (i in 0...3) {
			layers[i].worldZ += dir;
			setEntireBufferTileTypes(layers[i]);
		}
	}

	public function getNextLevelData(dir:Cardinal, buffer:LayerBuffer):Array<Int> {
		return switch (dir) {
			case N:
				getWorldDataRow(buffer.worldX, buffer.worldY - 1, buffer.worldZ, buffer.bufWidth);
			case S:
				getWorldDataRow(buffer.worldX, buffer.worldY + buffer.bufHeight + 1, buffer.worldZ, buffer.bufWidth);
			case E:
				getWorldDataColumn(buffer.worldX + buffer.bufWidth + 1, buffer.worldY, buffer.worldZ, buffer.bufHeight);
			case W:
				getWorldDataColumn(buffer.worldX - 1, buffer.worldY, buffer.worldZ, buffer.bufHeight);
			default:
				throw('cannot request level data for direction ${dir}');
		}
	}

	public function setEntireBufferTileTypes(buffer:LayerBuffer) {
		for (y in 0...buffer.bufHeight) {
			for (x in 0...buffer.bufWidth) {
				buffer.setTile(x, y, calculator.get(buffer.worldX + x, buffer.worldY + y, buffer.worldZ));
			}
		}
	}

	public function getWorldDataRow(x:Int, y:Int, z:Int, num:Int):Array<Int> {
		var tiles:Array<Int> = [];
		for (i in 0...num) {
			tiles.push(calculator.get(x + i, y, z));
		}
		return tiles;
	}

	public function getWorldDataColumn(x:Int, y:Int, z:Int, num:Int):Array<Int> {
		var tiles:Array<Int> = [];
		for (i in 0...num) {
			tiles.push(calculator.get(x, y + i, z));
		}
		return tiles;
	}
}
