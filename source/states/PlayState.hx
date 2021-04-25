package states;

import flixel.FlxCamera;
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

		player.setTarget(player.getPosition());

		camera.follow(player, FlxCameraFollowStyle.TOPDOWN_TIGHT);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (!player.hasTarget()) {
			// check if the player should be falling first
			var newPlayerTarget = buffer.fallPlayer(player.getPosition());
			if (newPlayerTarget != null) {
				player.setTarget(newPlayerTarget);
			}

			// now check if the player wants to move somewhere in the current plane
			var dir = player.getIntention();
			if (dir != Cardinal.NONE) {
				newPlayerTarget = buffer.movePlayer(dir, player.getPosition());
				if (newPlayerTarget != null) {
					player.setTarget(newPlayerTarget);
				}
			}

			// now check if they
			var depthDir = player.getDepthIntention();
			if (depthDir != 0) {
				buffer.switchLayer(depthDir, player.getPosition());
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
