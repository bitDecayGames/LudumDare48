package states;

import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import flixel.FlxG;
import entities.snake.SnakeSegment;

using extensions.FlxStateExt;

class JakeCTState extends FlxTransitionableState {
	var snakeSegments:Array<SnakeSegment> = [];
	
	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		var seg = new SnakeSegment(FlxColor.BLUE);
		seg.x = 200;
		snakeSegments.push(seg);
		add(seg);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
