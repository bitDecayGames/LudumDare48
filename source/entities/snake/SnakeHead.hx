package entities.snake;

import helpers.Constants;
import flixel.util.FlxPath;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.tile.FlxTilemap;
import spacial.Cardinal;
import flixel.FlxSprite;

class SnakeHead extends FlxSprite {
    private static final ANIMATION_IDLE = "anim_idle";

    var strSeg: StraightSnakeSegment;
    var map: FlxTilemap;
    var target: FlxSprite;

    public function new() {
        super();
        loadGraphic(AssetPaths.head__png, true, Constants.TILE_SIZE, Constants.TILE_SIZE);
        var framerate = 3;
        animation.add(ANIMATION_IDLE, [for (i in 0...8) i], framerate);
        animation.play(ANIMATION_IDLE);

        path = new FlxPath();
    }

    public function setSegment(seg: StraightSnakeSegment) {
        strSeg = seg;

        flipX = seg.direction == Cardinal.E;
        if (seg.direction == Cardinal.N) {
            angle = 90;
        } else if (seg.direction == Cardinal.S) {
            angle = 270;
        } else {
            angle = 0;
        }
    }

    public function setMap(m: FlxTilemap) {
        map = m;
        generatePath();
    }

    public function setTarget(t: FlxSprite) {
        target = t;
        generatePath();
    }

    public function clearTarget() {
        target = null;
        path.cancel();
    }

    private function generatePath() {
        path.cancel();

        if (map == null) {
            #if debug
            trace("map not set");
            #end
            return;
        }
        if (target == null) {
            #if debug
            trace("target not set");
            #end
            return;
        }

        var start = FlxPoint.get(x + width / 2, y + height / 2);
        var end = FlxPoint.get(target.x + target.width / 2, target.y + target.height / 2);
		var pathPoints:Array<FlxPoint> = map.findPath(
			start,
			end,
			true,
			false,
			FlxTilemapDiagonalPolicy.NONE
		);

        // if pathPoints null, cannot find path
		if (pathPoints != null) {
			path.start(pathPoints);
		} else {
            #if debug
            trace("could not generate path");
            #end
        }
    }

    override public function update(delta: Float) {
        super.update(delta);

        FlxG.collide(map, this);

		if (path.finished) {
			path.cancel();
		}

        var newPos = strSeg.getPosition();
        switch(strSeg.direction) {
            case N:
                newPos.y -= width;
            case S:
                newPos.y += strSeg.height;
            case E:
                newPos.x += strSeg.width;
            case W:
                newPos.x -= width;
            default:
                throw 'direction ${strSeg.direction} unsupported';
        }
        setPosition(newPos.x, newPos.y);
    }

    override public function draw():Void
    {
        super.draw();

        #if debug
        if (!path.finished)
        {
            drawDebug();
        }
        #end
    }
}