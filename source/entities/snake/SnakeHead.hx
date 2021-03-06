package entities.snake;

import haxe.Timer;
import states.FailState;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.math.FlxVector;
import helpers.Constants;
import flixel.util.FlxPath;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.tile.FlxTilemap;
import spacial.Cardinal;
import flixel.FlxSprite;

typedef NewSegmentCallback = Cardinal->Cardinal->Void;

class SnakeHead extends FlxSprite {
	private static final ANIMATION_IDLE = "anim_idle";

	var map:FlxTilemap;

	public var player:Player;

	var prevDir:Cardinal;
	var curDir:Cardinal;

	public var z:Int = 0;
	public var shouldBeVisible:Bool = true;

	private var newSegmentCallback:NewSegmentCallback;

	private var onPathComplete:() -> Void;

	public var waitTime = 0.0;

	public var onSpeedChange:(FlxVector) -> Void = (v) -> {};

	public function new(p:FlxPoint, dir:Cardinal) {
		super(p.x, p.y);
		loadGraphic(AssetPaths.head__png, true, Constants.TILE_SIZE, Constants.TILE_SIZE);
		var framerate = 3;
		animation.add(ANIMATION_IDLE, [for (i in 0...8) i], framerate);
		animation.play(ANIMATION_IDLE);

		path = new FlxPath();
		path.cancel();

		newSegmentCallback = function(prevDir:Cardinal, newDir:Cardinal) {};

		curDir = dir;
		prevDir = curDir;

		onPathComplete = () -> {};

		waitTime = 3;
	}

	public function onNewSegment(callback:NewSegmentCallback) {
		newSegmentCallback = callback;
	}

	public function updatePathing(searcher:SnakeSearch) {
		if (waitTime > 0) {
			return;
		}
		searcher.updateSearchSpace(this, player);
		if (generatePath(searcher, player.getPosition(), player.z)) {
			// we found a path to the player, we no longer care about the transitions
			player.layerTransitions.resize(0);
			onPathComplete = () -> {};
		} else {
			if (player.layerTransitions.length == 0) {
				trace("uhhhh.. we have no way to chase the player");
			} else {
				// we didn't find the player, work our way through the transitions to find them
				var trans = player.layerTransitions[0];
				generatePath(searcher, trans.location, trans.zFrom);
				onPathComplete = () -> {
					// remove this element when we get there
					player.layerTransitions.remove(trans);
					z = trans.zTo;
				}
			}
		}
	}

	public function clearTarget() {
		player = null;
		path.cancel();
	}

	private function generatePath(searcher:SnakeSearch, to:FlxPoint, z:Int):Bool {
		path.cancel();

		if (to == null) {
			#if debug
			trace("target not set");
			#end
			return false;
		}

		if (this.z != z) {
			return false;
		}

		var start = FlxPoint.get(x + width / 2, y + height / 2);
		var end = FlxPoint.get(to.x + Constants.HALF_TILE_SIZE, to.y + Constants.HALF_TILE_SIZE);
		var pathPoints:Array<FlxPoint> = searcher.tileset.findPath(start, end, false, false, FlxTilemapDiagonalPolicy.NONE);

		#if debug
		trace('attempting pathfind from ${start} to ${end}');
		#end

		// if pathPoints null, cannot find path
		if (pathPoints != null) {
			path.start(pathPoints, Constants.SNAKE_SPEED);
			return true;
		} else {
			#if debug
			trace("could not generate path");
			#end
			return false;
		}
	}

	var targetNode:FlxPoint = FlxPoint.get().copyFrom(Constants.NO_TARGET);
	var lastVelocity = FlxPoint.get().copyFrom(Constants.NO_TARGET);

	override public function update(delta:Float) {
		super.update(delta);

		#if debug
		if (FlxG.keys.pressed.P) {
			waitTime = 2;
		}
		#end

		if (waitTime > 0) {
			lastVelocity.copyFrom(velocity);
			waitTime -= delta;
			path.cancel();

			onSpeedChange(FlxPoint.get());
			return;
		}

		if (path.finished) {
			path.cancel();
			onPathComplete();
		}

		if (!lastVelocity.equals(Constants.NO_TARGET)) {
			curDir = Cardinal.closest(FlxVector.get(lastVelocity.x, lastVelocity.y), true);
		} else {
			curDir = Cardinal.closest(FlxVector.get(velocity.x, velocity.y), true);
		}

		onSpeedChange(velocity);

		lastVelocity.copyFrom(Constants.NO_TARGET);

		if (path != null && path.nodes.length > 0) {
			if (!targetNode.equals(path.nodes[path.nodeIndex])) {
				// reached a target, move to next place!
				newSegmentCallback(prevDir, curDir);
				targetNode.copyFrom(path.nodes[path.nodeIndex]);
			}

			if (FlxG.overlap(this, player)) {
				if (player.z == z) {
					FmodManager.PlaySoundOneShot(FmodSFX.SnakeEatMole);
					FmodFlxUtilities.TransitionToState(new FailState());
				}
			}
			checkIfKillMoleFollowers();
		}

		prevDir = curDir;

		flipX = curDir == Cardinal.E;
		if (curDir == Cardinal.NONE) {
			// don't mess with angle in this case
		} else if (curDir == Cardinal.N) {
			angle = 90;
		} else if (curDir == Cardinal.S) {
			angle = 270;
		} else {
			angle = 0;
		}

		if (shouldBeVisible) {
			alpha += delta * 2;
			if (alpha > 1.0) {
				alpha = 1.0;
			}
		} else {
			alpha -= delta * 2;
			if (alpha < 0.0) {
				alpha = 0.0;
			}
		}
	}

	private function checkIfKillMoleFollowers() {
		var moleToKill = player.findFirstMoleCloseToPoint(x, y, z);
		if (moleToKill != null && moleToKill.health > 0) {
			FmodManager.PlaySoundOneShot(FmodSFX.SnakeEatMole);
			moleToKill.kill();
			waitTime = 0.5;
		}
	}

	override public function draw():Void {
		super.draw();

		#if debug
		if (!path.finished) {
			drawDebug();
		}
		#end
	}
}
