using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class IntervalTimerListView extends Ui.View 
{
	
    function onLayout(dc)
    {
    	setLayout( Rez.Layouts.WorkoutListLayout( dc ) );
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
		
		View.onUpdate ( dc );

    }
}

