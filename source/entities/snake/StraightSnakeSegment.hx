package entities.snake;

import flixel.addons.display.FlxTiledSprite;
import helpers.Constants;
import spacial.Cardinal;
import flixel.math.FlxRandom;
import flixel.math.FlxVector;

using extensions.FlxObjectExt;
using zero.extensions.FloatExt;

class StraightSnakeSegment extends FlxTiledSprite {
    public static final ALL_DIRECTIONS = [Cardinal.N, Cardinal.S, Cardinal.W, Cardinal.E];
    private static final rand = new FlxRandom();

    var trashLen = Constants.TILE_SIZE * 1.0;

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
            dir.horizontal(),
            dir.vertical()
        );

        direction = dir;
        directionVector = dir.asVector();
    }

    private function getAssetsPath(dir: Cardinal) {
        if (dir.horizontal()) {
            return AssetPaths.straight__png;
        } else if (dir.vertical()) {
            return AssetPaths.straightUD__png;
        }
        throw "dir " + dir + " not supported";
    }

    public function stop(prevCrv: CurvedSnakeSegment, nextCrv: CurvedSnakeSegment) {
        stopMovement = true;

        if (direction.horizontal()) {
            width = prevCrv.x - nextCrv.x - Constants.TILE_SIZE;
            snapWidth();
        } else if (direction.vertical()) {
            height = prevCrv.y - nextCrv.y - Constants.TILE_SIZE;
            snapHeight();
        }

        setPosition(x, y);
    }

    private function snapWidth() {
        width = width.snap_to_grid(Constants.TILE_SIZE);
    }

    private function snapHeight() {
        height = height.snap_to_grid(Constants.TILE_SIZE);
    }

    public override function setPosition(X:Float = 0, Y:Float = 0) {
        super.setPosition(X, Y);
        x = x.snap_to_grid(Constants.TILE_SIZE);
        y = y.snap_to_grid(Constants.TILE_SIZE);
    }

    override public function update(delta:Float) {
        super.update(delta);

        var deltaDir = Constants.SNAKE_SPEED * delta;
        if (direction.horizontal()) {
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
                if (trashLen > 0) {
                    trashLen -= deltaDir;
                } else {
                    width += deltaDir;
                }
            }
        } else if (direction.vertical()) {
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
                if (trashLen > 0) {
                    trashLen -= deltaDir;
                } else {
                    height += deltaDir;
                }
            }
        }
    }
}
