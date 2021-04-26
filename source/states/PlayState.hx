package states;

import entities.MoleFriend;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxVector;
import entities.snake.Snake;
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

	var snake:Snake;
	var snakeNeedsUpdate:Bool = false;

	var buffer:LayerBufferStack;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();
		FmodManager.PlaySong(FmodSongs.Maybe);

		FlxG.camera.pixelPerfectRender = true;

		// makes sure "MOST" of the mole buddies will be within this rect so collisions can happen
		FlxG.worldBounds.set(-50 * Constants.TILE_SIZE, -10 * Constants.TILE_SIZE, 100 * Constants.TILE_SIZE, 10000000 * Constants.TILE_SIZE);

		var milfs = new FlxTypedGroup<MoleFriend>();
		// Buffer is 2 tiles wider and taller than the play field on purpose
		buffer = new LayerBufferStack(-7, -11, 14, 22, 2, milfs);
		add(buffer);

		add(milfs);
		player = new Player();
		add(player);
		add(player.tail);
		add(player.emitter);

		buffer.repositionLayers(Cardinal.NONE, player.getPosition());

		#if nosnake
		#else
		snake = new Snake(FlxVector.get());
		add(snake);
		add(snake.searcher.tileset);
		#end

		player.setTarget(new MoveResult(player.getPosition(), EMPTY_SPACE, false));

		camera.follow(player, FlxCameraFollowStyle.TOPDOWN_TIGHT);

		buffer.addMoleFriend(0, 0);
		buffer.addMoleFriend(3 * Constants.TILE_SIZE, 0);
		buffer.addMoleFriend(-3 * Constants.TILE_SIZE, 0);
		buffer.addMoleFriend(6 * Constants.TILE_SIZE, 0);
		buffer.addMoleFriend(-6 * Constants.TILE_SIZE, 0);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.watch.addQuick('player pos:', player.getPosition());

		if (!player.hasTarget()) {
			if (snakeNeedsUpdate) {
				#if nosnake
				#else
				snake.setTarget(player);
				snakeNeedsUpdate = false;
				#end
			}
		} else {
			snakeNeedsUpdate = true;
		}
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
				player.transitionDir = depthDir;
				player.isTransitioningBetweenLayers = buffer.switchLayer(depthDir, player.getPosition(), () -> {
					player.isTransitioningBetweenLayers = false;
				});
			}
		}
		if (player.hasTarget()) {
			// check if there are in friends around that should follow us
			buffer.checkForMilfOverlap(player);
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
