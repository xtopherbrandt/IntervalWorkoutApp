using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;

class Page2View extends Ui.View 
{
    function onLayout(dc)
    {
    	var page2DistanceDrawable;
    	var page2TimeDrawable;
    	var page2PaceDrawable;
    	
     	setLayout( Rez.Layouts.Page2Layout( dc ) );
    
        
		// Update the distance travelled
		page2DistanceDrawable = View.findDrawableById("Page2Distance");
		page2DistanceDrawable.setText( "0.00" );
		page2DistanceDrawable.draw(dc);
		
		// Update the workout duration
		page2TimeDrawable = View.findDrawableById("Page2Time");
		page2TimeDrawable.setText( "0:00" );
		page2TimeDrawable.draw(dc);
		
		// Update the current pace
		page2PaceDrawable = View.findDrawableById("Page2Pace");
		page2PaceDrawable.setText( "0" );
		page2PaceDrawable.draw(dc);
        
       
    }
	
	function update()
	{
    	Ui.requestUpdate();			
	}
	
    function onUpdate(dc)
    {
   		var page2DistanceDrawable;
    	var page2TimeDrawable;
    	var page2PaceDrawable;
    	var value;
    
        
        View.onUpdate(dc);
        
		// Update the distance travelled
		page2DistanceDrawable = View.findDrawableById("Page2Distance");
		page2DistanceDrawable.setText( "0.00" );
		page2DistanceDrawable.draw(dc);
		
		// Update the workout duration
		page2TimeDrawable = View.findDrawableById("Page2Time");
		value = count1 / 2;
		System.println( value.toString() );
		page2TimeDrawable.setText( value.toString() );
		page2TimeDrawable.draw(dc);
		
		// Update the current pace
		page2PaceDrawable = View.findDrawableById("Page2Pace");
		page2PaceDrawable.setText( "0" );
		page2PaceDrawable.draw(dc);
        
    }


}

