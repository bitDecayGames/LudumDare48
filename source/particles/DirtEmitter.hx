package particles;

import flixel.FlxObject;
import flixel.util.FlxCollision;
import spacial.Cardinal;
import flixel.effects.particles.FlxEmitter;


class DirtEmitter extends FlxEmitter {
	public function new() {
		super(0, 0, 200);
		this.loadParticles(AssetPaths.dirt__png, 200);
		this.acceleration.set(0, 100);
		this.alpha.set(0.9, 1, 0, 0);
		this.lifespan.set(0.5, 1.5);
		this.scale.set(0.3, 0.3, 1, 1);
	}

	public function setDigDirection(dir:Cardinal) {
		switch(dir) {
			case N:
				this.angle.set(SE, SW);
			case S:
				this.angle.set(NW, NE);
			case E:
				this.angle.set(NE, SE);
			case W:
				this.angle.set(SW, NW);
			default:
		}
	}
}