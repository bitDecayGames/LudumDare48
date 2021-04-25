package entities.snake;

import helpers.Constants;
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

        head = new SnakeHead();
        add(head);

        addSegment(Cardinal.E);
        activeStraightSegment.setPosition(startPos.x, startPos.y);
    }

    private function addSegment(dir: Cardinal) {
        var strSeg = new StraightSnakeSegment(dir);

        if (activeStraightSegment != null) {
            activeStraightSegment.stop();

            var crvPos = activeStraightSegment.direction.asVector().scale(activeStraightSegment.width).add(activeStraightSegment.x, activeStraightSegment.y);

            var crvSeg = CurvedSnakeSegment.create(activeStraightSegment.direction, strSeg.direction);
            crvSeg.setPosition(crvPos.x, crvPos.y);
            curvedSegments.push(crvSeg);
            add(crvSeg);

            var strSegVec = dir.asVector().scale(Constants.TILE_SIZE).add(crvSeg.x, crvSeg.y);
            strSeg.setPosition(strSegVec.x, strSegVec.y);
        }

        activeStraightSegment = strSeg;
        head.setSegment(activeStraightSegment);
        straightSegments.push(strSeg);
		add(strSeg);
    }

    override public function update(elapsed:Float) {
		super.update(elapsed);

        #if debug
        if (FlxG.keys.justPressed.SPACE) {
            var dir = StraightSnakeSegment.randomDir(activeStraightSegment.direction);
            addSegment(dir);
        } else if (FlxG.keys.justPressed.UP) {
            addSegment(Cardinal.N);
        } else if (FlxG.keys.justPressed.DOWN) {
            addSegment(Cardinal.S);
        } else if (FlxG.keys.justPressed.LEFT) {
            addSegment(Cardinal.W);
        } else if (FlxG.keys.justPressed.RIGHT) {
            addSegment(Cardinal.E);
        }
        #end
	}
}