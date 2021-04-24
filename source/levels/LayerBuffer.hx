package levels;

import flixel.tile.FlxTilemap;

class LayerBuffer extends FlxTilemap {
	public var tilemap:FlxTilemap;

	// NOTE: This array is indexed as [y][x] due to how FlxTilemap loads them
	var local:Array<Array<Int>> = new Array<Array<Int>>();

	public function new(width:Int, height:Int) {
		super();
		local = [for(i in 0...height) [for(k in 0...width) 1]];
		tilemap = new FlxTilemap();
		trace('width: ${local.length}   height: ${local[0].length}');
		reload();
	}

	public function pushOntoLeft(column:Array<Int>) {
		for(i in 0...local.length) {
			local[i].pop();
			local[i].unshift(column[i]);
		}
		reload();
	}

	public function pushOntoRight(column:Array<Int>) {
		for(i in 0...local.length) {
			local[i].shift();
			local[i].push(column[i]);
		}
		reload();
	}

	public function pushOntoTop(row:Array<Int>) {
			local.pop();
			local.unshift(row);
			reload();
		}

	public function pushOntoBottom(row:Array<Int>) {
		local.shift();
		local.push(row);
		reload();
	}

	public function reload() {
		loadMapFrom2DArray(local, AssetPaths.testTiles__png, 32, 32);
	}

	public function dump() {
		trace(local);
	}
}