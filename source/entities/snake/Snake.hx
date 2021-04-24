package entities.snake;

import flixel.math.FlxVector;
import flixel.group.FlxGroup;

class Snake extends FlxGroup {
    var activeSegment:SnakeSegment;
    var startPos:FlxVector;

    public function new(startPos:FlxVector) {
        super();

        addSegment();
        activeSegment.setPosition(startPos.x, startPos.y);
    }

    private function addSegment() {
        var newSeg = new SnakeSegment();  
        
        if (activeSegment != null) {
            activeSegment.alive = false;
            var activePos = activeSegment.getPosition();
            newSeg.setPosition(activePos.x, activePos.x);
        }

        activeSegment = newSeg;
		add(newSeg);
    }
}