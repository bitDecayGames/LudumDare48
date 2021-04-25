package entities.snake;

import spacial.Cardinal;
import flixel.FlxSprite;

class SnakeHead extends FlxSprite {
    var strSeg: StraightSnakeSegment;

    public function new() {
        super(0, 0, AssetPaths.head__png);
    }

    public function setSegment(seg: StraightSnakeSegment) {
        strSeg = seg;
    }

    override public function update(delta: Float) {
        super.update(delta);

        var x = strSeg.x + strSeg.width;
        var y = strSeg.y;
        setPosition(x, y);

        if (strSeg == null) {
            return;
        }

        if (strSeg.direction == Cardinal.E) {
            flipX = true;
        } else {
            flipX = false;
            angle = strSeg.direction;
        }
    }
}