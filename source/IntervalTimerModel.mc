using Toybox.ActivityRecording;
using Toybox.Activity;
using Toybox.Lang;
using Toybox.Attention;
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
	
	function initialize( stepName, stepType, intervalDuration, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		name = stepName;
		intervalType = stepType;
		performanceTarget = stepPerformanceTarget;
		doneCallback = stepDoneCallback;
		initialDuration = intervalDuration;
		remainingDuration = intervalDuration;
		startActivityInfo = null;
		
		if ( repeatInfo != null )
		{
			repeats = repeatInfo;
		}
		else
		{
			repeats = new RepeatAttribute(0,0);
		}
	}

	function reset()
	{
		startActivityInfo = null;
		remainingDuration = initialDuration;
		
		if ( repeats != null )
		{
			repeats.reset();
		}
	}
		
	function onStart()
	{
		alert();
	}
	
	function alert()
	{
		var vibrationPattern = new [1];
		
		if ( !backlightIsOn )
		{
			backlightIsOn = true;
			Attention.backlight( true );
			backlightTimer.start( method(:backlightOff), 5000, false );
		}
		
		vibrationPattern[0] = new Attention.VibeProfile( 50, 1000 );
		
		Attention.vibrate(vibrationPattern);
	}
	
	function backlightOff ()
	{
		backlightIsOn = false;
		Attention.backlight( false );
		backlightTimer.stop();
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

	function reset()
	{
		_stepId = 0;
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
		IntervalStepBaseModel.onStart();
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
	
	function initialize(  intervalDuration, stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		IntervalStepBaseModel.initialize( stepName, STEP_DISTANCE, intervalDuration, stepPerformanceTarget, stepDoneCallback, repeatInfo );
	}
	
	function onStart()
	{
		// Take a snapshot of the activity at the start of the step
		startActivityInfo = Activity.getActivityInfo();
		IntervalStepBaseModel.onStart();
	}

	function onLap()
	{
		stepComplete();
	}
	
	function stepComplete()
	{
		
		// Call the done callback
		doneCallback.invoke();
	}
	
	function timerUpdate()
	{
		var currentActivityInfo;
		
		currentActivityInfo = Activity.getActivityInfo();
		
		// if the activity is running
		if ( startActivityInfo != null && startActivityInfo.elapsedDistance != null && ( currentActivityInfo.elapsedDistance - startActivityInfo.elapsedDistance < initialDuration ) )
		{
			// Calculate the remaining number of seconds in this step
			remainingDuration = ((startActivityInfo.elapsedDistance + initialDuration) - currentActivityInfo.elapsedDistance );
		}
		else if ( startActivityInfo != null && ( currentActivityInfo.elapsedDistance - startActivityInfo.elapsedDistance >= initialDuration ) )
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
		System.println( (remainingDuration / 1000).toString() );
		// if we're over 1500 m then return km
		if ( remainingDuration > 1000 )
		{
			return format( "$1$ km", [(remainingDuration / 1000).format("%4.2f")] );
		}
		else
		{
			return format( "$1$ m", [remainingDuration.format("%4d")] );
		}
	}

}

// An interval step which ends once the specified time has passed within this interval.
// For example, recover for 60 seconds.
class TimeIntervalModel extends IntervalStepBaseModel
{
	
	function initialize(  intervalDuration, stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		IntervalStepBaseModel.initialize( stepName, STEP_TIME, intervalDuration, stepPerformanceTarget, stepDoneCallback, repeatInfo );
	}
	
	function onStart()
	{
		// Take a snapshot of the activity at the start of the step
		startActivityInfo = Activity.getActivityInfo();
		IntervalStepBaseModel.onStart();
	}

	function onLap()
	{
		stepComplete();
	}
	
	function stepComplete()
	{
		
		// Call the done callback
		doneCallback.invoke();
	}
	
	function timerUpdate()
	{
		var currentActivityInfo;
		
		currentActivityInfo = Activity.getActivityInfo();
				
		// if the activity is running
		if ( startActivityInfo != null && startActivityInfo.timerTime != null && ( currentActivityInfo.timerTime - startActivityInfo.timerTime < initialDuration ) )
		{
			// Calculate the remaining number of seconds in this step
			remainingDuration = ((startActivityInfo.timerTime + initialDuration) - currentActivityInfo.timerTime);
		}
		else if ( currentActivityInfo.timerTime - startActivityInfo.timerTime >= initialDuration )
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
		secString = seconds > 9 ? seconds.toString() : format( "0$1$", [ seconds.toString() ] );
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

	function reset()
	{
		restStepStartActivityInfo = null;
		intervalState = ON_DURATION_NOT_STARTED;
	}
	
	function onStart()
	{
		
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
		
		IntervalStepBaseModel.onStart();
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
		alert();
		
		// Take a snapshot of the acitivity at the start of the rest interval
		restStepStartActivityInfo = Activity.getActivityInfo();
		
		// Change the state to the rest state
		intervalState = ON_DURATION_REST_STEP;
	}

	function stepComplete()
	{
		
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
			remainingDuration = ((startActivityInfo.timerTime + initialDuration) - currentActivityInfo.timerTime);
		
			// If we're out of time, limit the remaing duration to 0
			if ( remainingDuration <= 0 )
			{
				remainingDuration = 0;
			}
		}
		else if ( intervalState == ON_DURATION_REST_STEP )
		{
			// Calculate the remaining number of seconds in this step
			remainingDuration = ((startActivityInfo.timerTime + initialDuration) - currentActivityInfo.timerTime);
		
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

// An interval step type that has a work step added to it (like lap, distance or time) and includes an embedded rest step
// Allows for intervals that repeat on a certain distance: can do stuff like 2 x 500m on 1000m --> every 1Km start a 500 m work interval.
class OnDistanceIntervalModel extends IntervalStepBaseModel
{
	var workStep;		//definition of the work step
	var restStepStartActivityInfo;	// the activity time stamp at the start of the rest interval
	var intervalState;
	
	function initialize( totalIntervalDuration, workIntervalStep, stepName, stepPerformanceTarget, stepDoneCallback, repeatInfo )
	{
		workStep = workIntervalStep;
		intervalState = ON_DURATION_NOT_STARTED;
		IntervalStepBaseModel.initialize( stepName, SET_ON_DISTANCE, totalIntervalDuration, stepPerformanceTarget, stepDoneCallback, repeatInfo );
		
		// Set the done callback in the work step
		workStep.doneCallback = getDoneCallback();
	}

	function reset()
	{
		restStepStartActivityInfo = null;
		intervalState = ON_DURATION_NOT_STARTED;
	}
	
	function onStart()
	{
		
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
		
		IntervalStepBaseModel.onStart();
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
		alert();
		
		// Take a snapshot of the acitivity at the start of the rest interval
		restStepStartActivityInfo = Activity.getActivityInfo();
		
		// Change the state to the rest state
		intervalState = ON_DURATION_REST_STEP;
	}

	function stepComplete()
	{
		
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

			// Calculate the remaining distance in this step for the rest step
			remainingDuration = ((startActivityInfo.elapsedDistance + initialDuration) - currentActivityInfo.elapsedDistance);
		
			// If we're out of distance, limit the remaing duration to 0
			if ( remainingDuration <= 0 )
			{
				remainingDuration = 0;
			}
		}
		else if ( intervalState == ON_DURATION_REST_STEP )
		{
			// Calculate the remaining number of seconds in this step
			remainingDuration = ((startActivityInfo.elapsedDistance + initialDuration) - currentActivityInfo.elapsedDistance);
		
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
		System.println( (remainingDuration / 1000).toString() );
		// if we're over 1500 m then return km
		if ( remainingDuration > 1000 )
		{
			return format( "$1$ km", [(remainingDuration / 1000).format("%4.2f")] );
		}
		else
		{
			return format( "$1$ m", [remainingDuration.format("%4d")] );
		}
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
	
	function reset()
	{
		currentStepId = 0;
		_session = null;
		
		// re-initialize the workout
		for ( var i = 0; i < totalSteps; i++ )
		{
			workoutSteps[ i ].reset();
		}
	
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
            else if ( _session != null )
            {
            	_session.start();
            }
        }
	}
	
	function onStop()
	{
		if ( isRecording() )
		{
            _session.stop();
		}
	}
	
	function onSave()
	{
		if ( _session != null )
		{
            _session.save();
            _session = null;
        }
	}
	
	// the lap button always moves to the next interval step
	function onLap()
	{
		if ( currentStepId < totalSteps )
		{
			_session.addLap();
			workoutSteps[ currentStepId ].onLap();
			return true;
		}
		else
		{
			return false;
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
	var workouts = new [3];
	
	workouts[ 0 ] = simpleRepeatWorkout();
	workouts[ 1 ] = onTimeOnDistanceRepeatWorkout();
	workouts[ 2 ] = outAndBackWorkout();
	
	return workouts;
}

function simpleRepeatWorkout ()
{
	var workout = new Workout( "Simple Repeat Workout", 6);
	
	workout.workoutSteps[0] = new LapIntervalModel( "Warm Up", "Easy", workout.getDoneCallback() );
	
	workout.workoutSteps[1] = new TimeIntervalModel( 61000, "Hard Effort", "Work", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	workout.workoutSteps[2] = new TimeIntervalModel( 31000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	
	workout.workoutSteps[3] = new TimeIntervalModel( 60000, "Hard Effort", "Work", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );
	workout.workoutSteps[4] = new TimeIntervalModel( 30000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );

	workout.workoutSteps[5] = new LapIntervalModel( "Cool Down", "Easy", workout.getDoneCallback() );
	
	return workout;
}

function onTimeOnDistanceRepeatWorkout ()
{
	var workout = new Workout( "On-Time On-Distance Repeat Workout", 6);
	
	workout.workoutSteps[0] = new LapIntervalModel( "Warm Up", "Easy", workout.getDoneCallback() );
	
	var workStep1 = new LapIntervalModel( "15 Step Sprint", "Work", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	workout.workoutSteps[1] = new OnTimeIntervalModel( 30000, workStep1, "Sprint on 30s", "Easy", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	
	var workStep2 = new LapIntervalModel( "15 Step Sprint", "Work", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );
	workout.workoutSteps[2] = new OnTimeIntervalModel( 30000, workStep2, "Sprint on 30s", "Easy", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );
	
	var workStep3 = new LapIntervalModel( "500 m Hard", "Work", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	workout.workoutSteps[3] = new OnDistanceIntervalModel( 1000, workStep3, "Sprint on 30s", "Easy", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
	
	var workStep4 = new LapIntervalModel( "500 m Hard", "Work", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );
	workout.workoutSteps[4] = new OnDistanceIntervalModel( 1000, workStep4, "Sprint on 30s", "Easy", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );

	workout.workoutSteps[5] = new LapIntervalModel( "Cool Down", "Easy", workout.getDoneCallback() );
	
	return workout;
}

function outAndBackWorkout ()
{
	var workout = new Workout( "Out and Back Workout", 2);
	
	workout.workoutSteps[0] = new DistanceIntervalModel( 2000, "Out", "Steady", workout.getDoneCallback(), null );

	workout.workoutSteps[1] = new LapIntervalModel( "Back", "Steady", workout.getDoneCallback() );
	
	return workout;
}