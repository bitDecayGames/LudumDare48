package entities.snake;

import flixel.tweens.FlxTween;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import helpers.Constants;
import flixel.FlxSprite;
import spacial.Cardinal;
import flixel.group.FlxSpriteGroup;

using zero.extensions.FloatExt;

class NewSnake extends FlxSpriteGroup {
	var head:SnakeHead;

	public var searcher:SnakeSearch;

	public var segments = new Array<NewSegment>();

	var segGroup = new FlxSpriteGroup();

	public var player:Player;

	public function new(pos:FlxPoint, player:Player) {
		super();
		searcher = new SnakeSearch();
		this.player = player;
		head = new SnakeHead(pos, E);
		head.player = player;
		head.onNewSegment(function(prevDir, newDir) {
			addSegment(prevDir, newDir);
		});
		head.onSpeedChange = setSpeed;
		add(segGroup);
		add(head);

		makeOffscreenSnake();
	}

	private function makeOffscreenSnake() {
		for (i in 0...15) {
			var seg = new NewSegment(head.x.snap_to_grid(Constants.TILE_SIZE) - i * Constants.TILE_SIZE, head.y.snap_to_grid(Constants.TILE_SIZE), head.z, E,
				E, head.shouldBeVisible);

			segments.push(seg);
			segGroup.add(seg);
		}
	}

	public function occupies(p:FlxPoint, z:Int):Bool {
		for (s in segments) {
			if (s.z == z && s.overlapsPoint(p)) {
				return true;
			}
		}
		return false;
	}

	public function setWait(t:Float) {
		head.waitTime = t;
	}

	public function updatePathing() {
		head.updatePathing(searcher);
	}

	private function addSegment(inDir:Cardinal, outDir:Cardinal) {
		var seg = new NewSegment(head.x.snap_to_grid(Constants.TILE_SIZE), head.y.snap_to_grid(Constants.TILE_SIZE), head.z, inDir, outDir,
			head.shouldBeVisible);
		segments.push(seg);

		// TODO: Synchronize frames
		if (segments.length > 0) {
			var frameNum = segments[0].animation.curAnim.curFrame;
			for (i in 1...segments.length) {
				segments[i].animation.curAnim.curFrame = frameNum;
			}
		}

		seg.alpha = 0;
		FlxTween.tween(seg, {alpha: 1}, 0.5);

		segGroup.add(seg);
	}

	public function setSpeed(velocity:FlxVector) {
		var len = velocity.length;
		if (segments.length > 0) {
			for (i in 1...segments.length) {
				segments[i].animation.curAnim.frameRate = len / 8 * 4;
			}
		}
	}

	public function makePartsVisibleOrNot(currentZ:Int) {
		head.shouldBeVisible = head.z == currentZ;
		for (s in segments) {
			s.shouldBeVisible = s.z == currentZ;
		}
	}
}
