package states;

import flixel.math.FlxPoint;
import helpers.Constants;
import spacial.Cardinal;
import levels.LayerBufferStack;
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

	var buffer:LayerBufferStack;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		// Buffer is 2 tiles wider and taller than the play field on purpose
		buffer = new LayerBufferStack(14, 22, 2);
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
			var newPlayerTarget = buffer.movePlayer(dir, player.getPosition());
			if (newPlayerTarget != null) {
				player.setTarget(newPlayerTarget);
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
