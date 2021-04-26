package entities.snake;

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
	var target:FlxSprite;

	var prevDir:Cardinal;
	var curDir:Cardinal;

	public var z:Int = 0;
	public var shouldBeVisible:Bool = true;

	private var newSegmentCallback:NewSegmentCallback;

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
	}

	public function onNewSegment(callback:NewSegmentCallback) {
		newSegmentCallback = callback;
	}

	public function hasTarget():Bool {
		return target != null;
	}

	public function setTarget(t:FlxSprite, searcher:SnakeSearch) {
		target = t;
		searcher.updateSearchSpace(this, t);
		generatePath(searcher);
	}

	public function clearTarget() {
		target = null;
		path.cancel();
	}

	private function generatePath(searcher:SnakeSearch) {
		path.cancel();

		if (target == null) {
			#if debug
			trace("target not set");
			#end
			return;
		}

		var start = FlxPoint.get(x + width / 2, y + height / 2);
		var end = FlxPoint.get(target.x + target.width / 2, target.y + target.height / 2);
		var pathPoints:Array<FlxPoint> = searcher.tileset.findPath(start, end, false, false, FlxTilemapDiagonalPolicy.NONE);

		#if debug
		trace('attempting pathfind from ${start} to ${end}');
		#end

		// if pathPoints null, cannot find path
		if (pathPoints != null) {
			path.start(pathPoints, Constants.SNAKE_SPEED);
		} else {
			#if debug
			trace("could not generate path");
			#end
		}
	}

	var targetNode:FlxPoint = FlxPoint.get().copyFrom(Constants.NO_TARGET);

	override public function update(delta:Float) {
		super.update(delta);

		if (path.finished) {
			path.cancel();
			target = null;
		}

		curDir = Cardinal.closest(FlxVector.get(velocity.x, velocity.y), true);

		if (path != null && path.nodes.length > 0) {
			if (!targetNode.equals(path.nodes[path.nodeIndex])) {
				// reached a target, move to next place!
				newSegmentCallback(prevDir, curDir);
				targetNode.copyFrom(path.nodes[path.nodeIndex]);
			}

			if (FlxG.overlap(this, target)) {
				var playerTarget = cast(target, Player);
				if (playerTarget != null && playerTarget.z == z) {
					// TODO: Player got eated
					FmodFlxUtilities.TransitionToState(new FailState());
				}
			}
		}

		prevDir = curDir;

		flipX = curDir == Cardinal.E;
		if (curDir == Cardinal.N) {
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

	override public function draw():Void {
		super.draw();

		#if debug
		if (!path.finished) {
			drawDebug();
		}
		#end
	}
}
