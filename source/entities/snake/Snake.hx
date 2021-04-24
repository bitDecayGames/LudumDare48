package entities.snake;

import flixel.FlxG;
import flixel.math.FlxVector;
import flixel.group.FlxGroup;

class Snake extends FlxGroup {
    var segments:Array<StraightSnakeSegment>;
    var activeSegment:StraightSnakeSegment;
    var startPos:FlxVector;

    public function new(startPos:FlxVector) {
        super();
        segments = [];

        addSegment(StraightSnakeSegment.right());
        activeSegment.setPosition(startPos.x, startPos.y);
    }

    private function addSegment(seg: StraightSnakeSegment) {
        if (activeSegment != null) {
            activeSegment.stop();
            var activePos = activeSegment.getPosition();
            seg.setPosition(activePos.x, activePos.x);
        }

        activeSegment = seg;
		add(seg);
    }

    override public function update(elapsed:Float) {
		super.update(elapsed);

        if (FlxG.keys.justPressed.SPACE) {
            addSegment(StraightSnakeSegment.random());
        }

        var offset = 0.0;
		var i = segments.length - 1;
        while (i >= 0) {
			offset += segments[i].getSpriteOffsetAmount();
			segments[i].setSpriteOffset(offset);
			i--;
		}
	}
}