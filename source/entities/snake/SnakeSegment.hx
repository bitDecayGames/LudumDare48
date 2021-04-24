package entities.snake;

import flixel.util.FlxColor;
import flixel.math.FlxVector;
import entities.RotatingTileSprite;

using extensions.FlxObjectExt;

class SnakeSegment extends RotatingTiledSprite {
    private static final WIDTH = 32;
    private static final HEIGHT = 16;

    private var center:FlxVector = FlxVector.get();
    private var lastCenter:FlxVector = FlxVector.get();

    private var totalDelta:FlxVector = FlxVector.get();

    private var spriteOffset:Float = 0;

    public function new(color: FlxColor) {
        super(WIDTH, HEIGHT, true, false);
        makeGraphic(WIDTH, HEIGHT, color);
    }

    public function setSpriteOffset(o:Float) {
        spriteOffset = o;
    }

    public function getSpriteOffsetAmount():Float {
        return this.width % WIDTH;
    }

    override public function update(delta:Float) {
        super.update(delta);

        lastCenter.copyFrom(center);

        this.width = WIDTH;  
        scrollX = spriteOffset;

        this.setPositionMidpoint(center.x, center.y);
    }

    public function delta():FlxVector {
        totalDelta.copyFrom(center).subtractPoint(lastCenter);
        return totalDelta;
    }
}
