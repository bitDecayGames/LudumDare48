package states;

import entities.MoveResult;
import flixel.FlxCamera;
import helpers.Constants;
import spacial.Cardinal;
import levels.LayerBufferStack;
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
		add(player.tail);

		player.setTarget(new MoveResult(player.getPosition(), EMPTY_SPACE, false));

		camera.follow(player, FlxCameraFollowStyle.TOPDOWN_TIGHT);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (!player.hasTarget() && !player.isTransitioningBetweenLayers) {
			// check if the player should be falling first (only if not currently transitioning between layers)
			var result = buffer.fallPlayer(player.getPosition());
			if (result != null) {
				player.setTarget(result);
			}

			// now check if the player wants to move somewhere in the current plane
			var dir = player.getIntention();
			if (dir != Cardinal.NONE) {
				result = buffer.movePlayer(dir, player.getPosition());
				if (result != null) {
					player.setTarget(result);
				}
			}

			// now check if they want to go deeper
			var depthDir = player.getDepthIntention();
			if (depthDir != 0) {
				player.isTransitioningBetweenLayers = buffer.switchLayer(depthDir, player.getPosition(), () -> {
					player.isTransitioningBetweenLayers = false;
				});
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
