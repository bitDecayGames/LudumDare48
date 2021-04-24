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
            seg.setPosition(activeSegment.x + activeSegment.width, activeSegment.y + activeSegment.height);
        }

        activeSegment = seg;
		add(seg);
    }

    override public function update(elapsed:Float) {
		super.update(elapsed);

        if (FlxG.keys.justPressed.SPACE) {
            addSegment(StraightSnakeSegment.random());
        }
	}
}