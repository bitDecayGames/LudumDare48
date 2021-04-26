package entities;

import metrics.Metrics;
import entities.Moleness.MoleTarget;
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
	var speed:Float = 60;

	public var secondsToMoveOneEmptyBlock:Float = 0.3;
	public var secondsToDigOneDirtBlock:Float = 0.4;
	public var secondsToFallOneBlock:Float = 0.1;

	private var totalSecondsToTarget:Float = 0.0;
	private var curTime:Float = 0.0;
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
		initAnimations();
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
		Metrics.reportMolesFollowing(molesFollowingMe);

		if (isTransitioningBetweenLayers) {
			switch (transitionDir) {
				case -1:
					animation.play(Moleness.WALK_OUT);
				case 1:
					animation.play(Moleness.WALK_IN);
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
				if (animation.name == Moleness.WALK_UP || animation.name == Moleness.CHOMP_UP) {
					startFrame = 3;
				} else if (animation.name == Moleness.WALK_DOWN || animation.name == Moleness.CHOMP_DOWN) {
					startFrame = 7;
				}

				if (animation.name != "falling"){
					fallingSoundId = FmodManager.PlaySoundWithReference(FmodSFX.MoleFall);
				}

				animation.play(Moleness.FALLING, startFrame);
			}

			if (!falling && travelDir != lastDirection) {
				// need to play animation and wait for it to finish
				switch (lastDirection) {
					case N:
						switch (travelDir) {
							case E:
								animation.play(Moleness.TURN_UP_TO_RIGHT);
							case S:
								animation.play(Moleness.TURN_UP_TO_DOWN);
							case W:
								animation.play(Moleness.TURN_UP_TO_LEFT);
							default:
						}
					case E:
						switch (travelDir) {
							case S:
								animation.play(Moleness.TURN_RIGHT_TO_DOWN);
							case W:
								animation.play(Moleness.TURN_RIGHT_TO_LEFT);
							case N:
								animation.play(Moleness.TURN_RIGHT_TO_UP);
							default:
						}
					case S:
						switch (travelDir) {
							case W:
								animation.play(Moleness.TURN_DOWN_TO_LEFT);
							case N:
								animation.play(Moleness.TURN_DOWN_TO_UP);
							case E:
								animation.play(Moleness.TURN_DOWN_TO_RIGHT);
							default:
						}
					case W:
						switch (travelDir) {
							case N:
								animation.play(Moleness.TURN_LEFT_TO_UP);
							case E:
								animation.play(Moleness.TURN_LEFT_TO_RIGHT);
							case S:
								animation.play(Moleness.TURN_LEFT_TO_DOWN);
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
						animation.play(targetType == DIRT ? Moleness.CHOMP_UP : Moleness.WALK_UP);
					case S:
						animation.play(targetType == DIRT ? Moleness.CHOMP_DOWN : Moleness.WALK_DOWN);
					case E:
						animation.play(targetType == DIRT ? Moleness.CHOMP_RIGHT : Moleness.WALK_RIGHT);
					case W:
						animation.play(targetType == DIRT ? Moleness.CHOMP_LEFT : Moleness.WALK_LEFT);
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
				stopped = true;
				isFalling = false;
			}
		} else {
			// Player isn't giving input, so lets check animation stuff
			if (stopped) {
				if (!StringExt.contains(animation.name, "idle")) {
					switch (lastDirection) {
						case N:
							animation.play(Moleness.IDLE_UP);
						case S:
							animation.play(Moleness.IDLE_DOWN);
						case E:
							animation.play(Moleness.IDLE_RIGHT);
						case W:
							animation.play(Moleness.IDLE_LEFT);
						default:
					}
				}
			}
		}
		if(animation.name != "falling" && FmodManager.IsSoundPlaying(fallingSoundId)){
			FmodManager.StopSoundImmediately(fallingSoundId);
			FmodManager.PlaySoundOneShot(FmodSFX.MoleFallLand);
			trace("Stopped in the movement check");
		}
		trace("Animation: " + animation.name);
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
			if (animation.name.contains("turn") || animation.name.contains(Moleness.FALLING) || isTransitioningBetweenLayers) {
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
				tailAnim = Moleness.TAIL_UP;
			case S:
				tailAnim = Moleness.TAIL_DOWN;
			case E:
				tailAnim = Moleness.TAIL_RIGHT;
			case W:
				tailAnim = Moleness.TAIL_LEFT;
			default:
				// set it to something so we don't explode
				return;
		}

		if (stopped && !justStopped) {
			tailAnim += Moleness.SLOW;
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
		if (t.changeInDepth != 0) {
			z += t.changeInDepth;
		}

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

		moveFollower(MoleTarget.fromPoint(FlxPoint.get(x, y), totalSecondsToTarget, z, t.dir));
	}

	public function targetValid():Bool {
		return !target.equals(Constants.NO_TARGET);
	}

	public override function destroy() {
		super.destroy();
		if (moleFollowingMe != null) {
			// break the chain
			moleFollowingMe.moleImFollowing = null;
		}
	}
}
