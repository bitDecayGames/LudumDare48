package helpers;

enum abstract TileType(Int) from Int to Int {
	var EMPTY_SPACE = 0;
	var DIRT = 1;
	var ROCK = 2;
	var DUG_DIRT = 3;
}