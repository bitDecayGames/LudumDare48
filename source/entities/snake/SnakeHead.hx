package entities.snake;

import flixel.FlxSprite;

class SnakeHead extends FlxSprite {
    public function new() {
        super(0, 0, AssetPaths.head__png);
    }
}