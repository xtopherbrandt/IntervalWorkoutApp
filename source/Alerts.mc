using Toybox.Attention;


class Alert
{
	var backlightTimer;
	var backlightIsOn;

	function initialize()
	{
		backlightTimer = new Timer.Timer();
		backlightIsOn = false;
	}
	
	function vibrateAndLight()
	{
		var vibrationPattern = new [1];
		
		if ( !backlightIsOn )
		{
			backlightIsOn = true;
			Attention.backlight( true );
			backlightTimer.start( method( :backlightOff ), 5000, false );
		}
		
		vibrationPattern[0] = new Attention.VibeProfile( 50, 1000 );
		
		Attention.vibrate(vibrationPattern);
	}
	
	function backlightOff ()
	{
		Attention.backlight( false );
		backlightTimer.stop();
		backlightIsOn = false;
	}
}