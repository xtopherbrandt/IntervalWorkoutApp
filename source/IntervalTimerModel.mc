using Toybox.ActivityRecording;
using Toybox.Activity;
using Toybox.Lang;

enum
{
	WORKOUT,
	REPEATER,
	STEP_LAP,
	STEP_TIME,
	STEP_DISTANCE,
	SET_ON_TIME,
	SET_ON_DISTANCE
}

// The base class for all steps
// A step is a basic block within a workout. All steps have a name, a performance target, an onStart method and a callback to call when they are done.
class IntervalStepBaseModel 
{
	var name;
	var performanceTarget; //string description for now, eventually describe in code
	var doneCallback;
	var repeats;
	
	function initialize( stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		name = stepName;
		performanceTarget = stepPerformanceTarget;
		doneCallback = stepDoneCallback;
		if ( repeatInfo != null )
		{
			repeats = repeatInfo;
		}
		else
		{
			repeats = new RepeatAttribute(0,0);
		}
	}
	
	function onStart()
	{
	}
	
	function getNextStepInfo()
	{
		return null;
	}
}

// A strong data type that ensures the repeat step ID is less than or equal to the total repeat count
class RepeatAttribute
{
	hidden var _stepId = 0;
	hidden var _count = 0;
	hidden var _initialized = false;
	
	function initialize( repeatStepId, repeatCount )
	{
		if ( repeatStepId <= repeatCount && repeatStepId > 0 )
		{
			_stepId = repeatStepId;
			_count = repeatCount;
			_initialized = true;
		}
	}
	
	function getStepId()
	{
		return _stepId;
	}
	
	function getCount()
	{
		return _count;
	}
	
	function isInitialized()
	{
		return _initialized;
	}
}

// A simple interval step which ends when the lap (back) button is pushed.
class LapIntervalModel extends IntervalStepBaseModel
{
	
	function initialize( stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo );
	}
	
	function onStart()
	{
		System.println ("Lap Interval Started " + name);
	}

	function onLap()
	{
		// Call the done callback
		doneCallback.invoke();
	}
	
	function getCurrentStepInfo()
	{
		var stepId = repeats.getStepId();
		var count = repeats.getCount();
		return { "name" => name, "until" => "Lap Button", "type" => STEP_LAP, "repeatStep" => stepId, "repeatTotal" => count };
	}

}

// An interval step which ends once the specified distance is reached within this interval.
// For example, run for 1Km.
class DistanceIntervalModel extends IntervalStepBaseModel
{
	var distance;
	
	function initialize( intervalDistance, stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		distance = intervalDistance;
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo );
	}
	
	function onStart()
	{
	}

	function onLap()
	{
		// Call the done callback
		doneCallback.invoke();
	}

}

// An interval step which ends once the specified time has passed within this interval.
// For example, recover for 60 seconds.
class TimeIntervalModel extends IntervalStepBaseModel
{
	var duration;
	var currentCount;
	var startActivityInfo;
	var endActivityInfo;
	
	function initialize(  intervalDuration, stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		duration = intervalDuration;
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo );
		startActivityInfo = null;
		endActivityInfo = null;
	}
	
	function onStart()
	{
		System.println ("Time Interval Started: " + name);
		
		// Take a snapshot of the activity at the start of the step
		startActivityInfo = Activity.getActivityInfo();
	}

	function onLap()
	{
		// Take a snapshot of the activity at the end of this step
		endActivityInfo = Activity.getActivityInfo();
		
		// Call the done callback
		doneCallback.invoke();
	}
	
	function getCurrentStepInfo()
	{
		var currentActivityInfo;
		var remainingDuration;
		
		currentActivityInfo = Activity.getActivityInfo();

		// if the activity is running
		if ( startActivityInfo != null && startActivityInfo.elapsedTime != null && endActivityInfo == null )
		{
			// Calculate the remaining number of seconds in this step
			remainingDuration = ((startActivityInfo.elapsedTime + duration) - currentActivityInfo.elapsedTime) / 1000;
		}
		else if ( endActivityInfo != null )
		{
			remainingDuration = 0;
		}
		else
		{
			remainingDuration = duration / 1000;
		}
		
		return {"name" => name, "until" => remainingDuration, "type" => STEP_TIME, "repeatStep" => repeats.getStepId(), "repeatTotal" => repeats.getCount() };
	}

}

// An interval step type that has a work step added to it (like lap, distance or time) and includes an embedded rest step
// Allows for intervals that repeat on a certain distance: can do stuff like 2 x 500m on 1000m --> every 1Km start a 500 m work interval.
class OnTimeIntervalModel extends IntervalStepBaseModel
{
	var totalTime;		// total length of this duration step including the work step
	var workStep;		//definition of the work step
	
	function initialize( totalIntervalDuration, workIntervalStep, stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		totalTime = totalIntervalDuration;
		workStep = workIntervalDistance;
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo );
	}

}

// A repeater step which allows a set of interval steps to be repeated a specified number of times.
// A repeater contains a collection of other interval steps which are repeated in the same order everytime.
// A repeater may also contain another repeater.
// For example repeat the following 5 times: run 500 m (distance step), walk 60 seconds (time step)
class IntervalRepeatModel extends IntervalStepBaseModel
{

	var repeatCount;
	var currentRepeat;
	var currentStepId;
	var stepCount;
	var intervalSteps; 	// an array of IntervalStepBaseModel
	
	function initialize( intervalRepeatCount, numberOfSteps, stepName, stepPerformanceTarget, stepDoneCallback )
	{
		repeatCount = intervalRepeatCount;
		currentRepeat = 0;
		currentStepId = 0;
		stepCount = numberOfSteps;
		intervalSteps = new [numberOfSteps];
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback );
	}
	
	function onStart()
	{
		System.println ("Repeat Interval Started " + name);
		currentRepeat = 1;
		intervalSteps[currentStepId].onStart();
	}

	function onLap()
	{
		// Call the done callback
		intervalSteps[currentStepId].onLap();
	}
	
	function onDone()
	{
		// if the step we're on within the current repeat is within repeat set, then increment and start the next step		
		if ( currentStepId < stepCount - 1 )
		{
			currentStepId = currentStepId + 1;
			intervalSteps[currentStepId].onStart();
		} // otherwise, if our current repeat is with the total repeats, then increment and start a new repeat
		else if ( currentRepeat < repeatCount )
		{
			currentRepeat++;
			currentStepId = 0;
			intervalSteps[currentStepId].onStart();
		}
		else
		{
			doneCallback.invoke();
		}
	}
	
	function getDoneCallback()
	{
		return method( :onDone );
	}
	
	function getCurrentStepInfo()
	{
		return intervalSteps[currentStepId].getCurrentStepInfo();
	}
	
	function getNextStepInfo()
	{
		var nextStepInfo;
		
		// if this repeat hasn't started yet, then the next step is the first step
		if ( currentRepeat == 0 )
		{
			nextStepInfo = intervalSteps[0].getCurrentStepInfo();
		} // if the step we're on within the current repeat is within repeat set, then check the next step	
		else if ( currentStepId < stepCount - 1 )
		{
			// Ask the current step if it can return next step info (this would be the case if the next step was a repeater or an onTime/onDistance)
			nextStepInfo = intervalSteps[currentStepId].getNextStepInfo();
			
			// If the current step can't return next step info, then ask the next step info to the next step
			if ( nextStepInfo == null )
			{
				nextStepInfo = intervalSteps[currentStepId + 1].getNextStepInfo();
				
				// if the next step can't return next step info, then return the current step info for the next step
				if ( nextStepInfo == null )
				{
					nextStepInfo = intervalSteps[currentStepId + 1].getCurrentStepInfo();

				}
			}
			
		} // otherwise, if our current repeat is with the total repeats, then increment and start a new repeat
		else if ( currentRepeat < repeatCount )
		{
			// Ask the first step if it can return next step info (this would be the case if the first step was a repeater or an onTime/onDistance)
			nextStepInfo = intervalSteps[0].getNextStepInfo();
			
			// If the first step can't return next step info, then set the next step info to the next step
			if ( nextStepInfo == null )
			{
				nextStepInfo = intervalSteps[0].getCurrentStepInfo();
			}
		}
		else
		{
			// the next step isn't here, need to go up a level
			nextStepInfo = null;
		}
		
		return nextStepInfo;
	
	}
}

// The top level collection of the workout
class Workout
{
	var name;
	var workoutSteps; 	// an array of IntervalStepBaseModel
	var currentStepId;	// the array identity of the current step
	var totalSteps;
	hidden var _session;
	
	function initialize( workoutName, topLevelStepCount )
	{
		name = workoutName;
		currentStepId = 0;
		totalSteps = topLevelStepCount;
		workoutSteps = new [ topLevelStepCount ];
		_session = null;
	}
	
	// the lap button always moves to the next interval step
	function onLap()
	{
		workoutSteps[ currentStepId ].onLap();
	}
	
	function onStart()
	{
        if( Toybox has :ActivityRecording ) 
        {
            if( ( _session == null ) || ( _session.isRecording() == false ) ) {
                _session = ActivityRecording.createSession({ :sport => ActivityRecording.SPORT_RUNNING, :subSport => ActivityRecording.SUB_SPORT_CARDIO_TRAINING, :name => name});
                _session.start();
                workoutSteps[currentStepId].onStart();
            }
            else if( ( _session != null ) && _session.isRecording() ) 
            {
                _session.stop();
                _session.save();
                _session = null;
                System.println( "Failed starting activity recording session" );
            }
        }
	}
	
	// Callback called by a child step when it finishes
	function onDone()
	{
		
		if ( currentStepId < totalSteps - 1 )
		{
			currentStepId = currentStepId + 1;
			workoutSteps[currentStepId].onStart();
		}
		else
		{
	        if( Toybox has :ActivityRecording ) 
	        {
	            if( _session != null && _session.isRecording() ) 
	            {
	                _session.stop();
	                _session.save();
	                _session = null;
					currentStepId = currentStepId + 1;
	            }
	        }
		}
	}
	
	function getDoneCallback()
	{
		return method( :onDone );
	}
	
	function getCurrentStepInfo()
	{
		if ( currentStepId < totalSteps )
		{
			return workoutSteps[currentStepId].getCurrentStepInfo();
		}
		else
		{
			return {"name" => "Workout Complete!", "until" => "", "type" => WORKOUT };
		}
	}
	
	function getNextStepInfo()
	{
		var nextStepInfo;
		
		// if the step we're on within the workout set, then check the next step		
		if ( currentStepId < totalSteps - 1 )
		{
			// Ask the current step if it can return next step info (this would be the case if the next step was a repeater or an onTime/onDistance)
			nextStepInfo = workoutSteps[currentStepId].getNextStepInfo();
			
			// If the current step can't return next step info, then ask the next step info to the next step
			if ( nextStepInfo == null )
			{
				nextStepInfo = workoutSteps[currentStepId + 1].getNextStepInfo();
				
				// if the next step can't return next step info, then return the current step info for the next step
				if ( nextStepInfo == null )
				{
					nextStepInfo = workoutSteps[currentStepId + 1].getCurrentStepInfo();
				}
			}
			
		} // otherwise, if our current repeat is with the total repeats, then increment and start a new repeat
		else if ( currentStepId < totalSteps )
		{
			// the next step is the finish
			nextStepInfo = {"name" => "Workout Complete!", "until" => "", "type" => WORKOUT };
		}
		else
		{
			// no more steps
			nextStepInfo = null;
		}
		
		return nextStepInfo;
	}
}

function testWorkout ()
{
	var workout = new Workout( "Test Workout", 6);
	
	workout.workoutSteps[0] = new LapIntervalModel( "Warm Up", "Easy", workout.getDoneCallback() );
	
	workout.workoutSteps[1] = new TimeIntervalModel( 60000, "Hard Effort", "Work", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	workout.workoutSteps[2] = new TimeIntervalModel( 30000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	
	workout.workoutSteps[3] = new TimeIntervalModel( 60000, "Hard Effort", "Work", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );
	workout.workoutSteps[4] = new TimeIntervalModel( 30000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );

	workout.workoutSteps[5] = new LapIntervalModel( "Cool Down", "Easy", workout.getDoneCallback() );
	
	return workout;
}