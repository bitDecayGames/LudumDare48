package states.teststates;

import flixel.input.keyboard.FlxKeyboard;
import generation.Perlin;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxState;

using extensions.FlxStateExt;

class MikesNoiseyState extends FlxState {
	var curX:Int = 0;
	var curY:Int = 0;
	var curZ:Int = 0;

	var sprites:Array<FlxSprite> = new Array<FlxSprite>();
	var perlin:Perlin;
	var size = 16;

	public function new() {
		super();
	}

	override public function create() {
		super.create();

		perlin = new Perlin();

		for (y in 0...size) {
			for (x in 0...size) {
				var sprite = new FlxSprite();
				sprite.makeGraphic(32, 32);
				sprite.setPosition(x * 32, y * 32);
				sprites.push(sprite);
				add(sprite);
			}
		}
		redraw();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		move();
	}

	public function redraw() {
		var scale = .1;
		for (y in 0...size) {
			for (x in 0...size) {
				var density = perlin.perlin((curX + x) * scale, (curY + y) * scale, curZ * scale);
				var color = FlxColor.WHITE;
				if (density < 0.25) {
					color = new FlxColor(0xAA708090);
				} else if (density > 0.6) {
					color = FlxColor.BLACK;
				} else {
					color = new FlxColor(0xAA8B4513);
				}
				if (curY + y < 0) {
					color = FlxColor.BLACK;
				}
				sprites[y * size + x].color = color;
			}
		}
	}

	public function move() {
		if (FlxG.keys.pressed.UP) {
			curY -= 1;
			redraw();
		} else if (FlxG.keys.pressed.DOWN) {
			curY += 1;
			redraw();
		} else if (FlxG.keys.pressed.LEFT) {
			curX -= 1;
			redraw();
		} else if (FlxG.keys.pressed.RIGHT) {
			curX += 1;
			redraw();
		} else if (FlxG.keys.justPressed.PERIOD) {
			curZ += 1;
			redraw();
		} else if (FlxG.keys.justPressed.COMMA) {
			curZ -= 1;
			redraw();
		}
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
