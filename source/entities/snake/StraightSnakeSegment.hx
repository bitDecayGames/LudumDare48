package entities.snake;

import spacial.Cardinal;
import flixel.math.FlxRandom;
import flixel.addons.display.FlxTiledSprite;
import flixel.math.FlxVector;

using extensions.FlxObjectExt;

class StraightSnakeSegment extends FlxTiledSprite {
    public static final ALL_DIRECTIONS = [Cardinal.N, Cardinal.S, Cardinal.W, Cardinal.E];
    private static final rand = new FlxRandom();

    public static function up() {
        return new StraightSnakeSegment(Cardinal.N);
    }

    public static function down() {
        return new StraightSnakeSegment(Cardinal.S);
    }

    public static function left() {
        return new StraightSnakeSegment(Cardinal.W);
    }

    public static function right() {
        return new StraightSnakeSegment(Cardinal.E);
    }

    public static function randomDir(curDir: Cardinal) {
        var arrCpy = ALL_DIRECTIONS.copy();
        arrCpy.remove(curDir);
        arrCpy.remove(curDir.reverse());
        return rand.getObject(arrCpy);
    }

    private static final WIDTH = 32;
    private static final HEIGHT = 32;
    private static final SPEED = 20;

    public final direction:Cardinal;
    public final directionVector:FlxVector;

    private var spriteOffset:Float = 0;
    private var stopMovement = false;

    public function new(direction:Cardinal) {
        super(
            AssetPaths.straight__png, WIDTH, HEIGHT,
            horizontal(direction),
            vertical(direction)
        );
        if (direction == Cardinal.W) {
            flipY = true;
        } else if (direction == Cardinal.N) {
            angle = 90;
        } else if (direction == Cardinal.S) {
            angle = 270;
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

        if (horizontal(direction)) {
            var dx = directionVector.x * SPEED * delta;
            if (stopMovement) {
                scrollX += dx;
            } else {
                width += dx;
                scrollX = width % WIDTH;
            }

        } else if (vertical(direction)) {
            var dy = directionVector.y * SPEED * delta;
            if (stopMovement) {
                scrollY += dy;
            } else {
                height += dy;
                scrollY = height % HEIGHT;
            }
        }
    }
}
