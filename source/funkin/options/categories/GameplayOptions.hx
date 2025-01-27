package funkin.options.categories;

import funkin.backend.system.Conductor;

class GameplayOptions extends OptionsScreen {
	var __metronome = FlxG.sound.load(Paths.sound('editors/charter/metronome'));
	public override function new() {
		super("Gameplay", 'Change Gameplay options such as Downscroll, Scroll Speed, Naughtiness...');
		add(new Checkbox(
			"Downscroll",
			"If checked, notes will go from up to down instead of down to up, as if they were falling",
			"downscroll"));
		add(new Checkbox(
			"Ghost Tapping",
			"If unchecked, trying to hit any strum that have no note that can be hit will cause a miss.",
			"ghostTapping"));
		add(new NumOption(
			"Song Offset",
			"Changes the offset at which the song should start",
			-999, // minimum
			999, // maximum
			1, // change
			"songOffset", // save name or smth
			__changeOffset)); // callback
		add(new Checkbox(
			"Naughtiness",
			"If unchecked, will censor Week 7 cutscenes",
			"naughtyness")); //I didn't feel like changing this line to be spelled right as naughtiness (with an I) as I think it would break stuff.
		add(new Checkbox(
			"Camera Zoom on Beat",
			"If unchecked, will disable the camera from zooming every four beats",
			"camZoomOnBeat"));
	}
	private function __changeOffset(offset) Conductor.songOffset = offset; 
	var __lastBeat:Int = 0;
	var __lastSongBeat:Int = 0;
	override function update(elapsed) {
		super.update(elapsed);
		FlxG.camera.zoom = CoolUtil.fpsLerp(FlxG.camera.zoom, 1, 0.04);
		if (members[2].selected) {
			FlxG.sound.music.volume = 0.5;
			if (__lastBeat != Conductor.curBeat) {
				FlxG.camera.zoom += 0.03;
				__lastBeat = Conductor.curBeat;
			}
			if (__lastSongBeat != Math.floor(Conductor.getStepForTime(FlxG.sound.music.time / 2) / Conductor.stepsPerBeat)) {
				__metronome.replay();
				__lastSongBeat = Math.floor(Conductor.getStepForTime(FlxG.sound.music.time / 2) / Conductor.stepsPerBeat);
			}
		}
		else FlxG.sound.music.volume = 1;
	}
}
