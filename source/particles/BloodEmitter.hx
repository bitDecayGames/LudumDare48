package particles;

import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.util.FlxCollision;
import spacial.Cardinal;
import flixel.effects.particles.FlxEmitter;

class BloodEmitter extends FlxEmitter {
	public function new() {
		super(0, 0, 200);
		this.loadParticles(AssetPaths.dirt__png, 200);
		color.set(FlxColor.RED, FlxColor.RED);
		this.acceleration.set(0, 100);
		this.alpha.set(0.9, 1, 0, 0);
		this.lifespan.set(0.5, 1.5);
		this.scale.set(0.3, 0.3, 1, 1);
		this.angle.set(NW, NE);
	}

	public function doBloodSplatter(x:Float, y:Float) {
		this.x = x;
		this.y = y;
		start(true);
	}
}
