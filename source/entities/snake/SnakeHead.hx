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

        flipX = seg.direction == Cardinal.E;
        if (seg.direction == Cardinal.N) {
            angle = 90;
        } else if (seg.direction == Cardinal.S) {
            angle = 270;
        } else {
            angle = 0;
        }
    }

    override public function update(delta: Float) {
        super.update(delta);

        var newPos = strSeg.direction.asVector().scale(strSeg.width).add(strSeg.x, strSeg.y);
        setPosition(newPos.x, newPos.y);
    }
}