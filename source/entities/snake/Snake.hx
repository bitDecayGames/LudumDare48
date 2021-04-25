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