package levels;

import haxe.macro.Expr.Constant;
import helpers.TileType;
import entities.MoveResult;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import helpers.Constants;
import spacial.Cardinal;
import flixel.tile.FlxTilemap;
import entities.MoleFriend;
import entities.Player;
import states.PlayState;
using extensions.FlxStateExt;
using zero.flixel.extensions.FlxTilemapExt;
using Math;
import flixel.math.FlxRandom;

class LayerBufferStack extends FlxTypedGroup<LayerBuffer> {
	private static final rand = new FlxRandom();

	public var layers:Array<LayerBuffer> = new Array<LayerBuffer>();
	public var invisibleForeLayer:LayerBuffer;

	public var calculator:VoxelCalculator;
	public var moleFriends:Array<MoleFriend>;
	public var playState:PlayState;
	public var deepestY:Int;

	public function new(width:Int, height:Int, padding:Int) {
		super();
		calculator = new VoxelCalculator();
		for (i in 0...3) {
			var l = new LayerBuffer(width, height, padding, calculator);
			l.worldZ = i;
			l.setTarget(1.0 - i * 0.05, // target scale
				1 - i * 0.3, // target tint
				1.0); // target alpha
			setEntireBufferTileTypes(l);
			layers.push(l);
		}
		for (i in 0...3) {
			add(layers[layers.length - 1 - i]);
		}
		var i = -1;
		invisibleForeLayer = new LayerBuffer(width, height, padding, calculator);
		invisibleForeLayer.alpha = 0.0;
		invisibleForeLayer.worldZ = -1;
		setEntireBufferTileTypes(invisibleForeLayer);
		add(invisibleForeLayer);
		moleFriends = new Array<MoleFriend>();
		deepestY = 10;
	}

	public function addMoleFriend(x:Int, y:Int) {
		var moleFriend = new MoleFriend();
		moleFriend.x = x;
		moleFriend.y = y;
		trace('adding a friend at: (${x}, ${y}))');
		moleFriends.push(moleFriend);
		playState.add(moleFriend);
	}

	public function spawnMoleFriend(tileY:Int) {
		var main = layers[0];
		trace('trying to spawn a friend');
		if (rand.float(0, 1) > .99) {
			trace('not spawning due to probability');
			return;
		}
		trace('bufWidth: ${main.bufWidth}');
		for (tileX in 0...main.bufWidth) {
			trace('checking if (${tileX}, ${tileY}) is empty');
			if (main.tileIsType(tileX, tileY, TileType.EMPTY_SPACE)) {
				trace('found a place to put a friend');
				addMoleFriend(tileX * Constants.TILE_SIZE, tileY * Constants.TILE_SIZE);
				break;
			} 
		}
	}

	public function makeFriendsFollowPlayer(player:Player) {
		for (moleFriend in moleFriends) {
			if (player.x == moleFriend.x && player.y == moleFriend.y && moleFriend.moleIdLikeToFollow == null) {
				player.setFollower(moleFriend);
			}
		}
	}

	public function movePlayer(dir:Cardinal, playerPos:FlxPoint):MoveResult {
		var main = layers[0];
		var tileMovement = dir.asVector().scale(Constants.TILE_SIZE);

		// figure out the world coordinates of where the player wants to be
		var worldTarget = new FlxPoint(playerPos.x, playerPos.y);
		worldTarget.addPoint(tileMovement);

		// figure out the tilemap coordinates within the buffer
		var bufferTarget = FlxPoint.get().copyFrom(worldTarget);
		bufferTarget.subtract(main.worldX * Constants.TILE_SIZE, main.worldY * Constants.TILE_SIZE);
		bufferTarget.x -= 10;
		bufferTarget.y -= 10;

		var targetTile = main.getTileTypeFromPoint(bufferTarget);

		// 2 is rocks for now... can't move into those
		if (targetTile != TileType.ROCK) {
			if (targetTile == TileType.DIRT) {
				var x = (bufferTarget.x / main.get_tile_width()).floor();
				var y = (bufferTarget.y / main.get_tile_height()).floor();
				main.setTile(x, y, TileType.DUG_DIRT);
				calculator.set(((worldTarget.x - 10) / Constants.TILE_SIZE).floor(), ((worldTarget.y - 10) / Constants.TILE_SIZE).floor(), main.worldZ,
					Constants.AFTER_DIG);
				// TODO: SFX dug through dirt here
			}

			// buffer is slightly bigger than screen, so we position it so it's centered correctly
			var x = worldTarget.x - 8 * Constants.TILE_SIZE;
			var y = worldTarget.y - 12 * Constants.TILE_SIZE;
			for (i in 0...layers.length) {
				layers[i].pushData(dir, getNextLevelData(dir, layers[i]));
				layers[i].setPosition(x, y);
			}
			invisibleForeLayer.pushData(dir, getNextLevelData(dir, invisibleForeLayer));
			invisibleForeLayer.setPosition(x, y);
		
			return new MoveResult(worldTarget, targetTile, false);
		} else {
			// TODO: SFX tried to dig through rock here
		}
		return null;
	}

	public function fallPlayer(playerPos:FlxPoint):MoveResult {
		var main = layers[0];

		var bufferTarget = FlxPoint.get().copyFrom(playerPos);
		bufferTarget.subtract(main.worldX * Constants.TILE_SIZE, main.worldY * Constants.TILE_SIZE);
		bufferTarget.x -= 10;
		bufferTarget.y -= 10;

		var leftHand = !isEmpty(main.getTileTypeFromPoint(FlxPoint.get().copyFrom(bufferTarget).addPoint(Cardinal.W.asVector().scale(Constants.TILE_SIZE))));
		var leftFoot = !isEmpty(main.getTileTypeFromPoint(FlxPoint.get().copyFrom(bufferTarget).addPoint(Cardinal.SW.asVector().scale(Constants.TILE_SIZE))));
		var rightHand = !isEmpty(main.getTileTypeFromPoint(FlxPoint.get().copyFrom(bufferTarget).addPoint(Cardinal.E.asVector().scale(Constants.TILE_SIZE))));
		var rightFoot = !isEmpty(main.getTileTypeFromPoint(FlxPoint.get().copyFrom(bufferTarget).addPoint(Cardinal.SE.asVector().scale(Constants.TILE_SIZE))));
		var peen = !isEmpty(main.getTileTypeFromPoint(FlxPoint.get().copyFrom(bufferTarget).addPoint(Cardinal.S.asVector().scale(Constants.TILE_SIZE))));

		var shouldFall = !(leftHand && rightHand) && !(leftFoot && rightFoot) && !peen;
		if (shouldFall) {
			var result = movePlayer(Cardinal.S, playerPos);
			result.isFalling = true;
			return result;
		}
		return null;
	}

	private function isEmpty(tileType:Int):Bool {
		return tileType == Constants.EMPTY_SPACE || tileType == Constants.DUG_DIRT;
	}

	private function isDiggable(tileType:Int):Bool {
		return tileType != Constants.ROCK;
	}

	public function switchLayer(dir:Int, playerPos:FlxPoint, onFinish:Void->Void):Bool {
		if (dir != -1 && dir != 1) {
			trace("You are not allowed to move more than one layer at a time");
			return false;
		}

		var main = layers[0];
		var cellToDigInto = [
			((playerPos.x - 10) / Constants.TILE_SIZE)
			.floor(),
			((playerPos.y - 10) / Constants.TILE_SIZE)
			.floor(),
			main.worldZ + dir,
		];
		var allowableDig = isDiggable(calculator.get(cellToDigInto[0], cellToDigInto[1], cellToDigInto[2]));

		if (allowableDig) {
			calculator.set(cellToDigInto[0], cellToDigInto[1], cellToDigInto[2], Constants.AFTER_DIG);
			for (i in 0...layers.length) {
				var l = layers[i];
				l.worldZ += dir;

				var startAlpha = 1.0;
				if (dir < 0 && i == 0) {
					startAlpha = 0.0;
				}
				l.setCurrent(1.0 - (i + dir) * 0.1, 1 - (i + dir) * 0.3, startAlpha);
				l.setTarget(1.0 - i * 0.1, 1 - i * 0.3, 1.0);
				setEntireBufferTileTypes(l);

				if (i == 0) {
					l.onReachedTarget = onFinish;
				}
			}
			invisibleForeLayer.worldZ += dir;
			if (dir > 0) {
				var i = -1.0;
				invisibleForeLayer.setCurrent(1.0 - (i + dir) * 0.1, 1 - (i + dir) * 0.3, 1.0);
				invisibleForeLayer.setTarget(1.0 - i * 0.1, 1 - i * 0.3, 0.0);
			}
			setEntireBufferTileTypes(invisibleForeLayer);
			return true;
		} else {
			// TODO: SFX tried to dig through rock here
		}
		return false;
	}

	public function getNextLevelData(dir:Cardinal, buffer:LayerBuffer):Array<Int> {
		return switch (dir) {
			case N:
				getWorldDataRow(buffer.worldX, buffer.worldY - 1, buffer.worldZ, buffer.bufWidth);
			case S:
				getWorldDataRow(buffer.worldX, buffer.worldY + buffer.bufHeight + 1, buffer.worldZ, buffer.bufWidth);
			case E:
				getWorldDataColumn(buffer.worldX + buffer.bufWidth + 1, buffer.worldY, buffer.worldZ, buffer.bufHeight);
			case W:
				getWorldDataColumn(buffer.worldX - 1, buffer.worldY, buffer.worldZ, buffer.bufHeight);
			default:
				throw('cannot request level data for direction ${dir}');
		}
	}

	public function setEntireBufferTileTypes(buffer:LayerBuffer) {
		buffer.setEntireBufferTileTypes();
	}

	public function getWorldDataRow(x:Int, y:Int, z:Int, num:Int):Array<Int> {
		var tiles:Array<Int> = [];
	
		
		for (i in 0...num) {
			tiles.push(calculator.get(x + i, y, z));
		}
		if (y > deepestY) {
			spawnMoleFriend(y);
		}
		return tiles;
	}

	public function getWorldDataColumn(x:Int, y:Int, z:Int, num:Int):Array<Int> {
		var tiles:Array<Int> = [];
		for (i in 0...num) {
			tiles.push(calculator.get(x, y + i, z));
		}
		return tiles;
	}
}
