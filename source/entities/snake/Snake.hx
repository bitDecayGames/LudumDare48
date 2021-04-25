package entities.snake;

import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import helpers.Constants;
import spacial.Cardinal;
import flixel.FlxG;
import flixel.math.FlxVector;
import flixel.group.FlxGroup;

class Snake extends FlxGroup {
    var straightSegments:Array<StraightSnakeSegment>;
    var activeStraightSegment:StraightSnakeSegment;
    var curvedSegments:Array<CurvedSnakeSegment>;
    public final head:SnakeHead;

    public function new(startPos:FlxVector) {
        super();
        straightSegments = [];
        curvedSegments = [];

        head = new SnakeHead();
        add(head);

        addSegment(Cardinal.E);
        activeStraightSegment.setPosition(startPos.x, startPos.y);
    }

    public function setMap(m: FlxTilemap) {
        head.setMap(m);
    }

    public function setTarget(t: FlxSprite) {
        head.setTarget(t);
    }

    private function addSegment(dir: Cardinal) {
        var strSeg = new StraightSnakeSegment(dir);

        if (activeStraightSegment != null) {
            activeStraightSegment.stop();

            var crvPos = activeStraightSegment.getPosition();
            switch(activeStraightSegment.direction) {
                case N:
                    crvPos.y -= Constants.TILE_SIZE;
                case S:
                    crvPos.y += activeStraightSegment.height;
                case E:
                    crvPos.x += activeStraightSegment.width;
                case W:
                    crvPos.x -= Constants.TILE_SIZE;
                default:
                    throw 'direction ${activeStraightSegment.direction} unsupported';
            }
            var crvSeg = CurvedSnakeSegment.create(activeStraightSegment.direction, strSeg.direction);
            crvSeg.setPosition(crvPos.x, crvPos.y);
            curvedSegments.push(crvSeg);
            add(crvSeg);

            var strSegVec = crvSeg.getPosition();
            switch(dir) {
                case N:
                    strSegVec.y -= strSeg.height;
                case S:
                    strSegVec.y += crvSeg.height;
                case E:
                    strSegVec.x += crvSeg.width;
                case W:
                    strSegVec.x -= strSeg.width;
                default:
                    throw 'direction ${strSeg.direction} unsupported';
            }
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