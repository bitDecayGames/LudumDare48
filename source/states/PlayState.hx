package states;

import levels.LayerBuffer;
import input.SimpleController;
import levels.LevelBuffer;
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

	var buffer:LayerBuffer;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

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

		var target = player.getIntention();
		var targetTile = buffer.get_index_from_point(target);


		// 2 is rocks for now... can't move into those
		if (targetTile < 2) {
			player.setTarget(target);
			if (targetTile == 1) {
				buffer.setTile((target.x / buffer.get_tile_width()).floor(), (target.y / buffer.get_tile_height()).floor(), 0);
			}
		}

		// reference for how to move the buffer around
		if (SimpleController.just_pressed(Button.UP)) {
			buffer.pushOntoBottom([for(i in 0...16) 1]);
		} else if (SimpleController.just_pressed(Button.DOWN)) {
			buffer.pushOntoTop([for(i in 0...16) 1]);
		} else if (SimpleController.just_pressed(Button.LEFT)) {
			buffer.pushOntoRight([for(i in 0...24) 2]);
		} else if (SimpleController.just_pressed(Button.RIGHT)) {
			buffer.pushOntoLeft([for(i in 0...24) 2]);
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
