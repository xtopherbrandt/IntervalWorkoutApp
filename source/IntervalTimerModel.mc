using Toybox.ActivityRecording;
using Toybox.Activity;
using Toybox.Lang;

/*

*/

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

enum
{
	ON_DURATION_NOT_STARTED,
	ON_DURATION_WORK_STEP,
	ON_DURATION_REST_STEP
}

// The base class for all steps
// A step is a basic block within a workout. All steps have a name, a performance target, an onStart method and a callback to call when they are done.
class IntervalStepBaseModel 
{
	var name;
	var intervalType;
	var performanceTarget; //string description for now, eventually describe in code
	var doneCallback;
	var repeats;
	var initialDuration;
	var remainingDuration;	// a numeric representation of the remaining duration. Each supertype is responsible for providing a string representation
	var startActivityInfo;
	var endActivityInfo;
	
	function initialize( stepName, stepType, intervalDuration, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		name = stepName;
		intervalType = stepType;
		performanceTarget = stepPerformanceTarget;
		doneCallback = stepDoneCallback;
		initialDuration = intervalDuration;
		remainingDuration = intervalDuration;
		
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
	
	function timerUpdate()
	{
	}
	
	function getRemainingDuration()
	{
		return "";
	}
	
	function getChildStep()
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
		IntervalStepBaseModel.initialize( stepName, STEP_LAP, 0, stepPerformanceTarget, stepDoneCallback, repeatInfo );
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

}

// An interval step which ends once the specified distance is reached within this interval.
// For example, run for 1Km.
class DistanceIntervalModel extends IntervalStepBaseModel
{
	
	function initialize( intervalDistance, stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		IntervalStepBaseModel.initialize( stepName, STEP_DISTANCE, intervalDistance, stepPerformanceTarget, stepDoneCallback, repeatInfo );
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
	
	function initialize(  intervalDuration, stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		IntervalStepBaseModel.initialize( stepName, STEP_TIME, intervalDuration, stepPerformanceTarget, stepDoneCallback, repeatInfo );
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
		stepComplete();
	}
	
	function stepComplete()
	{
		// Take a snapshot of the activity at the end of this step
		endActivityInfo = Activity.getActivityInfo();
		
		// Call the done callback
		doneCallback.invoke();
	}
	
	function timerUpdate()
	{
		var currentActivityInfo;
		
		currentActivityInfo = Activity.getActivityInfo();

		// if the activity is running
		if ( startActivityInfo != null && startActivityInfo.elapsedTime != null && endActivityInfo == null )
		{
			// Calculate the remaining number of seconds in this step
			remainingDuration = ((startActivityInfo.elapsedTime + initialDuration) - currentActivityInfo.elapsedTime);
		}
		else if ( endActivityInfo != null )
		{
			remainingDuration = 0;
		}
		else
		{
			remainingDuration = initialDuration ;
		}
		
		// Check if we're done
		if ( remainingDuration <= 0 )
		{
			stepComplete();
		}
	}
	
	function getRemainingDuration()
	{
		var hours;
		var minutes;
		var seconds;
		var secString;
		var minString;
		
		hours = 0;
		minutes = remainingDuration / 60000;
		seconds = ( remainingDuration % 60000 ) / 1000;
		secString = seconds > 9 ? seconds.toString() : format( "0$1$", [ seconds.toString() ]);
		minString = minutes > 9 ? minutes.toString() : format( "0$1$", [ minutes.toString() ] );
		
		return format( "$1$:$2$", [ minString , secString ] );
	}

}

// An interval step type that has a work step added to it (like lap, distance or time) and includes an embedded rest step
// Allows for intervals that repeat on a certain distance: can do stuff like 2 x 500m on 1000m --> every 1Km start a 500 m work interval.
class OnTimeIntervalModel extends IntervalStepBaseModel
{
	var workStep;		//definition of the work step
	var restStepStartActivityInfo;	// the activity time stamp at the start of the rest interval
	var intervalState;
	
	function initialize( totalIntervalDuration, workIntervalStep, stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		workStep = workIntervalStep;
		intervalState = ON_DURATION_NOT_STARTED;
		IntervalStepBaseModel.initialize( stepName, SET_ON_TIME, totalIntervalDuration, stepPerformanceTarget, stepDoneCallback, repeatInfo );
		
		// Set the done callback in the work step
		workStep.doneCallback = getDoneCallback();
	}
	
	function onStart()
	{
		System.println ("On-Time Interval Started: " + name);
		
		// Take a snapshot of the activity at the start of the step
		startActivityInfo = Activity.getActivityInfo();
		
		// Start the work step
		if ( workStep != null )
		{		
			// Change the state to the work step
			intervalState = ON_DURATION_WORK_STEP;
			
			workStep.onStart();
		}
		else
		{
			// Change the state to the work step
			intervalState = ON_DURATION_REST_STEP;
		}
	}

	function onLap()
	{
		if ( intervalState == ON_DURATION_WORK_STEP )
		{
			workStep.onLap();
		}
		else
		{
			stepComplete();
		}
	}
	
	// Callback called by a work step when it finishes
	function onDone()
	{
		// Take a snapshot of the acitivity at the start of the rest interval
		restStepStartActivityInfo = Activity.getActivityInfo();
		
		// Change the state to the rest state
		intervalState = ON_DURATION_REST_STEP;
	}

	function stepComplete()
	{
		// Take a snapshot of the activity at the end of this step
		endActivityInfo = Activity.getActivityInfo();
		
		// Call the done callback
		doneCallback.invoke();
	}

	function timerUpdate()
	{
		var currentActivityInfo;
		
		currentActivityInfo = Activity.getActivityInfo();

		// if the work step is running, pass this update through
		if ( intervalState == ON_DURATION_WORK_STEP )
		{
			workStep.timerUpdate();

			// Calculate the remaining number of seconds in this step for the rest step
			remainingDuration = ((startActivityInfo.elapsedTime + initialDuration) - currentActivityInfo.elapsedTime);
		
			// If we're out of time, limit the remaing duration to 0
			if ( remainingDuration <= 0 )
			{
				remainingDuration = 0;
			}
		}
		else if ( intervalState == ON_DURATION_REST_STEP )
		{
			// Calculate the remaining number of seconds in this step
			remainingDuration = ((startActivityInfo.elapsedTime + initialDuration) - currentActivityInfo.elapsedTime);
		
			// Check if we're done
			if ( remainingDuration <= 0 )
			{
				stepComplete();
			}
		}
		else
		{
			remainingDuration = initialDuration ;
		}
	}
	
	function getDoneCallback()
	{
		return method( :onDone );
	}

	function getChildStep()
	{
		if ( intervalState == ON_DURATION_NOT_STARTED || intervalState == ON_DURATION_WORK_STEP )
		{
			// if there is a workstep
			if ( workStep != null )
			{
				// if the work step has a child, return it, otherwise return the work step
				if ( workStep.getChildStep() != null )
				{
					return workStep.getChildStep();
				}
				else
				{
					return workStep;
				}
			}
		}
		
		// if we're in the rest state or there is no work step then return null which will have this object passed as the child
		return null;
	}
	
	function getNextStepInfo ()
	{
		if ( intervalState == ON_DURATION_NOT_STARTED && workStep != null )
		{
			if ( workStep.getNextStepInfo() != null )
			{
				return workStep.getNextStepInfo();
			}
			else
			{
				return workStep;
			}
		}
		else if ( intervalState == ON_DURATION_WORK_STEP && remainingDuration > 0 ) // if we're on the work step and we still have time to recover, return this as the next step
		{
			return weak().get();
		}
		
		// if we're in the rest state or there is no work step then return null which will have this object passed as the child
		return null;
	}
	
	function getRemainingDuration()
	{
		var hours;
		var minutes;
		var seconds;
		var secString;
		var minString;
		
		hours = 0;
		minutes = remainingDuration / 60000;
		seconds = ( remainingDuration % 60000 ) / 1000;
		secString = seconds > 9 ? seconds.toString() : format( "0$1$", [ seconds.toString() ]);
		minString = minutes > 9 ? minutes.toString() : format( "0$1$", [ minutes.toString() ] );
		
		return format( "$1$:$2$", [ minString , secString ] );
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
	
	function getNextStepInfo()
	{
		var nextStepInfo;
		
		// if this repeat hasn't started yet, then the next step is the first step
		if ( currentRepeat == 0 )
		{
			nextStepInfo = intervalSteps[0];
		} // if the step we're on within the current repeat is within repeat set, then check the next step	
		else if ( currentStepId < stepCount - 1 )
		{
			// Ask the current step if it can return next step info (this would be the case if the next step was a repeater or an onTime/onDistance)
			nextStepInfo = intervalSteps[currentStepId].getNextStepInfo();
			
			// If the current step can't return next step info, then ask the next step info to the next step
			if ( nextStepInfo == null )
			{
				nextStepInfo = intervalSteps[currentStepId + 1].getChildStep();
				
				// if the next step can't return next step info, then return the current step info for the next step
				if ( nextStepInfo == null )
				{
					nextStepInfo = intervalSteps[currentStepId + 1];

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

class completeWorkoutModel extends IntervalStepBaseModel
{
	function initialize()
	{
		IntervalStepBaseModel.initialize( "Workout Complete", WORKOUT );
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
	hidden var _completeStep;
	
	function initialize( workoutName, topLevelStepCount )
	{
		name = workoutName;
		currentStepId = 0;
		totalSteps = topLevelStepCount;
		workoutSteps = new [ topLevelStepCount ];
		_session = null;
		_completeStep = new completeWorkoutModel();
	}
	
	function isRecording()
	{
        if( Toybox has :ActivityRecording ) 
        {
            if( ( _session != null ) && _session.isRecording() ) 
            {
            	return true;
           	}
        }
        
        return false;
	}
	
	function onStart()
	{
		if ( isRecording() )
		{
            _session.stop();
            _session.save();
            _session = null;
            System.println( "Was already recording. Recording stopped." );
		}
		
        if( Toybox has :ActivityRecording ) 
        {
            if( ( _session == null ) || ( _session.isRecording() == false ) ) {
                _session = ActivityRecording.createSession({ :sport => ActivityRecording.SPORT_RUNNING, :subSport => ActivityRecording.SUB_SPORT_CARDIO_TRAINING, :name => name});
                _session.start();
                workoutSteps[currentStepId].onStart();
            }
        }
	}
	
	function onStop()
	{
		if ( isRecording() )
		{
            _session.stop();
            _session.save();
            _session = null;
		}
	}
	
	// the lap button always moves to the next interval step
	function onLap()
	{
		if ( currentStepId < totalSteps )
		{
			workoutSteps[ currentStepId ].onLap();
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
	
	// periodic update of the workout to update the remaining duration of the current step and move to the next step when done
	function timerUpdate()
	{
		if ( currentStepId < totalSteps )
		{
			workoutSteps[ currentStepId ].timerUpdate();
		}
	}
	
	function getChildStep()
	{
		if ( currentStepId < totalSteps )
		{
			if ( workoutSteps[currentStepId].getChildStep() == null )
			{
				return workoutSteps[currentStepId];
			}
			else
			{
				return workoutSteps[currentStepId].getChildStep();
			}
			
		}
		
		return _completeStep;
	}
	
	function getDoneCallback()
	{
		return method( :onDone );
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
				nextStepInfo = workoutSteps[currentStepId + 1].getChildStep();
				
				// if the next step can't return next step info, then return the current step info for the next step
				if ( nextStepInfo == null )
				{
					nextStepInfo = workoutSteps[currentStepId + 1];
				}
			}
			
		} // otherwise, if our current repeat is with the total repeats, then increment and start a new repeat
		else if ( currentStepId < totalSteps )
		{
			// the next step is the finish
			nextStepInfo = _completeStep ;
		}
		else
		{
			// no more steps
			nextStepInfo = null;
		}
		
		return nextStepInfo;
	}
}

function testWorkouts ()
{
	var workouts = new [2];
	
	workouts[ 0 ] = simpleRepeatWorkout();
	workouts[ 1 ] = onTimeRepeatWorkout();
	
	return workouts;
}

function simpleRepeatWorkout ()
{
	var workout = new Workout( "Simple Repeat Workout", 6);
	
	workout.workoutSteps[0] = new LapIntervalModel( "Warm Up", "Easy", workout.getDoneCallback() );
	
	workout.workoutSteps[1] = new TimeIntervalModel( 60000, "Hard Effort", "Work", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	workout.workoutSteps[2] = new TimeIntervalModel( 30000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	
	workout.workoutSteps[3] = new TimeIntervalModel( 60000, "Hard Effort", "Work", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );
	workout.workoutSteps[4] = new TimeIntervalModel( 30000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );

	workout.workoutSteps[5] = new LapIntervalModel( "Cool Down", "Easy", workout.getDoneCallback() );
	
	return workout;
}

function onTimeRepeatWorkout ()
{
	var workout = new Workout( "On-Time Repeat Workout", 4);
	
	workout.workoutSteps[0] = new LapIntervalModel( "Warm Up", "Easy", workout.getDoneCallback() );
	
	var workStep1 = new LapIntervalModel( "15 Step Sprint", "Work", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	workout.workoutSteps[1] = new OnTimeIntervalModel( 30000, workStep1, "Sprint on 30s", "Easy", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	
	var workStep2 = new LapIntervalModel( "15 Step Sprint", "Work", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );
	workout.workoutSteps[2] = new OnTimeIntervalModel( 30000, workStep2, "Sprint on 30s", "Easy", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );

	workout.workoutSteps[3] = new LapIntervalModel( "Cool Down", "Easy", workout.getDoneCallback() );
	
	return workout;
}