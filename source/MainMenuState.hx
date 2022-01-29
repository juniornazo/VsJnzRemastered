package;

import haxe.macro.Expr.DisplayKind;
import haxe.macro.Expr.ComplexType;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var jnzVersion:String = '1.0';
	public static var curSelected:Int = 0;

	#if ACHIEVEMENTS_ALLOWED
	var firstPrize:FlxSprite;
	#end
	var bumpGame:FlxSprite;
	var rollWrench:FlxSprite;

	var menuItems:FlxTypedGroup<FlxSprite>;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		'credits',
	];

	var spaceMenu:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-90, -100).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-90, -100).loadGraphic(Paths.image('menuBGMagenta'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		add(magenta);
		// magenta.scrollFactor.set();

		spaceMenu = new FlxSprite(-80).loadGraphic(Paths.image('menuSelect'));
		spaceMenu.scrollFactor.set();
		spaceMenu.setGraphicSize(Std.int(spaceMenu.width * 1.175));
		spaceMenu.updateHitbox();
		spaceMenu.screenCenter();
		spaceMenu.antialiasing = ClientPrefs.globalAntialiasing;
		add(spaceMenu);

		firstPrize = new FlxSprite(1200, 595);
		firstPrize.scrollFactor.set();
		firstPrize.frames = Paths.getSparrowAtlas('mousemenu/prize');
		firstPrize.animation.addByPrefix('idle', "shine", 24);
		firstPrize.animation.addByPrefix('selected', "prize", 24);
		firstPrize.animation.play('idle');
		firstPrize.antialiasing = ClientPrefs.globalAntialiasing;
		//firstPrize.setGraphicSize(Std.int(firstPrize.width * 0.58));
		firstPrize.updateHitbox();
		#if ACHIEVEMENTS_ALLOWED
		add(firstPrize);
		#end

		bumpGame = new FlxSprite(1000, 600);
		bumpGame.scrollFactor.set();
		bumpGame.frames = Paths.getSparrowAtlas('mousemenu/gump');
		bumpGame.animation.addByPrefix('idle', "bump", 24);
		bumpGame.animation.addByPrefix('selected', "gamer", 24);
		bumpGame.animation.play('idle');
		bumpGame.antialiasing = ClientPrefs.globalAntialiasing;
		//bumpGame.setGraphicSize(Std.int(bumpGame.width * 0.58));
		bumpGame.updateHitbox();
		add(bumpGame);

		rollWrench = new FlxSprite(30, 580);
		rollWrench.scrollFactor.set();
		rollWrench.frames = Paths.getSparrowAtlas('mousemenu/wrench');
		rollWrench.animation.addByPrefix('idle', "roll", 24);
		rollWrench.animation.addByPrefix('selected', "wrench", 24);
		rollWrench.animation.play('idle');
		rollWrench.antialiasing = ClientPrefs.globalAntialiasing;
		rollWrench.setGraphicSize(Std.int(rollWrench.width * 0.78));
		rollWrench.updateHitbox();
		add(rollWrench);


		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 20 - (Math.max(optionShit.length, 4) - 4) * 20;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(1105, 0, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(1032, 15, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(1068, 30, 0, "Vs Jnz Remastered' v" + jnzVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;
	var selectedSomeMouse:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if(FlxG.mouse.overlaps(bumpGame))
			{
				bumpGame.animation.play('selected');
			}
		else if(FlxG.mouse.overlaps(firstPrize))
			{
				firstPrize.animation.play('selected');
			}
		else if(FlxG.mouse.overlaps(rollWrench))
			{
				rollWrench.animation.play('selected');
			}
		else
			{
				rollWrench.animation.play('idle');
				firstPrize.animation.play('idle');
				bumpGame.animation.play('idle');	
			}

		if (!selectedSomeMouse)
		{
					
				if (FlxG.mouse.justPressed)
				{

				if(FlxG.mouse.overlaps(bumpGame))
					{
						CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
							
					}
					
				if (FlxG.mouse.overlaps(firstPrize))
					{
						selectedSomethin = true;
						selectedSomeMouse = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
						MusicBeatState.switchState(new AchievementsMenuState());
								
					}
				else if (FlxG.mouse.overlaps(rollWrench))
					{
						selectedSomethin = true;
						selectedSomeMouse = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
						MusicBeatState.switchState(new options.OptionsState());
									
					}
				}
		}

		if (!selectedSomethin)
		{
			

			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				selectedSomeMouse = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
			
					selectedSomethin = true;
					selectedSomeMouse = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
								}
							});
						}
					});

					
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				selectedSomeMouse = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}
	

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
        

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
			}
		});
	}
}
