package options;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flash.text.TextField;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class LanguageState extends MusicBeatState
{

    var curSelected:Int = 0;

    private var grpLangua:FlxTypedGroup<FlxSprite>;
    
    private var langStuff:Array<String> = [
    'English',
    'Portuguese',
    'Spanish'
    ];
    
    var bg:FlxSprite;
    
    override function create()
    {

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("selecting a language", null);
		#end

        FlxG.sound.playMusic(Paths.music('offsetSong'), 1, true);

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        grpLangua = new FlxTypedGroup<FlxSprite>();
		add(grpLangua);

		var scale:Float = 1;

        for (i in 0...langStuff.length)
            {
                var offset:Float = 20 - (Math.max(langStuff.length, 4) - 4) * 140;
			    var menuItem:FlxSprite = new FlxSprite(0, (i * 150)  + offset);
			    menuItem.scale.x = scale;
			    menuItem.scale.y = scale;
			    menuItem.frames = Paths.getSparrowAtlas('langmenu/lang_' + langStuff[i]);
			    menuItem.animation.addByPrefix('idle', langStuff[i] + " select", 24);
			    menuItem.animation.addByPrefix('selected', langStuff[i] + " white", 24);
			    menuItem.animation.play('idle');
                menuItem.screenCenter(X);
			    menuItem.ID = i;
			    grpLangua.add(menuItem);
			    var scr:Float = (langStuff.length - 4) * 0.135;
			    if(langStuff.length < 6) scr = 0;
			    menuItem.scrollFactor.set(0, scr);
			    menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			    //menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			    menuItem.updateHitbox();
            
        }

        changeItem();
        super.create();
    }

    var selectedSomethin:Bool = false;

    override function update(elapsed:Float)
        {

    
            var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
    
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
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    MusicBeatState.switchState(new options.OptionsState());
                }
    
                if (controls.ACCEPT)
                {
                
                        selectedSomethin = true;
                        FlxG.sound.play(Paths.sound('confirmMenu'));

                        FlxG.save.data.languaGame == langStuff[curSelected];
    
                        grpLangua.forEach(function(spr:FlxSprite)
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
                                    MusicBeatState.switchState(new options.OptionsState());
                                });
                            }
                        });
    
                        
                }
            }
    
            super.update(elapsed);
        }

        function changeItem(huh:Int = 0)
            {
                curSelected += huh;
        
                if (curSelected >= grpLangua.length)
                    curSelected = 0;
                if (curSelected < 0)
                    curSelected = grpLangua.length - 1;
                
        
                grpLangua.forEach(function(spr:FlxSprite)
                {
                    spr.animation.play('idle');
                    spr.updateHitbox();
        
                    if (spr.ID == curSelected)
                    {
                        spr.animation.play('selected');
                        var add:Float = 0;
                        if(grpLangua.length > 4) {
                            add = grpLangua.length * 8;
                        }
                    }
                });
            }

}