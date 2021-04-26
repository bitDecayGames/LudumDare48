package entities.snake;

import flixel.math.FlxPoint;
import haxe.macro.Expr.Constant;
import flixel.util.FlxSort;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import helpers.Constants;
import spacial.Cardinal;
import flixel.math.FlxVector;

class Snake extends FlxSpriteGroup {
    var straightSegments:Array<StraightSnakeSegment>;
    var activeStraightSegment:StraightSnakeSegment;
    var curvedSegments:Array<CurvedSnakeSegment>;
    public final head:SnakeHead;

    public var searcher:SnakeSearch;

    public function new(startPos:FlxVector) {
        super();
        straightSegments = [];
        // HACK put one curved segment off screen to start
        var startCrvSeg = CurvedSnakeSegment.create(Cardinal.S, Cardinal.E);
        startCrvSeg.x = -Constants.TILE_SIZE;
        curvedSegments = [startCrvSeg];

        var startDir = Cardinal.E;
        head = new SnakeHead(FlxPoint.get(), startDir);
        head.setPosition(startPos.x, startPos.y);
        head.onNewSegment(function(prevDir, newDir) {
            addSegment(newDir);
        });
        add(head);

        addSegment(startDir);

        searcher = new SnakeSearch();
    }

    public function setTarget(t: FlxSprite) {
        head.setTarget(t, searcher);
    }

    private function addSegment(dir: Cardinal) {
        var strSeg = new StraightSnakeSegment(dir);

        if (activeStraightSegment != null) {
            var crvSeg = CurvedSnakeSegment.create(activeStraightSegment.direction, strSeg.direction);
            crvSeg.setPosition(head.x, head.y);
            curvedSegments.push(crvSeg);
            add(crvSeg);

            activeStraightSegment.stop(
                curvedSegments[curvedSegments.length - 2],
                crvSeg
            );

            var strSegVec = crvSeg.getPosition();
            if (dir.horizontal()) {
                strSegVec.x += crvSeg.width;
            } else if (dir.vertical()) {
                strSegVec.y += crvSeg.height;
            } else {
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
	}
}