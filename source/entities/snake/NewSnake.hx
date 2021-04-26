package entities.snake;

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

	var target:FlxSprite;

	public function new(pos:FlxPoint, dir:Cardinal) {
		super();
		searcher = new SnakeSearch();
		head = new SnakeHead(pos, E);
		head.onNewSegment(function(prevDir, newDir) {
            addSegment(prevDir, newDir);
        });
		add(segGroup);
		add(head);
	}

	public function occupies(p:FlxPoint):Bool {
		for (s in segments) {
			if (s.overlapsPoint(p)) {
				return true;
			}
		}
		return false;
	}

	public function setTarget(t: FlxSprite) {
		target = t;
		head.setTarget(target, searcher);
    }

	private function addSegment(inDir:Cardinal, outDir:Cardinal) {
        var seg = new NewSegment(
			head.x.snap_to_grid(Constants.TILE_SIZE),
			head.y.snap_to_grid(Constants.TILE_SIZE),
			inDir,
			outDir);
		segments.push(seg);

		// TODO: Synchronize frames
		if (segments.length > 0) {
			var frameNum = segments[0].animation.curAnim.curFrame;
			for(i in 1...segments.length) {
				segments[i].animation.curAnim.curFrame = frameNum;
			}
		}
		segGroup.add(seg);
    }
}