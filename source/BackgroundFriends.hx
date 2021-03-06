package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundFriends extends FlxSprite
{
	var isScared:Bool = true;
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas("friends");
		animation.addByPrefix('hey', 'hey', 24, false);
		antialiasing = ClientPrefs.globalAntialiasing;

		getScared();

		animation.play('idle');
	}

	public function getScared():Void
	{
		isScared = !isScared;
		if (isScared) animation.addByIndices('idle', 'scared', CoolUtil.numberArray(14), "", 24, false);
		else animation.addByIndices('idle', 'idle', CoolUtil.numberArray(14), "", 24, false);
		
		dance();
	}

	public function dance():Void
	{

			animation.play('idle', true);

	}
}