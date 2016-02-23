using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;

class Page2View extends Ui.View 
{
	
	function initialize ( )
	{
	}

    function onLayout(dc)
    {
      	setLayout( Rez.Layouts.Page2Layout( dc ) );
 
 		onUpdate( dc );       
       
    }

	function setField ( dc, drawableId, text )
	{
        var drawable;
        
        //set the interval name
        drawable = View.findDrawableById( drawableId );
        drawable.setText( text );
        drawable.draw(dc);
	}
	
    function onUpdate(dc)
    {
   		var page2DistanceDrawable;
    	var page2TimeDrawable;
    	var page2PaceDrawable;
    	var value;
        
		// Update the distance travelled
		setField( dc, "Page2Distance", getCurrentDistance() );
		
		// Update the workout duration
		setField( dc, "Page2Time", getElapsedTime() );
		
		// Update the current hr
		setField( dc, "Page2HR", getCurrentHeartRate() );
    
        View.onUpdate(dc);
        
    }
	
	function getCurrentDistance()
	{
    	var currentActivityInfo;
    	var distanceString;
    	
 		currentActivityInfo = Activity.getActivityInfo();    	
		distanceString = "0.00";
		
		if ( currentActivityInfo != null )
		{
			if ( currentActivityInfo.elapsedDistance != null )
			{
				distanceString = format( "$1$", [(currentActivityInfo.elapsedDistance / 1000).format("%4.2f")] );
			}
		}
		
		return distanceString;
	}
	
	function getElapsedTime()
	{
		var hours;
		var minutes;
		var seconds;
		var secString;
		var minString;
    	var totalTime;
		
		hours = 0;
    	minutes = 0;
    	seconds = 0;
    	
 		totalTime = Activity.getActivityInfo().elapsedTime;    	

		if ( totalTime != null )
		{
			minutes = totalTime / 60000;
			seconds = ( totalTime % 60000 ) / 1000;
		}

		secString = seconds > 9 ? seconds.toString() : format( "0$1$", [ seconds.toString() ]);
		minString = minutes > 9 ? minutes.toString() : format( "0$1$", [ minutes.toString() ] );
		
		return format( "$1$:$2$", [ minString , secString ] );
	}

	
	function getCurrentHeartRate()
	{
    	var currentActivityInfo;
    	var heartRateString;
    	
 		currentActivityInfo = Activity.getActivityInfo();    	
		heartRateString = "__";
		
		if ( currentActivityInfo != null )
		{
			if ( currentActivityInfo.currentHeartRate != null )
			{
				heartRateString = format( "$1$", [(currentActivityInfo.currentHeartRate).toString()] );
			}
		}
		
		return heartRateString;
	}

}

