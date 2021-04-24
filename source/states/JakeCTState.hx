package states;

import flixel.math.FlxVector;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import entities.snake.Snake;

using extensions.FlxStateExt;

class JakeCTState extends FlxTransitionableState {
	var snake:Snake;

	override public function create() {
		super.create();

		FlxG.debugger.visible = true;

		FlxG.camera.bgColor = FlxColor.WHITE;
		FlxG.camera.pixelPerfectRender = true;

		var snakeStart = FlxVector.get(0, FlxG.height / 2);
		snake = new Snake(snakeStart);
		add(snake);
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
