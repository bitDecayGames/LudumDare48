package;

import states.SplashScreenState;
import misc.Macros;
import states.MainMenuState;
import flixel.FlxState;
import config.Configure;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import misc.FlxTextFactory;
import openfl.display.Sprite;
#if play
import states.PlayState;
#elseif credits
import states.CreditsState;
#elseif mike
import states.teststates.MikesNoisyState;
#elseif jakect
import states.JakeCTState;
#elseif fish
import states.teststates.FishState;
#end

class Main extends Sprite {
	public function new() {
		super();
		Configure.initAnalytics(false);

		var startingState:Class<FlxState> = SplashScreenState;

		#if play
		startingState = PlayState;
		#elseif credits
		startingState = CreditsState;
		#elseif mike
		startingState = MikesNoiseyState;
		#elseif jakect
		startingState = JakeCTState;
		#elseif fish
		startingState = FishState;
		#elseif tanner
		startingState = MainMenuState;
		#else
		if (Macros.isDefined("SKIP_SPLASH")) {
			startingState = MainMenuState;
		}
		#end
		addChild(new FlxGame(0, 0, startingState, 1, 60, 60, true, false));

		FlxG.fixedTimestep = false;

		// Disable flixel volume controls as we don't use them because of FMOD
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;

		// Don't use the flixel cursor
		FlxG.mouse.useSystemCursor = true;

		#if debug
		FlxG.autoPause = false;
		#end

		// Set up basic transitions. To override these see `transOut` and `transIn` on any FlxTransitionable states
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.2);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.2);

		FlxTextFactory.defaultFont = AssetPaths.Brain_Slab_8__ttf;
	}
}
