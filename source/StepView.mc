using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;

class StepView extends Ui.View 
{
    function onLayout(dc)
    {
    	var intervalLengthDrawable;
    	var intervalLengthUnitDrawable;
    	var intervalLength = "Lap Button";
    	var intervalLengthUnit = "";
    	
     	setLayout( Rez.Layouts.IntervalStepLayout( dc ) );
        
        //set the interval length
        intervalLengthDrawable = View.findDrawableById("IntervalLength");
        intervalLengthDrawable.setText( intervalLength );
        intervalLengthDrawable.draw(dc);
        
        //set the interval units
        intervalLengthUnitDrawable = View.findDrawableById("IntervalLengthUnit");
        intervalLengthUnitDrawable.setText( intervalLengthUnit );
        intervalLengthUnitDrawable.draw(dc);
        
       
    }
	
	
    function onUpdate(dc)
    {
        
        View.onUpdate(dc);
        
    }

	function update()
	{
    	Ui.requestUpdate();			
	}

}

