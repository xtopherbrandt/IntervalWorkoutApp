using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;

class StepView extends Ui.View 
{
	hidden var _workout;
	
	function initialize ( workout )
	{
		_workout = workout;
	}
	
    function onLayout(dc)
    {
    	
     	setLayout( Rez.Layouts.IntervalStepLayout( dc ) );
        onUpdate( dc );
    }
	
	
    function onUpdate(dc)
    {
    	var stepInfo;
    	
    	stepInfo = _workout.getCurrentStepInfo(); 	
        
        if ( stepInfo["type"] == STEP_LAP )
        {
        	lapStepView( dc, stepInfo );
        }
        else if ( stepInfo["type"] == STEP_TIME )
        {
        	timeStepView( dc, stepInfo );
        }
        else
        {
        }
        
        View.onUpdate(dc);
        
        return true;
        
    }

	function lapStepView ( dc, stepInfo )
	{
     	var intervalLengthDrawable;
    	var intervalLengthUnitDrawable;
    	var intervalName = stepInfo["name"];
    	var intervalUntilText = "Until";
    	var intervalLength = "Lap Button";
    	var intervalLengthUnit = "";
        
        //set the interval name
        intervalLengthDrawable = View.findDrawableById("IntervalName");
        intervalLengthDrawable.setText( intervalName );
        intervalLengthDrawable.draw(dc);
        
        //set the until / for
        intervalLengthDrawable = View.findDrawableById("Until");
        intervalLengthDrawable.setText( intervalUntilText );
        intervalLengthDrawable.draw(dc);
        
        //set the interval length
        intervalLengthDrawable = View.findDrawableById("IntervalLength");
        intervalLengthDrawable.setText( intervalLength );
        intervalLengthDrawable.draw(dc);
        
        //set the interval units
        intervalLengthUnitDrawable = View.findDrawableById("IntervalLengthUnit");
        intervalLengthUnitDrawable.setText( intervalLengthUnit );
        intervalLengthUnitDrawable.draw(dc);
	}

	function timeStepView ( dc, stepInfo )
	{
     	var intervalLengthDrawable;
    	var intervalLengthUnitDrawable;
    	var intervalName = stepInfo["name"];
    	var intervalUntilText = "For";
    	var intervalLength = stepInfo["until"].toString();
    	var intervalLengthUnit = "sec";
        
        //set the interval name
        intervalLengthDrawable = View.findDrawableById("IntervalName");
        intervalLengthDrawable.setText( intervalName );
        intervalLengthDrawable.draw(dc);
        
        //set the until / for
        intervalLengthDrawable = View.findDrawableById("Until");
        intervalLengthDrawable.setText( intervalUntilText );
        intervalLengthDrawable.draw(dc);
        
        //set the interval length
        intervalLengthDrawable = View.findDrawableById("IntervalLength");
        intervalLengthDrawable.setText( intervalLength );
        intervalLengthDrawable.draw(dc);
        
        //set the interval units
        intervalLengthUnitDrawable = View.findDrawableById("IntervalLengthUnit");
        intervalLengthUnitDrawable.setText( intervalLengthUnit );
        intervalLengthUnitDrawable.draw(dc);
	}
	

	function lapNextStepView ( dc, stepInfo )
	{
     	var intervalLengthDrawable;
    	var intervalLengthUnitDrawable;
    	var intervalName = stepInfo["name"];
    	var intervalUntilText = "Until";
    	var intervalLength = "Lap Button";
    	var intervalLengthUnit = "";
        
        //set the interval name
        intervalLengthDrawable = View.findDrawableById("NextIntervalName");
        intervalLengthDrawable.setText( intervalName );
        intervalLengthDrawable.draw(dc);
        
        //set the until / for
        intervalLengthDrawable = View.findDrawableById("NextUntil");
        intervalLengthDrawable.setText( intervalUntilText );
        intervalLengthDrawable.draw(dc);
        
        //set the interval length
        intervalLengthDrawable = View.findDrawableById("NextIntervalLength");
        intervalLengthDrawable.setText( intervalLength );
        intervalLengthDrawable.draw(dc);
        
        //set the interval units
        intervalLengthUnitDrawable = View.findDrawableById("NextIntervalLengthUnit");
        intervalLengthUnitDrawable.setText( intervalLengthUnit );
        intervalLengthUnitDrawable.draw(dc);
	}
	
}

