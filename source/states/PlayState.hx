package states;

import flixel.tile.FlxTilemap;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxG;

using extensions.FlxStateExt;
using zero.flixel.extensions.FlxTilemapExt;
using Math;

class PlayState extends FlxTransitionableState {
	var player:Player;
	var level:FlxTilemap;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		level = new FlxTilemap();
		level.loadMapFromArray(
			[
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,2,2,2,2,1,1,1,1,1,1,1,
				1,1,1,2,1,1,1,1,1,1,1,1,1,1,
				1,1,1,2,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,2,1,1,1,1,1,1,1,1,
				1,1,1,1,1,2,1,1,1,1,1,1,1,1,
				1,1,1,1,2,2,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,
			], 14, 22, AssetPaths.testTiles__png
		);
		add(level);

		player = new Player();
		add(player);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		var target = player.getIntention();
		var targetTile = level.get_index_from_point(target);


		if (targetTile < 2) {
			player.setTarget(target);
			if (targetTile == 1) {
				level.setTile((target.x / level.get_tile_width()).floor(), (target.y / level.get_tile_height()).floor(), 0);
			}
		}
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
