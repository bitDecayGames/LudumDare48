package entities;

import flixel.FlxG;
import input.SimpleController;
import particles.DirtEmitter;
import flixel.FlxSprite;
import zero.extensions.StringExt;
import helpers.TileType;
import input.InputCalcuator;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import spacial.Cardinal;
import flixel.util.FlxColor;
import helpers.Constants;

using extensions.FlxPointExt;
using zero.extensions.StringExt;

class Player extends Moleness {
	private static inline var IDLE_LEFT = "idleLeft";
	private static inline var IDLE_RIGHT = "idleRight";
	private static inline var IDLE_UP = "idleUp";
	private static inline var IDLE_DOWN = "idleDown";

	private static inline var WALK_RIGHT = "walkRight";
	private static inline var WALK_LEFT = "walkLeft";
	private static inline var TURN_RIGHT_TO_LEFT = "turnRightLeft";
	private static inline var TURN_LEFT_TO_RIGHT = "turnLeftRight";

	private static inline var WALK_IN = "walkIn";
	private static inline var WALK_OUT = "walkOut";


	private static inline var WALK_UP = "walkUp";
	private static inline var WALK_DOWN = "walkDown";
	private static inline var TURN_UP_TO_DOWN = "turnUpDown";
	private static inline var TURN_DOWN_TO_UP = "turnDownUp";

	private static inline var TURN_UP_TO_RIGHT = "turnUpRight";
	private static inline var TURN_UP_TO_LEFT = "turnUpLeft";

	private static inline var TURN_DOWN_TO_RIGHT = "turnDownRight";
	private static inline var TURN_DOWN_TO_LEFT = "turnDownLeft";

	private static inline var TURN_LEFT_TO_UP = "turnLeftUp";
	private static inline var TURN_LEFT_TO_DOWN = "turnLeftDown";

	private static inline var TURN_RIGHT_TO_UP = "turnRightUp";
	private static inline var TURN_RIGHT_TO_DOWN = "turnRightDown";

	private static inline var CHOMP_UP = "chompUp";
	private static inline var CHOMP_DOWN = "chompDown";
	private static inline var CHOMP_LEFT = "chompLeft";
	private static inline var CHOMP_RIGHT = "chompRight";

	// Same frames as the walk animations for these two
	private static inline var CHOMP_IN = "walkIn";
	private static inline var CHOMP_OUT = "walkOut";

	private static inline var FALLING = "falling";

	private static inline var TAIL_LEFT = "tailLeft";
	private static inline var TAIL_RIGHT = "tailRight";
	private static inline var TAIL_UP = "tailUp";
	private static inline var TAIL_DOWN = "tailDown";

	public static inline var SLOW = "Slow";

	var speed:Float = 60;

	public var secondsToMoveOneEmptyBlock:Float = 0.3;
	public var secondsToDigOneDirtBlock:Float = 0.4;
	public var secondsToFallOneBlock:Float = 0.1;

	private var totalSecondsToTarget:Float = 0.0;
	private var curTime:Float = 0.0;
	var framerate:Int = 10;
	var moving:Bool = false;

	public var target:FlxPoint = FlxPoint.get().copyFrom(Constants.NO_TARGET);

	private var travelDir:Cardinal = Cardinal.NONE;
	private var originalPosition:FlxPoint = FlxPoint.get(0, 0);
	private var isFalling:Bool = false;

	var targetType:TileType = EMPTY_SPACE;

	var temp:FlxVector = FlxVector.get();

	var justStopped:Bool = false;
	var stopped:Bool = true;
	var lastDirection:Cardinal = NONE;
	var inTransition:Bool = false;

	var molesFollowingMe:Int = 0;

	public var tail:FlxSprite;
	public var emitter:DirtEmitter;
	public var emitterStarted = false;

	public var isTransitioningBetweenLayers:Bool = false;
	public var transitionDir = 0;

	public var fallingSoundId:String = "";

	public function new() {
		super();

		#if fast
		secondsToMoveOneEmptyBlock = 0.1;
		secondsToDigOneDirtBlock = 0.2;
		secondsToFallOneBlock = 0.05;
		#end
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.BLUE);
		updateHitbox();

		loadGraphic(AssetPaths.Player__png, true, 32, 32);
		var row = 12;

		animation.add(IDLE_RIGHT, [for (i in 0...8) i], framerate);
		animation.add(IDLE_LEFT, [for (i in 0...8) i], framerate, true, true);
		animation.add(IDLE_UP, [for (i in 9 * row + 9...10 * row) i], framerate, true, true);
		animation.add(IDLE_DOWN, [for (i in 4 * row + 9...5 * row) i], framerate, true, true);

		animation.add(WALK_RIGHT, [for (i in row...row + 8) i], framerate);
		animation.add(WALK_LEFT, [for (i in row...row + 8) i], framerate, true, true);
		animation.add(WALK_DOWN, [for (i in 5 * row...5 * row + 8) i], framerate);
		animation.add(WALK_UP, [for (i in 7 * row...7 * row + 8) i], framerate);
		animation.add(WALK_IN, [for (i in 8 * row + 8...9 * row) i], framerate);
		animation.add(WALK_OUT, [for (i in 10 * row + 5...10 * row + 9) i], framerate);

		animation.add(TURN_RIGHT_TO_UP, [row + 9, row + 10].concat([for (i in 10 * row + 1...10 * row + 5) i]), framerate * 2, false);
		animation.add(TURN_RIGHT_TO_LEFT, [for (i in row + 8...2 * row) i], framerate, false);
		animation.add(TURN_RIGHT_TO_DOWN, [row + 9, row + 10].concat([for (i in 7 * row + 9...8 * row) i]), framerate * 2, false);

		animation.add(TURN_LEFT_TO_UP, [2 * row + 9, 2 * row + 10].concat([for (i in 10 * row + 1...10 * row + 5) i]), framerate * 2, false);
		animation.add(TURN_LEFT_TO_RIGHT, [for (i in 2 * row + 8...3 * row) i], framerate, false);
		animation.add(TURN_LEFT_TO_DOWN, [2 * row + 8, 2 * row + 9].concat([for (i in 7 * row + 9...8 * row) i]), framerate * 2, false);

		animation.add(TURN_DOWN_TO_LEFT, [7 * row + 11, 7 * row + 10, row + 9, row + 10, row + 11], framerate * 2, false);
		animation.add(TURN_DOWN_TO_UP, [for (i in 5 * row + 8...6 * row) i], framerate, false);
		animation.add(TURN_DOWN_TO_RIGHT, [7 * row + 11, 7 * row + 10, 2 * row + 9, 2 * row + 10, 2 * row + 11], framerate * 2, false);

		animation.add(TURN_UP_TO_LEFT, [5 * row + 11, 5 * row + 10, row + 9, row + 10, row + 11], framerate * 2, false);
		animation.add(TURN_UP_TO_DOWN, [for (i in 7 * row + 8...8 * row) i], framerate, false);
		animation.add(TURN_UP_TO_RIGHT, [5 * row + 11, 5 * row + 10, 2 * row + 9, 2 * row + 10, 2 * row + 11], framerate * 2, false);

		animation.add(CHOMP_UP, [for (i in 8 * row...8 * row + 8) i], framerate);
		animation.add(CHOMP_DOWN, [for (i in 6 * row...6 * row + 8) i], framerate);
		animation.add(CHOMP_RIGHT, [for (i in 2 * row...2 * row + 8) i], framerate);
		animation.add(CHOMP_LEFT, [for (i in 2 * row...2 * row + 8) i], framerate, true, true);

		animation.add(FALLING, [for (i in 11 * row...11 * row + 9) i], framerate);

		tail = new FlxSprite();
		tail.loadGraphic(AssetPaths.Player__png, true, 32, 32);
		tail.animation.add(TAIL_RIGHT, [for (i in 3 * row...3 * row + 8) i], framerate);
		tail.animation.add(TAIL_RIGHT + SLOW, [for (i in 3 * row...3 * row + 8) i], framerate / 5);
		tail.animation.add(TAIL_LEFT, [for (i in 3 * row...3 * row + 8) i], framerate, true, true);
		tail.animation.add(TAIL_LEFT + SLOW, [for (i in 3 * row...3 * row + 8) i], framerate / 5, true, true);
		tail.animation.add(TAIL_UP, [for (i in 9 * row...9 * row + 8) i], framerate);
		tail.animation.add(TAIL_UP + SLOW, [for (i in 9 * row...9 * row + 8) i], framerate / 5);
		tail.animation.add(TAIL_DOWN, [for (i in 4 * row...4 * row + 8) i], framerate);
		tail.animation.add(TAIL_DOWN + SLOW, [for (i in 4 * row...4 * row + 8) i], framerate / 5);

		emitter = new DirtEmitter();
	}

	override public function update(delta:Float) {
		super.update(delta);

		innerUpdate(delta);

		updateTail(delta);
		updateEmitter(delta);
	}

	private function innerUpdate(delta:Float) {
		if (inTransition) {
			if (animation.finished) {
				inTransition = false;
			} else {
				return;
			}
		}

		if (justStopped && stopped) {
			justStopped = false;
		}

		molesFollowingMe = numMolesFollowingMe();

		if (isTransitioningBetweenLayers) {
			switch (transitionDir) {
				case -1:
					animation.play(WALK_OUT);
				case 1:
					animation.play(WALK_IN);
				default:
			}

			if (!emitterStarted) {
				emitterStarted = true;
				emitter.start(false);
			} else {
				emitter.emitting = true;
			}
			return;
		}

		// Move the player to the next block
		if (targetValid()) {
			// assume we are not stopped
			stopped = false;
			if (curTime >= 0.0) {
				var percentToTarget = 1.0 - curTime / totalSecondsToTarget;
				var diffToTarget = FlxPoint.get(target.x - originalPosition.x, target.y - originalPosition.y);
				diffToTarget = diffToTarget.scale(percentToTarget);
				setPosition(diffToTarget.x + originalPosition.x, diffToTarget.y + originalPosition.y);

				curTime -= delta;
				if (curTime < 0.0) {
					// snap to the target, probably jumps a bit here, but meh...
					setPosition(target.x, target.y);
				}
			}

			// Use actual falling information from the move result
			var falling = isFalling;
			if (falling) {
				var startFrame = 0;
				if (animation.name == WALK_UP || animation.name == CHOMP_UP) {
					startFrame = 3;
				} else if (animation.name == WALK_DOWN || animation.name == CHOMP_DOWN) {
					startFrame = 7;
				}

				animation.play(FALLING, startFrame);
			}

			if (!falling && travelDir != lastDirection) {
				// need to play animation and wait for it to finish
				switch (lastDirection) {
					case N:
						switch (travelDir) {
							case E:
								animation.play(TURN_UP_TO_RIGHT);
							case S:
								animation.play(TURN_UP_TO_DOWN);
							case W:
								animation.play(TURN_UP_TO_LEFT);
							default:
						}
					case E:
						switch (travelDir) {
							case S:
								animation.play(TURN_RIGHT_TO_DOWN);
							case W:
								animation.play(TURN_RIGHT_TO_LEFT);
							case N:
								animation.play(TURN_RIGHT_TO_UP);
							default:
						}
					case S:
						switch (travelDir) {
							case W:
								animation.play(TURN_DOWN_TO_LEFT);
							case N:
								animation.play(TURN_DOWN_TO_UP);
							case E:
								animation.play(TURN_DOWN_TO_RIGHT);
							default:
						}
					case W:
						switch (travelDir) {
							case N:
								animation.play(TURN_LEFT_TO_UP);
							case E:
								animation.play(TURN_LEFT_TO_RIGHT);
							case S:
								animation.play(TURN_LEFT_TO_DOWN);
							default:
						}
					default:
				}

				inTransition = true;
				lastDirection = travelDir;

				// return early as we need to finish this animation before moving
				return;
			}

			if (!falling) {
				switch (lastDirection) {
					case N:
						animation.play(targetType == DIRT ? CHOMP_UP : WALK_UP);
					case S:
						animation.play(targetType == DIRT ? CHOMP_DOWN : WALK_DOWN);
					case E:
						animation.play(targetType == DIRT ? CHOMP_RIGHT : WALK_RIGHT);
					case W:
						animation.play(targetType == DIRT ? CHOMP_LEFT : WALK_LEFT);
					default:
				}
				if (targetType == DIRT) {
					if (!emitterStarted) {
						emitterStarted = true;
						emitter.start(false);
					} else {
						emitter.emitting = true;
					}
				}
			}

			// Check if the player has now reached the next block
			if (getPosition(temp).distanceTo(target) < 1) {
				setPosition(Math.round(target.x), Math.round(target.y));
				target.copyFrom(Constants.NO_TARGET);
				justStopped = !stopped;
				// if(justStopped && FmodManager.IsSoundPlaying(fallingSoundId)){
				// 	FmodManager.StopSoundImmediately(fallingSoundId);
				// 	FmodManager.PlaySoundOneShot(FmodSFX.MoleFallLand);
				// }
				stopped = true;
				isFalling = false;
			}
		} else {
			// Player isn't giving input, so lets check animation stuff
			if (stopped) {
				if (!StringExt.contains(animation.name, "idle")) {
					switch (lastDirection) {
						case N:
							animation.play(IDLE_UP);
						case S:
							animation.play(IDLE_DOWN);
						case E:
							animation.play(IDLE_RIGHT);
						case W:
							animation.play(IDLE_LEFT);
						default:
					}
				}
				// if(FmodManager.IsSoundPlaying(fallingSoundId)){
				// 	FmodManager.StopSoundImmediately(fallingSoundId);
				// 	FmodManager.PlaySoundOneShot(FmodSFX.MoleFallLand);
				// }
			}
		}
	}

	private function updateEmitter(delta:Float) {
		var dir = lastDirection;
		if (isTransitioningBetweenLayers) {
			dir = NONE;
		}

		var emitterOffsets = [
			N => FlxPoint.get(16, 4),
			S => FlxPoint.get(16, 31),
			E => FlxPoint.get(30, 16),
			W => FlxPoint.get(0, 16),
			NONE => FlxPoint.get(16, 16),
		];


		emitter.x = x + emitterOffsets.get(dir).x;
		emitter.y = y + emitterOffsets.get(dir).y;

		emitter.setDigDirection(dir);

		if (stopped && !isTransitioningBetweenLayers) {
			emitter.emitting = false;
		}
	}

	private function updateTail(delta:Float) {
		if (animation.name != null) {
			if (animation.name.contains("turn") || animation.name.contains(FALLING)) {
				tail.visible = false;
				return;
			}
		}

		// Using 32, there are tiny gaps between rat and tail
		var tailOffsets = [
			N => FlxPoint.get(0, 32),
			S => FlxPoint.get(0, -31),
			E => FlxPoint.get(-30, 0),
			W => FlxPoint.get(30, 0),
			NONE => FlxPoint.get(0, 0),
		];

		tail.visible = true;
		tail.x = x + tailOffsets.get(lastDirection).x;
		tail.y = y + tailOffsets.get(lastDirection).y;

		var tailAnim:String = "";

		switch (lastDirection) {
			case N:
				tailAnim = TAIL_UP;
			case S:
				tailAnim = TAIL_DOWN;
			case E:
				tailAnim = TAIL_RIGHT;
			case W:
				tailAnim = TAIL_LEFT;
			default:
				// set it to something so we don't explode
				return;
		}

		if (stopped && !justStopped) {
			tailAnim += SLOW;
		}

		// trace('starting new tail anim on frame: ${tail.animation.frameIndex}');
		tail.animation.play(tailAnim, false, false, tail.animation.frameIndex % 8);
	}

	public function getIntention():Cardinal {
		if (hasTarget()) {
			// still chasing our target
			return Cardinal.NONE;
		} else {
			return InputCalcuator.getInputCardinal();
		}
	}

	public function hasTarget():Bool {
		return !target.equals(Constants.NO_TARGET);
	}

	public function getDepthIntention():Int {
		if (hasTarget() || isTransitioningBetweenLayers) {
			return 0;
		}
		return InputCalcuator.getDepthInput();
	}

	public function setTarget(t:MoveResult) {
		target.copyFrom(t.target);
		originalPosition = getPosition();
		if (!isFalling && t.isFalling) {
			// fallingSoundId = FmodManager.PlaySoundWithReference(FmodSFX.MoleFall);
		}
		isFalling = t.isFalling;

		var tmp = FlxVector.get();
		getPosition(tmp).subtractPoint(target);
		tmp.normalize();

		travelDir = Cardinal.closest(tmp, true).opposite();
		targetType = t.moveIntoType;

		if (targetType == DIRT) {
			// trying to dig through dirt
			totalSecondsToTarget = secondsToDigOneDirtBlock;
		} else {
			// just trying to move normally
			totalSecondsToTarget = secondsToMoveOneEmptyBlock;
		}
		// need to account for falling speed difference
		if (isFalling) {
			totalSecondsToTarget = secondsToFallOneBlock;
		}
		curTime = totalSecondsToTarget;

		moveFollower(new FlxPoint(x, y));
	}

	public function targetValid():Bool {
		return !target.equals(Constants.NO_TARGET);
	}
}
