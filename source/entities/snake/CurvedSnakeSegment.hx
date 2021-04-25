package entities.snake;

import flixel.FlxSprite;
import spacial.Cardinal;

using extensions.FlxObjectExt;

class CurvedSnakeSegment extends FlxSprite {    
    public static function create(currentDirection:Cardinal, nextDirection: Cardinal) {
        var imageName = "";

        if ((currentDirection == Cardinal.E && nextDirection == Cardinal.N) ||
            (currentDirection == Cardinal.S && nextDirection == Cardinal.W)) {
            imageName = AssetPaths.ul__png;
        } else if ((currentDirection == Cardinal.E && nextDirection == Cardinal.S) ||
                    (currentDirection == Cardinal.N && nextDirection == Cardinal.W)) {
            imageName = AssetPaths.dl__png;
        } else if ((currentDirection == Cardinal.S && nextDirection == Cardinal.E) ||
                    (currentDirection == Cardinal.W && nextDirection == Cardinal.N)) {
            imageName = AssetPaths.ur__png;
        } else if ((currentDirection == Cardinal.N && nextDirection == Cardinal.E) ||
                    (currentDirection == Cardinal.W && nextDirection == Cardinal.S)) {
            imageName = AssetPaths.dr__png;
        }

        #if debug
        if (imageName == "") {
            throw "failed to create curved snake segment. cur: " + currentDirection + ", next:" + nextDirection;
        }
        #end

        return new CurvedSnakeSegment(0, 0, imageName);
    }
}
