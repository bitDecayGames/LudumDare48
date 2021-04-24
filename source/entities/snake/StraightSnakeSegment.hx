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
        return new StraightSnakeSegment(Cardinal.N.asVector());
    }

    public static function down() {
        return new StraightSnakeSegment(Cardinal.S.asVector());
    }

    public static function left() {
        return new StraightSnakeSegment(Cardinal.W.asVector());
    }

    public static function right() {
        return new StraightSnakeSegment(Cardinal.E.asVector());
    }

    public static function random() {
        return new StraightSnakeSegment(rand.getObject(ALL_DIRECTIONS).asVector());
    }

    private static final WIDTH = 32;
    private static final HEIGHT = 32;
    private static final SPEED = 20;

    public final direction:FlxVector;

    private var spriteOffset:Float = 0;
    private var stopMovement = false;

    public function new(direction:FlxVector) {
        super(AssetPaths.snake_1__png, WIDTH, HEIGHT, direction.x != 0, direction.y != 0);
        this.direction = direction;
    }

    public function stop() {
        stopMovement = true;
    }

    override public function update(delta:Float) {
        super.update(delta);

        if (direction.x != 0) {
            var dx = direction.x * SPEED * delta;
            if (stopMovement) {
                scrollX += dx;
            } else {
                width += dx;
                scrollX = width % WIDTH;
            }

        } else if (direction.y != 0) {
            var dy = direction.y * SPEED * delta;
            if (stopMovement) {
                scrollY += dy;
            } else {
                height += dy;
                scrollY = height % HEIGHT;
            }
        }
    }
}
