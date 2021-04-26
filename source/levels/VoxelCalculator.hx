package levels;

import generation.Perlin;

class VoxelCalculator {

	public static final instance:VoxelCalculator = new VoxelCalculator();

	public var perlin:Perlin;
	public var modified:Map<String, Int>;
	public var scale:Float = 0.2;
	public var leftBound:Int = -10;
	public var rightBound:Int = 10;
	public var foreBound:Int = 3;
	public var backBound:Int = -3;

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
		if (x < leftBound || x > rightBound || z < backBound || z > foreBound) {
			return 2;
		}
		if (y < 0) {
			// return air if y is less than 0 since that means we are at ground level
			return 0;
		}
		var key = getKey(x, y, z);
		if (modified.exists(key)) {
			return modified.get(key);
		}
		var density = perlin.perlin(x * scale, y * scale, z * scale);
		if (density < 0.4) { // increase this number for more rocks
			#if dirt
			return 1;
			#else
			return 2;
			#end
		} else if (density > 0.7) { // decrease this number for more caves
			return 0;
		} else {
			return 1;
		}
	}

	// Returns a 1D array of the points in the block (to save on memory allocation of embedded arrays)
	public function getBlock(x:Int, y:Int, z:Int, width:Int, height:Int):Array<Array<Int>> {
		var block = new Array<Array<Int>>();
		for (i in 0...height) {
			block.push(new Array<Int>());
			for (k in 0...width) {
				block[i].push(get(x+k, y+i, z));
			}
		}

		return block;
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
		return this;
	}

	private function getKey(x:Int, y:Int, z:Int):String {
		return "" + x + "," + y + "," + z;
	}
}
