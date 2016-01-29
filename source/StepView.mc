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
    	var nextStepInfo;
    	var activity;
    	
    	stepInfo = _workout.getCurrentStepInfo(); 	
    	nextStepInfo = _workout.getNextStepInfo();
        
        if ( stepInfo["type"] == STEP_LAP )
        {
        	lapStepView( dc, stepInfo );
        }
        else if ( stepInfo["type"] == STEP_TIME )
        {
        	timeStepView( dc, stepInfo );
        }
        else if ( stepInfo["type"] == WORKOUT )
        {
        	completeStepView( dc, stepInfo );
        }
        else
        {
        }
        
        if ( nextStepInfo == null )
        {
        	clearNextStepView( dc );
        }
        else if ( nextStepInfo["type"] == STEP_LAP )
        {
        	lapNextStepView( dc, nextStepInfo );
        }
        else if ( nextStepInfo["type"] == STEP_TIME )
        {
        	timeNextStepView( dc, nextStepInfo );
        }
        else if ( nextStepInfo["type"] == WORKOUT )
        {
        	completeNextStepView( dc, nextStepInfo );
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
    	
    	var intervalRepeatStepDrawable;
    	var intervalRepeatDividerDrawable;
    	var intervalRepeatCountDrawable;
    	var intervalRepeatStep;
    	var intervalRepeatDivider;
    	var intervalRepeatCount;
    	
    	if ( stepInfo["repeatStep"] > 0 )
    	{
    		intervalRepeatStep = stepInfo["repeatStep"].toString();
    		intervalRepeatDivider = "/";
    		intervalRepeatCount = stepInfo["repeatTotal"].toString();
    	}
    	else
    	{
    		intervalRepeatStep = "";
    		intervalRepeatDivider = "";
    		intervalRepeatCount = "";
    	}
        
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
        
        //set the interval repeat step
        intervalRepeatStepDrawable = View.findDrawableById("IntervalRepeatStep");
        intervalRepeatStepDrawable.setText( intervalRepeatStep );
        intervalRepeatStepDrawable.draw(dc);
        
        //set the interval repeat divider
        intervalRepeatDividerDrawable = View.findDrawableById("IntervalRepeatDivider");
        intervalRepeatDividerDrawable.setText( intervalRepeatDivider );
        intervalRepeatDividerDrawable.draw(dc);
        
        //set the interval repeat count
        intervalRepeatCountDrawable = View.findDrawableById("IntervalRepeatCount");
        intervalRepeatCountDrawable.setText( intervalRepeatCount );
        intervalRepeatCountDrawable.draw(dc);

	}

	function completeStepView ( dc, stepInfo )
	{
     	var intervalLengthDrawable;
    	var intervalLengthUnitDrawable;
    	var intervalName = stepInfo["name"];
    	var intervalUntilText = "";
    	var intervalLength = "";
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

	function timeNextStepView ( dc, stepInfo )
	{
     	var intervalLengthDrawable;
    	var intervalLengthUnitDrawable;
     	var intervalName = stepInfo["name"];
    	var intervalUntilText = "For";
    	var intervalLength = stepInfo["until"].toString();
    	var intervalLengthUnit = "sec";
        
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

	function completeNextStepView ( dc, stepInfo )
	{
     	var intervalLengthDrawable;
    	var intervalLengthUnitDrawable;
     	var intervalName = stepInfo["name"];
    	var intervalUntilText = "";
    	var intervalLength = "";
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

	function clearNextStepView ( dc )
	{
     	var intervalLengthDrawable;
    	var intervalLengthUnitDrawable;
     	var intervalName = "";
    	var intervalUntilText = "";
    	var intervalLength = "";
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

