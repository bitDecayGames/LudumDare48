package entities.snake;

import flixel.addons.display.FlxTiledSprite;
import helpers.Constants;
import spacial.Cardinal;
import flixel.math.FlxRandom;
import flixel.math.FlxVector;

using extensions.FlxObjectExt;

class StraightSnakeSegment extends FlxTiledSprite {
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

    public function new(dir:Cardinal) {
        super(
            getAssetsPath(dir),
            Constants.TILE_SIZE,
            Constants.TILE_SIZE,
            horizontal(dir),
            vertical(dir)
        );

        direction = dir;
        directionVector = dir.asVector();
    }

    private function getAssetsPath(dir: Cardinal) {
        if (horizontal(dir)) {
            return AssetPaths.straight__png;
        } else if (vertical(dir)) {
            return AssetPaths.straightUD__png;
        }
        throw "dir " + dir + " not supported";
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

        var deltaDir = directionVector.length * Constants.SNAKE_SPEED * delta;
        if (horizontal(direction)) {
            if (stopMovement) {
                scrollX += deltaDir;
            } else {
                if (direction == Cardinal.W) {
                    x -= deltaDir;
                }
                width += deltaDir;
                scrollX = width % Constants.TILE_SIZE;
            }
        } else if (vertical(direction)) {
            if (stopMovement) {
                scrollY -= deltaDir;
            } else {
                if (direction == Cardinal.N) {
                    y -= deltaDir;
                }
                height += deltaDir;
                scrollY = -1 * (height % Constants.TILE_SIZE);
            }
        }
    }
}
