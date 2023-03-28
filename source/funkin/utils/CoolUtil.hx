package funkin.utils;

import flixel.system.frontEnds.SoundFrontEnd;
import flixel.system.FlxSound;
import funkin.system.Conductor;
import flixel.system.FlxSoundGroup;
import animateatlas.AtlasFrameMaker;
import haxe.Json;
import funkin.menus.StoryMenuState.WeekData;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import haxe.xml.Access;
import flixel.input.keyboard.FlxKey;
import lime.utils.Assets;
import flixel.animation.FlxAnimation;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flash.geom.ColorTransform;
import funkin.chart.Chart;

using StringTools;

@:allow(funkin.game.PlayState)
class CoolUtil
{
	/*
	 * Returns `v` if not null, `defaultValue` otherwise.
	 * @param v The value
	 * @param defaultValue The default value
	 * @return The return value
	 */
	public static inline function getDefault<T>(v:Null<T>, defaultValue:T):Null<T> {
		return (v == null || isNaN(v)) ? defaultValue : v;
	}

	/**
	 * Shortcut to parse JSON from an Asset path
	 * @param assetPath Path to the JSON asset.
	 */
	public static function parseJson(assetPath:String) {
		return Json.parse(Assets.getText(assetPath));
	}

	/**
	 * Shortcut to parse a JSON string
	 * @param str Path to the JSON string
	 * @return Parsed JSON
	 */
	public inline static function parseJsonString(str:String)
		return Json.parse(str);

	/**
	 * Whenever a value is NaN or not.
	 * @param v Value
	 */
	public static inline function isNaN(v:Dynamic) {
		if (v is Float || v is Int)
			return Math.isNaN(cast(v, Float));
		return false;
	}

	/**
	 * Returns the last of an Array
	 * @param array Array
	 * @return T Last element
	 */
	public static inline function last<T>(array:Array<T>):T {
		return array[array.length - 1];
	}

	/**
	 * Sets a field's default value, and returns it. In case it already exists, returns the existing one.
	 * @param v Dynamic to set the default value to
	 * @param name Name of the value
	 * @param defaultValue Default value
	 * @return T New/old value.
	 */
	public static function setFieldDefault<T>(v:Dynamic, name:String, defaultValue:T):T {
		if (Reflect.hasField(v, name)) {
			var f:Null<Dynamic> = Reflect.field(v, name);
			if (f != null)
				return cast f;
		}
		Reflect.setField(v, name, defaultValue);
		return defaultValue;
	}

	/**
	 * Add several zeros at the beginning of a string, so that `2` becomes `02`.
	 * @param str String to add zeros
	 * @param num The length required
	 */
	public static inline function addZeros(str:String, num:Int) {
		while(str.length < num) str = '0${str}';
		return str;
	}

	/**
	 * Returns a string representation of a size, following this format: `1.02 GB`, `134.00 MB`
	 * @param size Size to convert ot string
	 * @return String Result string representation
	 */
	public static function getSizeString(size:Float):String {
		var labels = ["B", "KB", "MB", "GB", "TB"];
		var rSize:Float = size;
		var label:Int = 0;
		while(rSize > 1024 && label < labels.length-1) {
			label++;
			rSize /= 1024;
		}
		return '${Std.int(rSize) + "." + addZeros(Std.string(Std.int((rSize % 1) * 100)), 2)}${labels[label]}';
	}

	/**
	 * Alternative linear interpolation function for each frame use, without worrying about framerate changes.
	 * @param v1 Begin value
	 * @param v2 End value
	 * @param ratio Ratio
	 * @return Float Final value
	 */
	public static inline function fpsLerp(v1:Float, v2:Float, ratio:Float):Float {
		return FlxMath.lerp(v1, v2, getFPSRatio(ratio));
	}
	/**
	 * Lerps from color1 into color2 (Shortcut to `FlxColor.interpolate`)
	 * @param color1 Color 1
	 * @param color2 Color 2
	 * @param ratio Ratio
	 * @param fpsSensitive Whenever the ratio should be fps sensitive (adapted when game is running at 120 instead of 60)
	 */
	public static inline function lerpColor(color1:FlxColor, color2:FlxColor, ratio:Float, fpsSensitive:Bool = false) {
		if (!fpsSensitive)
			ratio = getFPSRatio(ratio);
		return FlxColor.interpolate(color1, color2, ratio);
	}

	/**
	 * Modifies a lerp ratio based on current FPS to keep a stable speed on higher framerate.
	 * @param ratio Ratio
	 * @return FPS-Modified Ratio
	 */
	public static inline function getFPSRatio(ratio:Float):Float {
		return FlxMath.bound(ratio * 60 * FlxG.elapsed, 0, 1);
	}
	/**
	 * Tries to get a color from a `Dynamic` variable.
	 * @param c `Dynamic` color.
	 * @return The result color, or `null` if invalid.
	 */
	public static function getColorFromDynamic(c:Dynamic):Null<FlxColor> {
		// -1
		if (c is Int) return c;

		// -1.0
		if (c is Float) return Std.int(c);

		// "#FFFFFF"
		if (c is String) return FlxColor.fromString(c);

		// [255, 255, 255]
		if (c is Array) {
			var r:Int = 0;
			var g:Int = 0;
			var b:Int = 0;
			var a:Int = 255;
			var array:Array<Dynamic> = cast c;
			for(k=>e in array) {
				if (e is Int || e is Float) {
					switch(k) {
						case 0:		r = Std.int(e);
						case 1:		g = Std.int(e);
						case 2:		b = Std.int(e);
						case 3:		a = Std.int(e);
					}
				}
			}
			return FlxColor.fromRGB(r, g, b, a);
		}
		return null;
	}

	/**
	 * Plays the main menu theme.
	 * @param fadeIn 
	 */
	public static function playMenuSong(fadeIn:Bool = false) {
		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			playMusic(Paths.music('freakyMenu'), 102, fadeIn ? 0 : 1);
			if (fadeIn)
				FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
	}

	/**
	 * Preloads a character.
	 * @param name Character name
	 * @param spriteName (Optional) sprite name.
	 */
	public static function preloadCharacter(name:String, ?spriteName:String) {
		if (name == null) return;
		if (spriteName == null)
			spriteName = name;
		Assets.getText(Paths.xml('characters/$name'));
		Paths.getFrames('characters/$spriteName');
	}

	/**
	 * Plays music, while resetting the Conductor, and taking info from INI in count.
	 * @param path Path to the music
	 * @param DefaultBPM Default BPM of the music (102)
	 * @param Volume Volume of the music (1)
	 * @param Looped Whenever the music loops (true)
	 * @param Group A group that this music belongs to (default)
	 */
	public static function playMusic(path:String, DefaultBPM:Int = 102, Volume:Int = 1, Looped:Bool = true, ?Group:FlxSoundGroup) {
		Conductor.reset();
		FlxG.sound.playMusic(path, Volume, Looped, Group);

		var infoPath = '${Path.withoutExtension(path)}.ini';
		if (Assets.exists(infoPath)) {
			var musicInfo = IniUtil.parseAsset(infoPath, [
				"BPM" => null,
				"TimeSignature" => "2/2"
			]);

			var timeSignParsed:Array<Null<Float>> = musicInfo["TimeSignature"] == null ? [] : [for(s in musicInfo["TimeSignature"].split("/")) Std.parseFloat(s)];
			var beatsPerMesure:Float = 4;
			var stepsPerBeat:Float = 4;

			if (timeSignParsed.length == 2 && !timeSignParsed.contains(null)) {
				beatsPerMesure = timeSignParsed[0] == null || timeSignParsed[0] <= 0 ? 4 : cast timeSignParsed[0];
				stepsPerBeat = timeSignParsed[1] == null || timeSignParsed[1] <= 0 ? 4 : cast timeSignParsed[1];
			}

			var parsedBPM:Null<Float> = Std.parseFloat(musicInfo["BPM"]);
			Conductor.changeBPM(parsedBPM == null ? DefaultBPM : parsedBPM, beatsPerMesure, stepsPerBeat);
		} else
			Conductor.changeBPM(DefaultBPM);
	}

	/**
	 * Plays a specified Menu SFX.
	 * @param menuSFX Menu SFX to play
	 * @param volume At which volume it should play
	 */
	public static function playMenuSFX(menuSFX:CoolSfx = SCROLL, volume:Float = 1) {
		FlxG.sound.play(Paths.sound(switch(menuSFX) {
			case CONFIRM:	'menu/confirm';
			case CANCEL:	'menu/cancel';
			case SCROLL:	'menu/scroll';
			case CHECKED:	'menu/checkboxChecked';
			case UNCHECKED:	'menu/checkboxUnchecked';
			case WARNING:	'menu/warningMenu';
			default: 		'menu/scroll';
		}), volume);
	}

	/**
	 * Allows you to split a text file from a path, into a "cool text file", AKA a list. Allows for comments. For example,
	 * `# comment`
	 * `test1`
	 * ` `
	 * `test2`
	 * will return `["test1", "test2"]`
	 * @param path 
	 * @return Array<String>
	 */
	public static function coolTextFile(path:String):Array<String>
	{
		var trim:String;
		return [for(line in Assets.getText(path).split("\n")) if ((trim = line.trim()) != "" && !trim.startsWith("#")) trim];
	}

	/**
	 * Returns an array of number from min to max. Equivalent of `[for (i in min...max) i]`.
	 * @param max Max value
	 * @param min Minimal value (0)
	 * @return Array<Int> Final array
	 */
	public static inline function numberArray(max:Int, ?min:Int = 0):Array<Int>
	{
		return [for (i in min...max) i];
	}

	/**
	 * Switches frames from 2 FlxAnimations.
	 * @param anim1 First animation
	 * @param anim2 Second animation
	 */
	public static function switchAnimFrames(anim1:FlxAnimation, anim2:FlxAnimation) {
		if (anim1 == null || anim2 == null) return;
		var old = anim1.frames;
		anim1.frames = anim2.frames;
		anim2.frames = old;
	}

	/**
	 * Allows you to set a graphic size (ex: 150x150), with proper hitbox without a stretched sprite.
	 * @param sprite Sprite to apply the new graphic size to
	 * @param width Width
	 * @param height Height
	 * @param fill Whenever the sprite should fill instead of shrinking (true)
	 * @param maxScale Maximum scale (0 / none)
	 */
	public static function setUnstretchedGraphicSize(sprite:FlxSprite, width:Int, height:Int, fill:Bool = true, maxScale:Float = 0) {
		sprite.setGraphicSize(width, height);
		sprite.updateHitbox();
		var nScale = (fill ? Math.max : Math.min)(sprite.scale.x, sprite.scale.y);
		if (maxScale > 0 && nScale > maxScale) nScale = maxScale;
		sprite.scale.set(nScale, nScale);
	}

	/**
	 * Returns a simple string representation of a FlxKey. Used in Controls options.
	 * @param key Key
	 * @return Simple representation
	 */
	public static inline function keyToString(key:Null<FlxKey>):String {
		return switch(key) {
			case null | 0 | NONE:	"---";
			case LEFT: 				"←";
			case DOWN: 				"↓";
			case UP: 				"↑";
			case RIGHT:				"→";
			case ESCAPE:			"ESC";
			case BACKSPACE:			"[←]";
			case NUMPADZERO:		"#0";
			case NUMPADONE:			"#1";
			case NUMPADTWO:			"#2";
			case NUMPADTHREE:		"#3";
			case NUMPADFOUR:		"#4";
			case NUMPADFIVE:		"#5";
			case NUMPADSIX:			"#6";
			case NUMPADSEVEN:		"#7";
			case NUMPADEIGHT:		"#8";
			case NUMPADNINE:		"#9";
			case NUMPADPLUS:		"#+";
			case NUMPADMINUS:		"#-";
			case NUMPADPERIOD:		"#.";
			case ZERO:				"0";
			case ONE:				"1";
			case TWO:				"2";
			case THREE:				"3";
			case FOUR:				"4";
			case FIVE:				"5";
			case SIX:				"6";
			case SEVEN:				"7";
			case EIGHT:				"8";
			case NINE:				"9";
			case PERIOD:			".";
			default:				key.toString();
		}
	}

	/**
	 * Centers an object in a camera's field, basically `screenCenter()` but `camera.width` and `camera.height` are used instead of `FlxG.width` and `FlxG.height`.
	 * @param obj Sprite to center
	 * @param cam Camera
	 * @param axes Axes (XY)
	 */
	public static function cameraCenter(obj:FlxObject, cam:FlxCamera, axes:FlxAxes = XY) {
		switch(axes) {
			case XY:
				obj.setPosition((cam.width - obj.width) / 2, (cam.height - obj.height) / 2);
			case X:
				obj.x = (cam.width - obj.width) / 2;
			case Y:
				obj.y = (cam.height - obj.height) / 2;
			case NONE:

		}
	}

	/**
	 * Load a week into PlayState.
	 * @param weekData Week Data
	 * @param difficulty Week Difficulty
	 */
	public static function loadWeek(weekData:WeekData, difficulty:String = "normal") {
		PlayState.storyWeek = weekData;
		PlayState.storyPlaylist = [for(e in weekData.songs) e.name];
		PlayState.isStoryMode = true;
		PlayState.campaignScore = 0;
		PlayState.opponentMode = PlayState.coopMode = false;
		__loadSong(PlayState.storyPlaylist[0], difficulty);
	}

	/**
	 * Loads a song into PlayState
	 * @param name Song name
	 * @param difficulty Chart difficulty (if invalid, will load an empty chart)
	 * @param opponentMode Whenever opponent mode is on
	 * @param coopMode Whenever co-op mode is on.
	 */
	public static function loadSong(name:String, difficulty:String = "normal", opponentMode:Bool = false, coopMode:Bool = false) {
		PlayState.campaignScore = 0;
		PlayState.isStoryMode = false;
		PlayState.opponentMode = opponentMode;
		PlayState.coopMode = coopMode;
		__loadSong(name, difficulty);
	}

	/**
	 * (INTERNAL) Loads a song without resetting story mode/opponent mode/coop mode values.
	 * @param name Song name
	 * @param difficulty Song difficulty
	 */
	public static function __loadSong(name:String, difficulty:String) {
		PlayState.difficulty = difficulty;

		PlayState.SONG = Chart.parse(name, difficulty);
		PlayState.fromMods = PlayState.SONG.fromMods;
	}

	/**
	 * Equivalent of `setGraphicSize`, except that it can accept floats and automatically updates the hitbox.
	 * @param sprite Sprite to set the size of
	 * @param width Width
	 * @param height Height
	 */
	public static function setSpriteSize(sprite:FlxSprite, width:Float, height:Float) {
		sprite.scale.set(width / sprite.frameWidth, height / sprite.frameHeight);
		sprite.updateHitbox();
	}

	/**
	 * Gets an XML attribute from an `Access` abstract, without throwing an exception if invalid.
	 * Example: `xml.getAtt("test").getDefault("Hello, World!");`
	 * @param xml XML to get the attribute from
	 * @param name Name of the attribute
	 */
	public static inline function getAtt(xml:Access, name:String) {
		if (!xml.has.resolve(name)) return null;
		return xml.att.resolve(name);
	}

	/**
	 * Loads frames from a specific image path. Supports Sparrow Atlases, Packer Atlases, and multiple spritesheets.
	 * @param path Path to the image
	 * @param Unique Whenever the image should be unique in the cache
	 * @param Key Key to the image in the cache
	 * @param SkipAtlasCheck Whenever the atlas check should be skipped.
	 * @return FlxFramesCollection Frames
	 */
	public static function loadFrames(path:String, Unique:Bool = false, Key:String = null, SkipAtlasCheck:Bool = false):FlxFramesCollection {
		var noExt = Path.withoutExtension(path);

		if (Assets.exists('$noExt/1.png')) {
			// MULTIPLE SPRITESHEETS!!

			var graphic = FlxG.bitmap.add("flixel/images/logo/default.png", false, '$noExt/mult');
			var frames = FlxAtlasFrames.findFrame(graphic);
			if (frames != null)
				return frames;

			trace("no frames yet for multiple atlases!!");
			var spritesheets = [];
			var cur = 1;
			var finalFrames = new FlxFramesCollection(graphic, ATLAS);
			while(Assets.exists('$noExt/$cur.png')) {
				spritesheets.push(loadFrames('$noExt/$cur.png'));
				cur++;
			}
			for(frames in spritesheets)
				if (frames != null && frames.frames != null)
					for(f in frames.frames)
						if (f != null) {
							finalFrames.frames.push(f);
							f.parent = frames.parent;
						}
			return finalFrames;
		} else if (!SkipAtlasCheck && Assets.exists('$noExt/Animation.json')
		&& Assets.exists('$noExt/spritemap.json')
		&& Assets.exists('$noExt/spritemap.png')) {
			return AtlasFrameMaker.construct(noExt);
		} else if (Assets.exists('$noExt.xml')) {
			return Paths.getSparrowAtlasAlt(noExt);
		} else if (Assets.exists('$noExt.txt')) {
			return Paths.getPackerAtlasAlt(noExt);
		}

		var graph:FlxGraphic = FlxG.bitmap.add(path, Unique, Key);
		if (graph == null)
			return null;
		return graph.imageFrame;
	}

	/**
	 * Loads an animated graphic, and automatically animates it.
	 * @param spr Sprite to load the graphic for
	 * @param path Path to the graphic
	 */
	public static function loadAnimatedGraphic(spr:FlxSprite, path:String) {
		spr.frames = loadFrames(path);

		if (spr.frames != null && spr.frames.frames != null) {
			spr.animation.add("idle", [for(i in 0...spr.frames.frames.length) i], 24, true);
			spr.animation.play("idle");
		}

		return spr;
	}

	/**
	 * Copies a color transform from color1 to color2
	 * @param color1 Color transform to copy to
	 * @param color2 Color transform to copy from
	 */
	public static inline function copyColorTransform(color1:ColorTransform, color2:ColorTransform) {
		color1.alphaMultiplier 	= color2.alphaMultiplier;
		color1.alphaOffset 		= color2.alphaOffset;
		color1.blueMultiplier 	= color2.blueMultiplier;
		color1.blueOffset 		= color2.blueOffset;
		color1.greenMultiplier 	= color2.greenMultiplier;
		color1.greenOffset 		= color2.greenOffset;
		color1.redMultiplier 	= color2.redMultiplier;
		color1.redOffset 		= color2.redOffset;
	}

	/**
	 * Resets an FlxSprite
	 * @param spr Sprite to reset
	 * @param x New X position
	 * @param y New Y position
	 */
	public static function resetSprite(spr:FlxSprite, x:Float, y:Float) {
		spr.reset(x, y);
		spr.alpha = 1;
		spr.visible = true;
		spr.active = true;
		spr.antialiasing = FlxSprite.defaultAntialiasing;
		spr.rotOffset.set();
	}

	/**
	 * Gets the macro class created by hscript-improved for an abstract / enum
	 */
	public static function getMacroAbstractClass(className:String) {
		return Type.resolveClass('${className}_HSC');
	}

	/**
	 * Clears the content of an array
	 */
	public static function clear<T>(array:Array<T>):Array<T> {
		while(array.length > 0)
			array.shift();
		return array;
	}

	/**
	 * Push an entire group into an array.
	 * @param array Array to push the group into
	 * @param ...args Group entries
	 * @return Array<T>
	 */
	public static function pushGroup<T>(array:Array<T>, ...args:T):Array<T> {
		for(a in args)
			array.push(a);
		return array;
	}

	/**
	 * Opens an URL in the browser.
	 * @param url 
	 */
	public static function openURL(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	/**
	 * Stops a sound, set its time to 0 then play it again.
	 * @param sound Sound to replay.
	 */
	public static function replay(sound:FlxSound) {
		sound.stop();
		sound.time = 0;
		sound.play();
	}

	/**
	 * Equivalent of `Math.max`, except doesn't require a Int -> Float -> Int conversion.
	 * @param p1 
	 * @param p2 
	 * @return return p1 < p2 ? p2 : p1
	 */
	public static inline function maxInt(p1:Int, p2:Int)
		return p1 < p2 ? p2 : p1;

	/**
	 * Equivalent of `Math.floor`, except doesn't require a Int -> Float -> Int conversion.
	 * @param e Value to get the floor of.
	 */
	public static inline function floorInt(e:Float) {
		var r = Std.int(e);
		if (e < 0 && r != e)
			r--;
		return r;
	}

	/**
	 * Sets a SoundFrontEnd's music to a FlxSound.
	 * Example: `FlxG.sound.setMusic(music);`
	 * @param frontEnd SoundFrontEnd to set the music of
	 * @param music Music
	 */
	public static function setMusic(frontEnd:SoundFrontEnd, music:FlxSound) {
		frontEnd.list.remove(music);
		frontEnd.music = music;
	}
}

/**
 * SFXs to play using `playMenuSFX`.
 */
enum abstract CoolSfx(Int) from Int {
	var SCROLL = 0;
	var CONFIRM = 1;
	var CANCEL = 2;
	var CHECKED = 3;
	var UNCHECKED = 4;
	var WARNING = 5;
}