package entities.snake;

import flixel.util.FlxSort;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import helpers.Constants;
import spacial.Cardinal;
import flixel.FlxG;
import flixel.math.FlxVector;

class Snake extends FlxSpriteGroup {
    var straightSegments:Array<StraightSnakeSegment>;
    var activeStraightSegment:StraightSnakeSegment;
    var curvedSegments:Array<CurvedSnakeSegment>;
    public final head:SnakeHead;

    public function new(startPos:FlxVector) {
        super();
        straightSegments = [];
        // HACK put one curved segment off screen to start
        curvedSegments = [CurvedSnakeSegment.create(Cardinal.S, Cardinal.E)];

        var startDir = Cardinal.E;
        head = new SnakeHead(startDir);
        head.setPosition(startPos.x, startPos.y);
        head.onNewSegment(function(prevDir, newDir) {
            addSegment(newDir);
        });
        add(head);

        addSegment(startDir);
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
            // var crvPos: FlxVector = head.getPosition();
            // switch(activeStraightSegment.direction) {
            //     case N:
            //         crvPos.y -= Constants.TILE_SIZE;
            //     case S:
            //         crvPos.y += activeStraightSegment.height;
            //     case E:
            //         crvPos.x += activeStraightSegment.width;
            //     case W:
            //         crvPos.x -= Constants.TILE_SIZE;
            //     default:
            //         throw 'direction ${activeStraightSegment.direction} unsupported';
            // }
            var crvSeg = CurvedSnakeSegment.create(activeStraightSegment.direction, strSeg.direction);
            crvSeg.setPosition(head.x, head.y);
            curvedSegments.push(crvSeg);
            add(crvSeg);

            activeStraightSegment.stop(curvedSegments[curvedSegments.length - 2].getPosition(), crvSeg.getPosition());

            var strSegVec = crvSeg.getPosition();
            switch(dir) {
                case N:
                    // no-op, N already in right spot
                case S:
                    strSegVec.y += crvSeg.height;
                case E:
                    strSegVec.x += crvSeg.width;
                case W:
                    // no-op, W already in right spot
                default:
                    throw 'direction ${strSeg.direction} unsupported';
            }
            strSeg.setPosition(strSegVec.x, strSegVec.y);
        }

        activeStraightSegment = strSeg;
        straightSegments.push(strSeg);
		add(strSeg);
    }

    override public function update(elapsed:Float) {
		super.update(elapsed);

        // TODO Get snake head sorting above rest of snake body
        // sort(SnakeHeadSorter.sort, FlxSort.ASCENDING);

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