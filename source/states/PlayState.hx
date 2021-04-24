package states;

import flixel.math.FlxPoint;
import helpers.Constants;
import spacial.Cardinal;
import levels.LayerBuffer;
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

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		// Buffer is 2 tiles wider and taller than the play field on purpose
		buffer = new LayerBuffer(14, 22, 2);
		buffer.tilemap.x = -32;
		buffer.tilemap.y = -32;
		add(buffer);

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
					buffer.setTile((bufferTarget.x / buffer.get_tile_width()).floor(), (bufferTarget.y / buffer.get_tile_height()).floor(), 0);
				}
				buffer.pushData(dir, getNextLevelData(dir));
			}
		}
		// buffer is slightly bigger than screen, so we position it so it's centered correctly
		buffer.setPosition(player.x - 8 * Constants.TILE_SIZE, player.y - 12 * Constants.TILE_SIZE);
	}

	public function getNextLevelData(dir:Cardinal):Array<Int> {
		return switch(dir) {
			case N:
				getWorldDataRow(buffer.worldX, buffer.worldY-1, buffer.bufWidth);
			case S:
				getWorldDataRow(buffer.worldX, buffer.worldY + buffer.bufHeight + 1, buffer.bufWidth);
			case E:
				getWorldDataColumn(buffer.worldX + buffer.bufWidth + 1, buffer.worldY, buffer.bufHeight);
			case W:
				getWorldDataColumn(buffer.worldX - 1, buffer.worldY, buffer.bufHeight);
			default:
				throw('cannot request level data for direction ${dir}');
		}
	}

	public function getWorldDataRow(x:Int, y:Int, num:Int):Array<Int> {
		// TODO: Pull from perlin noise function
		var tile = FlxG.random.int(1, 2);
		return [for(i in 0...num) tile];
	}

	public function getWorldDataColumn(x:Int, y:Int, num:Int):Array<Int> {
		// TODO: Pull from perlin noise function
		var tile = FlxG.random.int(1, 2);
		return [for(i in 0...num) tile];
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
