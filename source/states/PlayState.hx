package states;

import particles.BloodEmitter;
import com.bitdecay.metrics.Common;
import com.bitdecay.analytics.Bitlytics;
import states.transitions.Trans;
import flixel.util.FlxColor;
import haxe.Timer;
import states.transitions.SwirlTransition;
import levels.VoxelCalculator;
import flixel.FlxSprite;
import metrics.Metrics;
import helpers.TileType;
import entities.snake.NewSnake;
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
using zero.extensions.FloatExt;
using Math;

class PlayState extends FlxTransitionableState {
	var player:Player;

	var snake:NewSnake;
	var snakeNeedsUpdate:Bool = false;

	var buffer:LayerBufferStack;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();
		FmodManager.PlaySong(FmodSongs.Maybe);

		FlxG.camera.pixelPerfectRender = true;
		FlxG.worldBounds.set(-20 * Constants.TILE_SIZE, -1 * Constants.TILE_SIZE, 40 * Constants.TILE_SIZE,
			(VoxelCalculator.queenBound + 3) * Constants.TILE_SIZE);
		VoxelCalculator.instance.reset();

		var milfs = new FlxTypedGroup<MoleFriend>();

		var bloodEmitter = new BloodEmitter();
		// Buffer is 2 tiles wider and taller than the play field on purpose
		buffer = new LayerBufferStack(-7, -11, 14, 22, 2, milfs, bloodEmitter);
		add(buffer);

		var queen = new FlxSprite(AssetPaths.queen__png);
		queen.x = -queen.width / 2;
		queen.y = (VoxelCalculator.queenBound + 1.85) * Constants.TILE_SIZE - queen.height;
		add(milfs);

		player = new Player(bloodEmitter);
		add(player);
		add(player.tail);
		add(player.emitter);

		buffer.repositionLayers(Cardinal.NONE, player.getPosition());

		snake = new NewSnake(FlxVector.get(-7 * Constants.TILE_SIZE, 0), player);
		#if nosnake
		#else
		add(snake);
		add(snake.searcher.tileset);
		#end

		player.setTarget(new MoveResult(player.getPosition(), EMPTY_SPACE, false, Cardinal.W));

		camera.follow(player, FlxCameraFollowStyle.TOPDOWN_TIGHT);

		buffer.addMoleFriend(0, 0);
		buffer.addMoleFriend(3 * Constants.TILE_SIZE, 0);
		buffer.addMoleFriend(-3 * Constants.TILE_SIZE, 0);
		buffer.addMoleFriend(6 * Constants.TILE_SIZE, 0);
		buffer.addMoleFriend(-6 * Constants.TILE_SIZE, 0);

		player.z = buffer.layers[0].worldZ;

		transOut = null;

		add(queen);
		add(bloodEmitter);
	}

	var gameOver = false;

	override public function update(elapsed:Float) {
		super.update(elapsed);

		// slightly past the downBound
		if (player.y >= (VoxelCalculator.downBound + 4) * Constants.TILE_SIZE) {
			// game has ended! Great success!
			snake.active = false;
			if (!player.hasTarget()) {
				// make sure the player gets down to the QUEEN
				var result = buffer.fallPlayer(player.getPosition(), snake);
				if (result != null) {
					player.setTarget(result);
				}
			}

			if (!gameOver) {
				gameOver = true;
				Timer.delay(() -> {
					var swirlOut = new SwirlTransition(Trans.OUT, () -> {
						// make sure our music is stopped;
						FmodManager.StopSongImmediately();
						FlxG.switchState(new MoleFactsState(new CreditsState(),
							'You saved ${player.numMolesFollowingMe()} mole${player.numMolesFollowingMe() != 1 ? "s" : ""}!'));
						Bitlytics.Instance().Queue(Common.GameCompleted, 1);
						Bitlytics.Instance().ForceFlush();
					});
					openSubState(swirlOut);
				}, 3000);
			}
			return;
		}

		#if nosnake
		#else
		snake.makePartsVisibleOrNot(buffer.layers[0].worldZ);
		#end

		if (!player.hasTarget()) {
			if (snakeNeedsUpdate) {
				#if nosnake
				#else
				snake.updatePathing();
				snakeNeedsUpdate = false;
				#end
			}
		} else {
			snakeNeedsUpdate = true;
		}
		if (!player.hasTarget() && !player.isTransitioningBetweenLayers) {
			Metrics.reportDepth(Std.int(player.y.snap_to_grid(32) / Constants.TILE_SIZE));
			// check if the player should be falling first (only if not currently transitioning between layers)
			var result = buffer.fallPlayer(player.getPosition(), snake);
			if (result != null) {
				player.setTarget(result);
			}

			// now check if the player wants to move somewhere in the current plane
			var dir = player.getIntention();
			if (dir != Cardinal.NONE) {
				result = buffer.movePlayer(dir, player.getPosition(), snake);
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
					// this hopefully makes the mole followers try to follow the player through the hole
					player.setTarget(new MoveResult(player.getPosition(), TileType.EMPTY_SPACE, false, Cardinal.NONE, depthDir));
				});
				if (player.isTransitioningBetweenLayers) {
					// this hopefully makes the mole followers try to follow the player through the hole
					player.setTarget(new MoveResult(player.getPosition(), TileType.EMPTY_SPACE, false, Cardinal.NONE));
				}
			}
		}
		if (player.hasTarget()) {
			// check if there are in friends around that should follow us
			buffer.checkForMilfOverlap(player);
		}

		buffer.makeMolesInDifferentLayersInvisible();
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
