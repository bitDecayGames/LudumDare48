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
            0,
            0,
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

        var deltaDir = Constants.SNAKE_SPEED * delta;
        if (horizontal(direction)) {
            if (stopMovement) {
                if (direction == Cardinal.W) {
                    scrollX -= deltaDir;
                } else {
                    scrollX += deltaDir;
                }
            } else {
                if (direction == Cardinal.W) {
                    x -= deltaDir;
                } else {
                    scrollX = width % Constants.TILE_SIZE;
                }
                width += deltaDir;
            }
        } else if (vertical(direction)) {
            if (stopMovement) {
                if (direction == Cardinal.N) {
                    scrollY -= deltaDir;
                } else {
                    scrollY += deltaDir;
                }
            } else {
                if (direction == Cardinal.N) {
                    y -= deltaDir;
                } else {
                    scrollY = height % Constants.TILE_SIZE;
                }
                height += deltaDir;
            }
        }
    }
}
