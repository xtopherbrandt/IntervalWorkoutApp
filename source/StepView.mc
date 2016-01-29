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
        
        if ( stepInfo[ :interval_type ] == STEP_LAP )
        {
        	lapStepView( dc, stepInfo );
        }
        else if ( stepInfo[ :interval_type ] == STEP_TIME )
        {
        	timeStepView( dc, stepInfo );
        }
        else if ( stepInfo[ :interval_type ] == WORKOUT )
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
        else if ( nextStepInfo[ :interval_type ] == STEP_LAP )
        {
        	lapNextStepView( dc, nextStepInfo );
        }
        else if ( nextStepInfo[ :interval_type ] == STEP_TIME )
        {
        	timeNextStepView( dc, nextStepInfo );
        }
        else if ( nextStepInfo[ :interval_type ] == WORKOUT )
        {
        	completeNextStepView( dc, nextStepInfo );
        }
        else
        {
        	
        }

        View.onUpdate(dc);
        
        return true;
        
    }

	function setField ( dc, drawableId, text )
	{
        var drawable;
        
        //set the interval name
        drawable = View.findDrawableById( drawableId );
        drawable.setText( text );
        drawable.draw(dc);
	}
	
	function setCurrentStep ( dc, intervalName, intervalUntilText, intervalLength, intervalLengthUnit, intervalRepeatStep, intervalRepeatDivider, intervalRepeatCount )
	{
        
        //set the interval name
		setField( dc, "IntervalName", intervalName );
        
        //set the until / for
		setField( dc, "Until", intervalUntilText );
        
        //set the interval length
		setField( dc, "IntervalLength", intervalLength );
        
        //set the interval units
		setField( dc, "IntervalLengthUnit", intervalLengthUnit );
        
        //set the interval repeat step
		setField( dc, "IntervalRepeatStep", intervalRepeatStep );
        
        //set the interval repeat divider
		setField( dc, "IntervalRepeatDivider", intervalRepeatDivider );
        
        //set the interval repeat count
		setField( dc, "IntervalRepeatCount", intervalRepeatCount );
	}
	
	function setNextStep ( dc, intervalName, intervalUntilText, intervalLength, intervalLengthUnit, intervalRepeatStep, intervalRepeatDivider, intervalRepeatCount )
	{
        
        //set the interval name
		setField( dc, "NextIntervalName", intervalName );
        
        //set the until / for
		setField( dc, "NextUntil", intervalUntilText );
        
        //set the interval length
		setField( dc, "NextIntervalLength", intervalLength );
        
        //set the interval units
		setField( dc, "NextIntervalLengthUnit", intervalLengthUnit );
        
        //set the interval repeat step
		setField( dc, "NextIntervalRepeatStep", intervalRepeatStep );
        
        //set the interval repeat divider
		setField( dc, "NextIntervalRepeatDivider", intervalRepeatDivider );
        
        //set the interval repeat count
		setField( dc, "NextIntervalRepeatCount", intervalRepeatCount );
	}
	
	function lapStepView ( dc, stepInfo )
	{
    	var intervalName = stepInfo[ :interval_name ];
    	var intervalUntilText = "Until";
    	var intervalLength = "Lap Button";
    	var intervalLengthUnit = "";
    	var intervalRepeatStep;
    	var intervalRepeatDivider;
    	var intervalRepeatCount;
    	
    	if ( stepInfo[ :interval_repeat_step ] > 0 )
    	{
    		intervalRepeatStep = stepInfo[ :interval_repeat_step ].toString();
    		intervalRepeatDivider = "/";
    		intervalRepeatCount = stepInfo[ :interval_repeat_count ].toString();
    	}
    	else
    	{
    		intervalRepeatStep = "";
    		intervalRepeatDivider = "";
    		intervalRepeatCount = "";
    	}

		setCurrentStep( dc, intervalName, intervalUntilText, intervalLength, intervalLengthUnit, intervalRepeatStep, intervalRepeatDivider, intervalRepeatCount );
	}

	function timeStepView ( dc, stepInfo )
	{
		
    	var intervalName = stepInfo[ :interval_name ];
    	var intervalUntilText = "For";
    	var intervalLength = stepInfo[ :interval_duration ].toString();
    	var intervalLengthUnit = "";
    	var intervalRepeatStep;
    	var intervalRepeatDivider;
    	var intervalRepeatCount;
    	
    	if ( stepInfo[ :interval_repeat_step ] > 0 )
    	{
    		intervalRepeatStep = stepInfo[ :interval_repeat_step ].toString();
    		intervalRepeatDivider = "/";
    		intervalRepeatCount = stepInfo[ :interval_repeat_count ].toString();
    	}
    	else
    	{
    		intervalRepeatStep = "";
    		intervalRepeatDivider = "";
    		intervalRepeatCount = "";
    	}

		setCurrentStep( dc, intervalName, intervalUntilText, intervalLength, intervalLengthUnit, intervalRepeatStep, intervalRepeatDivider, intervalRepeatCount );

	}

	function completeStepView ( dc, stepInfo )
	{
    	var intervalName = stepInfo[ :interval_name ];
    	var intervalUntilText = "";
    	var intervalLength = "";
    	var intervalLengthUnit = "";
     	var intervalRepeatStep = "";
    	var intervalRepeatDivider = "";
    	var intervalRepeatCount = "";

		setCurrentStep( dc, intervalName, intervalUntilText, intervalLength, intervalLengthUnit, intervalRepeatStep, intervalRepeatDivider, intervalRepeatCount );
	}
	

	function lapNextStepView ( dc, stepInfo )
	{
    	var intervalName = stepInfo[ :interval_name ];
    	var intervalUntilText = "Until";
    	var intervalLength = "Lap Button";
    	var intervalLengthUnit = "";
     	var intervalRepeatStep;
    	var intervalRepeatDivider;
    	var intervalRepeatCount;
    	
    	if ( stepInfo[ :interval_repeat_step ] > 0 )
    	{
    		intervalRepeatStep = stepInfo[ :interval_repeat_step ].toString();
    		intervalRepeatDivider = "/";
    		intervalRepeatCount = stepInfo[ :interval_repeat_count ].toString();
    	}
    	else
    	{
    		intervalRepeatStep = "";
    		intervalRepeatDivider = "";
    		intervalRepeatCount = "";
    	}
        
		setNextStep ( dc, intervalName, intervalUntilText, intervalLength, intervalLengthUnit, intervalRepeatStep, intervalRepeatDivider, intervalRepeatCount )	;
	}

	function timeNextStepView ( dc, stepInfo )
	{
     	var intervalName = stepInfo[ :interval_name ];
    	var intervalUntilText = "For";
    	var intervalLength = stepInfo[ :interval_duration ].toString();
    	var intervalLengthUnit = "";
     	var intervalRepeatStep;
    	var intervalRepeatDivider;
    	var intervalRepeatCount;
    	
    	if ( stepInfo[ :interval_repeat_step ] > 0 )
    	{
    		intervalRepeatStep = stepInfo[ :interval_repeat_step ].toString();
    		intervalRepeatDivider = "/";
    		intervalRepeatCount = stepInfo[ :interval_repeat_count ].toString();
    	}
    	else
    	{
    		intervalRepeatStep = "";
    		intervalRepeatDivider = "";
    		intervalRepeatCount = "";
    	}
        
		setNextStep ( dc, intervalName, intervalUntilText, intervalLength, intervalLengthUnit, intervalRepeatStep, intervalRepeatDivider, intervalRepeatCount );
	}

	function completeNextStepView ( dc, stepInfo )
	{
     	var intervalName = stepInfo[ :interval_name ];
    	var intervalUntilText = "";
    	var intervalLength = "";
    	var intervalLengthUnit = "";
     	var intervalRepeatStep = "";
    	var intervalRepeatDivider = "";
    	var intervalRepeatCount = "";
         
		setNextStep ( dc, intervalName, intervalUntilText, intervalLength, intervalLengthUnit, intervalRepeatStep, intervalRepeatDivider, intervalRepeatCount );
	}

	function clearNextStepView ( dc )
	{
     	var intervalName = "";
    	var intervalUntilText = "";
    	var intervalLength = "";
    	var intervalLengthUnit = "";
     	var intervalRepeatStep = "";
    	var intervalRepeatDivider = "";
    	var intervalRepeatCount = "";
        
		setNextStep ( dc, intervalName, intervalUntilText, intervalLength, intervalLengthUnit, intervalRepeatStep, intervalRepeatDivider, intervalRepeatCount );
	}
	
}

