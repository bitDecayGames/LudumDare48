package entities.snake;

import flixel.FlxG;
import helpers.Constants;
import entities.RotatingTileSprite.RotatingTiledSprite;
import spacial.Cardinal;
import flixel.math.FlxRandom;
import flixel.math.FlxVector;

using extensions.FlxObjectExt;

class StraightSnakeSegment extends RotatingTiledSprite {
    public static final ALL_DIRECTIONS = [Cardinal.N, Cardinal.S, Cardinal.W, Cardinal.E];
    private static final rand = new FlxRandom();

    public static function randomDir(curDir: Cardinal) {
        var arrCpy = ALL_DIRECTIONS.copy();
        arrCpy.remove(curDir);
        arrCpy.remove(curDir.reverse());
        return rand.getObject(arrCpy);
    }

    public final direction:Cardinal;
    public final directionVector:FlxVector;

    private var stopMovement = false;

    public function new(direction:Cardinal) {
        super(
            AssetPaths.straight__png,
            Constants.TILE_SIZE,
            Constants.TILE_SIZE,
            true,
            false
        );
        if (direction == Cardinal.N) {
            angle = 270;
        } else if (direction == Cardinal.S) {
            angle = 90;
        }
        this.direction = direction;
        this.directionVector = direction.asVector();
    }

    private function vertical(dir: Cardinal): Bool {
        return dir == Cardinal.N || dir == Cardinal.S;
    }

    private function horizontal(dir: Cardinal): Bool {
        return dir == Cardinal.W || dir == Cardinal.E;
    }

    public function stop() {
        stopMovement = true;
    }

    override public function update(delta:Float) {
        super.update(delta);

        var dx = directionVector.length * Constants.SNAKE_SPEED * delta;
        if (stopMovement) {
            scrollX += dx;
        } else {
            width += dx;
            scrollX = width % Constants.TILE_SIZE;
        }
    }
}
