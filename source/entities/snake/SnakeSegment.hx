package entities.snake;

import flixel.addons.display.FlxTiledSprite;
import flixel.util.FlxColor;
import flixel.math.FlxVector;

using extensions.FlxObjectExt;

class SnakeSegment extends FlxTiledSprite {
    private static final WIDTH = 32;
    private static final HEIGHT = 32;

    private var totalDelta:FlxVector = FlxVector.get();

    private var spriteOffset:Float = 0;

    public function new() {
        super(AssetPaths.snake_1__png, WIDTH, HEIGHT, true, false);
    }

    override public function update(delta:Float) {
        super.update(delta);

        width += 10 * delta;
        scrollX = width % WIDTH;
    }

    public function delta():FlxVector {
        return totalDelta;
    }
}
