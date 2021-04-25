package entities.snake;

import flixel.FlxSprite;
import spacial.Cardinal;

using extensions.FlxObjectExt;

class CurvedSnakeSegment extends FlxSprite {

    public static inline var LOOPS_PER_STRAIGHT_SEGMENT_LENGTH = 6;
    public static inline var FRAMES_PER_SCALE = 4;

    public static function create(currentDirection:Cardinal, nextDirection: Cardinal) {
        var assetPath = "";

        if ((currentDirection == Cardinal.E && nextDirection == Cardinal.N) ||
            (currentDirection == Cardinal.S && nextDirection == Cardinal.W)) {
            assetPath = AssetPaths.ul__png;
        } else if ((currentDirection == Cardinal.E && nextDirection == Cardinal.S) ||
                    (currentDirection == Cardinal.N && nextDirection == Cardinal.W)) {
            assetPath = AssetPaths.dl__png;
        } else if ((currentDirection == Cardinal.S && nextDirection == Cardinal.E) ||
                    (currentDirection == Cardinal.W && nextDirection == Cardinal.N)) {
            assetPath = AssetPaths.ur__png;
        } else if ((currentDirection == Cardinal.N && nextDirection == Cardinal.E) ||
                    (currentDirection == Cardinal.W && nextDirection == Cardinal.S)) {
            assetPath = AssetPaths.dr__png;
        }

        #if debug
        if (assetPath == "") {
            throw "failed to create curved snake segment. cur: " + currentDirection + ", next:" + nextDirection;
        }
        #end

        return new CurvedSnakeSegment(assetPath);
    }

    public function new(path:String) {
        super(0, 0);
        loadGraphic(path, true, 32, 32);
        animation.add("move", [0,1,2,3], 10);
        animation.play("move");
    }

    public function straightLengthsPerSecond(lps:Float) {
        var scalesPerSecond = lps / 6;
        animation.getByName("move").frameRate = scalesPerSecond * FRAMES_PER_SCALE;
    }
}
