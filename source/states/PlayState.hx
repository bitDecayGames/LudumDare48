package states;

import flixel.math.FlxPoint;
import helpers.Constants;
import spacial.Cardinal;
import levels.LayerBuffer;
import levels.VoxelCalculator;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxG;

using extensions.FlxStateExt;
using zero.flixel.extensions.FlxTilemapExt;
using Math;

class PlayState extends FlxTransitionableState {
	var player:Player;

	var buffer:LayerBuffer;
	var calculator:VoxelCalculator;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		calculator = new VoxelCalculator();

		// Buffer is 2 tiles wider and taller than the play field on purpose
		buffer = new LayerBuffer(14, 22, 2);
		buffer.tilemap.x = -32;
		buffer.tilemap.y = -32;
		add(buffer);
		setEntireBufferTileTypes(buffer, 0);

		player = new Player();
		player.x = Constants.TILE_SIZE * 7;
		player.y = Constants.TILE_SIZE * 11;
		add(player);

		camera.follow(player);
		// camera.setScrollBounds(-10000, 10000, 0, 10000);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		var dir = player.getIntention();
		if (dir != Cardinal.NONE) {
			var tileMovement = dir.asVector().scale(Constants.TILE_SIZE);

			// figure out the world coordinates of where the player wants to be
			var worldTarget = player.getPosition();
			worldTarget.addPoint(tileMovement);

			// figure out the tilemap coordinates within the buffer
			var bufferTarget = FlxPoint.get().copyFrom(worldTarget);
			bufferTarget.subtract(buffer.worldX * Constants.TILE_SIZE, buffer.worldY * Constants.TILE_SIZE);

			var targetTile = buffer.get_index_from_point(bufferTarget);

			// 2 is rocks for now... can't move into those
			if (targetTile < 2) {
				player.setTarget(worldTarget);
				if (targetTile == 1) {
					var x = (bufferTarget.x / buffer.get_tile_width()).floor();
					var y = (bufferTarget.y / buffer.get_tile_height()).floor();
					buffer.setTile(x, y, 0);
					calculator.set(x, y, 0, 0);
				}
				buffer.pushData(dir, getNextLevelData(dir));
			}
		}
		// buffer is slightly bigger than screen, so we position it so it's centered correctly
		buffer.setPosition(player.x - 8 * Constants.TILE_SIZE, player.y - 12 * Constants.TILE_SIZE);
	}

	public function getNextLevelData(dir:Cardinal):Array<Int> {
		return switch (dir) {
			case N:
				getWorldDataRow(buffer.worldX, buffer.worldY - 1, 0, buffer.bufWidth);
			case S:
				getWorldDataRow(buffer.worldX, buffer.worldY + buffer.bufHeight + 1, 0, buffer.bufWidth);
			case E:
				getWorldDataColumn(buffer.worldX + buffer.bufWidth + 1, buffer.worldY, 0, buffer.bufHeight);
			case W:
				getWorldDataColumn(buffer.worldX - 1, buffer.worldY, 0, buffer.bufHeight);
			default:
				throw('cannot request level data for direction ${dir}');
		}
	}

	public function setEntireBufferTileTypes(buffer:LayerBuffer, z:Int) {
		for (y in 0...buffer.bufHeight) {
			for (x in 0...buffer.bufWidth) {
				buffer.setTile(x, y, calculator.get(buffer.worldX + x, buffer.worldY + y, z));
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

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
