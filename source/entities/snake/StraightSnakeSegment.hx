package entities.snake;

import flixel.math.FlxRandom;
import flixel.addons.display.FlxTiledSprite;
import flixel.math.FlxVector;

using extensions.FlxObjectExt;

class StraightSnakeSegment extends FlxTiledSprite {
    public static final UP = FlxVector.get(0, 1);
    public static final DOWN = FlxVector.get(0, -1);
    public static final LEFT = FlxVector.get(-1, 0);
    public static final RIGHT = FlxVector.get(1, 0);
    public static final ALL_DIRECTIONS = [UP, DOWN, LEFT, RIGHT];
    private static final rand = new FlxRandom();

    public static function up() {
        return new StraightSnakeSegment(UP);
    }

    public static function down() {
        return new StraightSnakeSegment(DOWN);
    }

    public static function left() {
        return new StraightSnakeSegment(LEFT);
    }

    public static function right() {
        return new StraightSnakeSegment(RIGHT);
    }

    public static function random() {
        return new StraightSnakeSegment(rand.getObject(ALL_DIRECTIONS));
    }

    private static final WIDTH = 32;
    private static final HEIGHT = 32;
    private static final SPEED = 15;

    public final direction:FlxVector;

    private var spriteOffset:Float = 0;
    private var stopMovement = false;

    public function new(direction:FlxVector) {
        super(AssetPaths.snake_1__png, WIDTH, HEIGHT, direction.x != 0, direction.y != 0);
        this.direction = direction;
    }

    public function setSpriteOffset(o:Float) {
		spriteOffset = o;
	}

	public function getSpriteOffsetAmount():Float {
		var length = 0.0;
        var modulo = 0;
        if (direction.equals(UP) || direction.equals(DOWN)) {
            length = height;
            modulo = HEIGHT;
        } else if (direction.equals(LEFT) || direction.equals(RIGHT)) {
            length = width;
            modulo = WIDTH;
        }

        return length % modulo;
	}

    public function stop() {
        stopMovement = true;
    }

    override public function update(delta:Float) {
        super.update(delta);

        if (direction.x != 0) {
            if (!stopMovement) {
                width += direction.x * SPEED * delta;
            }
            scrollX = width % WIDTH;
        } else if (direction.y != 0) {
            if (!stopMovement) {
                height += direction.y * SPEED * delta;
            }
            scrollY = height % HEIGHT;
        }
    }
}
