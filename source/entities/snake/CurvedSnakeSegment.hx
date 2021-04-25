package entities.snake;

import helpers.Constants;
import flixel.FlxSprite;
import spacial.Cardinal;

using extensions.FlxObjectExt;
using zero.extensions.FloatExt;

class CurvedSnakeSegment extends FlxSprite {
    public final startDir: Cardinal;
    public final endDir: Cardinal;

    public static function create(currentDirection:Cardinal, nextDirection: Cardinal) {
        var assetPath = "";

        var reverse = false;

        if (currentDirection == Cardinal.E && nextDirection == Cardinal.N) {
            assetPath = AssetPaths.ul__png;
        } else if (currentDirection == Cardinal.S && nextDirection == Cardinal.W) {
            assetPath = AssetPaths.ul__png;
            reverse = true;
        } else if (currentDirection == Cardinal.E && nextDirection == Cardinal.S) {
            assetPath = AssetPaths.dl__png;
        } else if (currentDirection == Cardinal.N && nextDirection == Cardinal.W) {
            assetPath = AssetPaths.dl__png;
            reverse = true;
        } else if (currentDirection == Cardinal.S && nextDirection == Cardinal.E) {
            assetPath = AssetPaths.ur__png;
        } else if (currentDirection == Cardinal.W && nextDirection == Cardinal.N) {
            assetPath = AssetPaths.ur__png;
            reverse = true;
        } else if (currentDirection == Cardinal.N && nextDirection == Cardinal.E) {
            assetPath = AssetPaths.dr__png;
        } else if (currentDirection == Cardinal.W && nextDirection == Cardinal.S) {
            assetPath = AssetPaths.dr__png;
            reverse = true;
        }

        #if debug
        if (assetPath == "") {
            throw "failed to create curved snake segment. cur: " + currentDirection + ", next:" + nextDirection;
        }
        #end

        return new CurvedSnakeSegment(assetPath, reverse, currentDirection, nextDirection);
    }

    public function new(path:String, reverse:Bool, startDir: Cardinal, endDir: Cardinal) {
        super(0, 0);
        loadGraphic(path, true, 32, 32);

        // first get tiles per second in snake speed
        var fps = Constants.TILE_SIZE / Constants.SNAKE_SPEED;

        // times number of scales per snake tile gets us to SCALES PER SECOND
        fps *= 6;

        // times number of frames per scale in the corner piece animation gets us to FRAMES PER SECOND
        fps *= 4;

        var frames = [0,1,2,3];
        if (reverse) {
            frames.reverse();
        }
        animation.add("move", frames, fps);
        animation.play("move");

        this.startDir = startDir;
        this.endDir = endDir;
    }

    public override function setPosition(X:Float = 0, Y:Float = 0) {
        super.setPosition(X, Y);
        x = x.snap_to_grid(Constants.TILE_SIZE);
        y = y.snap_to_grid(Constants.TILE_SIZE);
    }
}
