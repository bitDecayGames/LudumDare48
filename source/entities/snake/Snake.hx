package entities.snake;

import spacial.Cardinal;
import flixel.FlxG;
import flixel.math.FlxVector;
import flixel.group.FlxGroup;

class Snake extends FlxGroup {
    var straightSegments:Array<StraightSnakeSegment>;
    var activeStraightSegment:StraightSnakeSegment;
    var curvedSegments:Array<CurvedSnakeSegment>;
    var head:SnakeHead;

    public function new(startPos:FlxVector) {
        super();
        straightSegments = [];
        curvedSegments = [];

        addSegment(Cardinal.E);
        activeStraightSegment.setPosition(startPos.x, startPos.y);

        head = new SnakeHead();
        add(head);
    }

    private function addSegment(dir: Cardinal) {
        var strSeg = new StraightSnakeSegment(dir);

        if (activeStraightSegment != null) {
            activeStraightSegment.stop();

            var x = activeStraightSegment.x + activeStraightSegment.width;
            var y = activeStraightSegment.y + activeStraightSegment.height;
            strSeg.setPosition(x, y);

            var crvSeg = CurvedSnakeSegment.create(activeStraightSegment.direction, strSeg.direction);
            crvSeg.setPosition(x, y);
            curvedSegments.push(crvSeg);
            add(crvSeg);
        }

        activeStraightSegment = strSeg;
        straightSegments.push(strSeg);
		add(strSeg);
    }

    override public function update(elapsed:Float) {
		super.update(elapsed);

        if (FlxG.keys.justPressed.SPACE) {
            var dir = StraightSnakeSegment.randomDir(activeStraightSegment.direction);
            addSegment(dir);
        }

        var x = activeStraightSegment.x + activeStraightSegment.width;
        var y = activeStraightSegment.y + activeStraightSegment.height;
        head.setPosition(x, y);
        head.angle = activeStraightSegment.direction;
	}
}