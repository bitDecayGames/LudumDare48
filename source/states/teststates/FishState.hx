package states.teststates;

import flixel.FlxCamera.FlxCameraFollowStyle;
import levels.LayerBufferStack;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import entities.MoleFriend;
import flixel.FlxG;
import spacial.Cardinal;
import helpers.Constants;

using extensions.FlxStateExt;
using zero.flixel.extensions.FlxTilemapExt;
using Math;

class FishState extends FlxTransitionableState {
	var player:Player;
	var moleFriend:MoleFriend;
	var moleFriend2:MoleFriend;

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

		moleFriend = new MoleFriend();
		moleFriend.x = 0;
		moleFriend.y = 0;
		add(moleFriend);

		moleFriend2 = new MoleFriend();
		moleFriend2.x = 3 * Constants.TILE_SIZE;
		moleFriend2.y = 0;
		add(moleFriend2);
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
		var depthDir = player.getDepthIntention();
		if (depthDir != 0) {
			buffer.switchLayer(depthDir);
		}

		if (player.x == moleFriend.x && player.y == moleFriend.y && moleFriend.moleIdLikeToFollow == null) {
			player.setFollower(moleFriend);
		}

		if (player.x == moleFriend2.x && player.y == moleFriend2.y && moleFriend2.moleIdLikeToFollow == null) {
			player.setFollower(moleFriend2);
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
