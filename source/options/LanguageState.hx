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

    private var grpLangua:FlxTypedGroup<Alphabet>;
    private var langStuff:Array<Array<String>> = [];
    
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

        grpLangua = new FlxTypedGroup<Alphabet>();
		add(grpLangua);

        var pisspoop:Array<Array<String>> = [
            ['English'],
            ['Portuguese'],
            ['Spanish']
        ];

        for(i in pisspoop){
			langStuff.push(i);
		}

        for (i in 0...langStuff.length)
            {
                var isSelectable:Bool = !unselectableCheck(i);
                var slangText:Alphabet = new Alphabet(0, 70 * i, langStuff[i][0], !isSelectable, false);
                slangText.isMenuItem = true;
                slangText.screenCenter(X);
                slangText.yAdd -= 70;
                if(isSelectable) {
                    slangText.x -= 70;
                }
                slangText.forceX = slangText.x;
                //optionText.yMult = 90;
                slangText.targetY = i;
                grpLangua.add(slangText);
    
                if(isSelectable) {
                        if(curSelected == 0) curSelected = i;
                }
            }

        changeSelection();
        super.create();
    }

    override function update(elapsed:Float)
        {
            if (FlxG.sound.music.volume < 0.7)
            {
                FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
            }
    
            var upP = controls.UI_UP_P;
            var downP = controls.UI_DOWN_P;
    
            if (upP)
            {
                changeSelection(-1);
            }
            if (downP)
            {
                changeSelection(1);
            }
            if(controls.ACCEPT) {
                FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                FlxG.save.data.languaGame = langStuff[curSelected];
                MusicBeatState.switchState(new TitleState());
            }
            super.update(elapsed);
        }

    function changeSelection(change:Int = 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
            do {
                curSelected += change;
                if (curSelected < 0)
                    curSelected = langStuff.length - 1;
                if (curSelected >= langStuff.length)
                    curSelected = 0;
            } while(unselectableCheck(curSelected));
    
            var bullShit:Int = 0;
        }

    private function unselectableCheck(num:Int):Bool {
        return langStuff[num].length <= 1;
    }

}