package states.teststates;

import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import entities.MoleFriend;
import flixel.FlxSprite;
import flixel.FlxG;

using extensions.FlxStateExt;

class FishState extends FlxTransitionableState {
	var player:FlxSprite;

	var moleFriend:FlxSprite;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		player = new Player();
		add(player);

		moleFriend = new MoleFriend(player);
		add(moleFriend);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
