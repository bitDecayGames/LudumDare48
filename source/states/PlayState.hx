package states;

import helpers.Constants;
import spacial.Cardinal;
import levels.LayerBuffer;
import levels.VoxelCalculator;
import input.SimpleController;
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
		buffer = new LayerBuffer(16, 24);
		buffer.tilemap.x = -32;
		buffer.tilemap.y = -32;
		add(buffer);

		player = new Player();
		add(player);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		var dir = player.getIntention();
		if (dir != Cardinal.NONE) {
			var target = player.getPosition();
			target.addPoint(dir.asVector().scale(Constants.TILE_SIZE));
			var targetTile = buffer.get_index_from_point(target);

			// 2 is rocks for now... can't move into those
			if (targetTile < 2) {
				player.setTarget(target);
				if (targetTile == 1) {
					buffer.setTile((target.x / buffer.get_tile_width()).floor(), (target.y / buffer.get_tile_height()).floor(), 0);
				}
				buffer.pushData(dir, getNextLevelData(dir));
			}

			// reference for how to move the buffer around
			// if (SimpleController.just_pressed(Button.UP)) {
			// 	buffer.pushOntoBottom([for(i in 0...16) 1]);
			// } else if (SimpleController.just_pressed(Button.DOWN)) {
			// 	buffer.pushOntoTop([for(i in 0...16) 1]);
			// } else if (SimpleController.just_pressed(Button.LEFT)) {
			// 	buffer.pushOntoRight([for(i in 0...24) 2]);
			// } else if (SimpleController.just_pressed(Button.RIGHT)) {
			// 	buffer.pushOntoLeft([for(i in 0...24) 2]);
			// }
		}
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
