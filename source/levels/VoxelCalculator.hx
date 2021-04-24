package levels;

import generation.Perlin;

class VoxelCalculator {
	public var perlin:Perlin;
	public var modified:Map<String, Int>;
	public var scale:Float = 0.2;

	public function new() {
		perlin = new Perlin();
		modified = new Map<String, Int>();
	}

	/**
	 * Get the type of voxel at a given world x,y,z
	 * @param x
	 * @param y
	 * @param z
	 * @return Int [0: empty air, 1: dirt, 2: solid rock]
	 */
	public function get(x:Int, y:Int, z:Int):Int {
		if (y < 0) {
			// return air if y is less than 0 since that means we are at ground level
			return 0;
		}
		var key = getKey(x, y, z);
		if (modified.exists(key)) {
			trace("Get back modified voxel at " + key);
			return modified.get(key);
		}
		var density = perlin.perlin(x * scale, y * scale, z * scale);
		if (density < 0.25) { // increase this number for more rocks
			return 2;
		} else if (density > 0.7) { // decrease this number for more caves
			return 0;
		} else {
			return 1;
		}
	}

	/**
	 * Manually set the voxel type at a given world x,y,z coordinate to overwrite what ever the perlin noise would have said was there.
	 * @param x
	 * @param y
	 * @param z
	 * @param value [0: empty air, 1: dirt, 2: solid rock]
	 * @return VoxelCalculator
	 */
	public function set(x:Int, y:Int, z:Int, value:Int):VoxelCalculator {
		modified.set(getKey(x, y, z), value);
		trace("Set calc " + getKey(x, y, z));
		return this;
	}

	private function getKey(x:Int, y:Int, z:Int):String {
		return "" + x + "," + y + "," + z;
	}
}
