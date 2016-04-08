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
	WORKOUT_NOT_STARTED,
	WORKOUT_STARTED,
	WORKOUT_COMPLETE
}

enum
{
	ON_DURATION_NOT_STARTED,
	ON_DURATION_WORK_STEP,
	ON_DURATION_REST_STEP
}

enum
{
	REPEAT_SET_NOT_STARTED,
	REPEAT_SET_STARTED
}



class intervalFinderInterface
{
	// returns the current interval within this processor or step
	// returns null if there is no current interval
	function getCurrentInterval()
	{
		return null;
	}

	// returns the next interval within this processor or step	
	// returns null if there is no next interval
	function getNextInterval()
	{
		return null;
	}

}


// The base class for all steps
// A step is a basic block within a workout. All steps have a name, a performance target, an onStart method and a callback to call when they are done.

class IntervalStepBaseModel extends intervalFinderInterface
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
	
	function dispose()
	{
		name = null;
		intervalType = null;
		performanceTarget = null;
		doneCallback = null;
		repeats = null;
		initialDuration = null;
		startActivityInfo = null;
		remainingDuration = null;
	}
		
	function onStart()
	{

		alert.vibrateAndLight();
	}
	
	function timerUpdate()
	{
	}
	
	function getRemainingDuration()
	{
		return "";
	}
	
	function getCurrentInterval()
	{
		return self;
	}
	
	function getNextInterval()
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
		
		if ( startActivityInfo != null )
		{
			if ( startActivityInfo.elapsedDistance != null && currentActivityInfo.elapsedDistance != null )
			{
				// if the activity is running
				if ( ( currentActivityInfo.elapsedDistance - startActivityInfo.elapsedDistance < initialDuration ) )
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
			}
		}
		
		// Check if we're done
		if ( remainingDuration <= 0 )
		{
			stepComplete();
		}
	}
	
	function getRemainingDuration()
	{
		// if we're over 1000 m then return km
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
				
		if ( startActivityInfo != null )
		{
			if ( currentActivityInfo.timerTime != null && startActivityInfo.timerTime != null )
			{
		
				// if the activity is running
				if ( ( currentActivityInfo.timerTime - startActivityInfo.timerTime < initialDuration ) )
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
					
			}
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
class OnTimeProcessor extends intervalFinderInterface
{
	hidden var _workStep;		//definition of the work step
	hidden var _recoveryStep;
	var intervalState;
	var workoutDoneCallback;
	var workoutLapCallback;
	
	function initialize( stepConfiguration, doneCallback, lapCallback )
	{
		_workStep = WorkoutProcessor.GetStepProcessor( stepConfiguration[ "workStep" ], OnTimeProcessor.getDoneCallback(), lapCallback, null );
		_recoveryStep = new TimeIntervalModel( stepConfiguration[ "duration" ], "Recovery", null, OnTimeProcessor.getDoneCallback(), lapCallback, null ); 
		
		intervalState = ON_DURATION_NOT_STARTED;
		workoutDoneCallback = doneCallback;
		workoutLapCallback = lapCallback;
		
	}
	
	function dispose()
	{
		if ( _workStep != null )
		{
			_workStep.dispose();
			_workStep = null;
		}
		
		if ( _recoveryStep != null )
		{
			_recoveryStep.dispose();
			_recoveryStep = null;
		}
		
		intervalState = null;
	}
	
	function onStart()
	{
		
		// Start the work step
		if ( _workStep != null && _recoveryStep != null )
		{		
		
			// Take a snapshot of the activity at the start of the step
			// Set both the work step and recovery step to have the same start point
			_workStep.startActivityInfo = Activity.getActivityInfo();
			_recoveryStep.startActivityInfo = _workStep.startActivityInfo;
			
			// Change the state to the work step
			intervalState = ON_DURATION_WORK_STEP;
			
			_workStep.onStart();
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
			_workStep.onLap();
			
			// don't want to start the recovery step because it's really already running
		}
		else
		{
			stepComplete();
		}
	}
	
	// Callback called by a work step when it finishes
	function onDone()
	{
		alert.vibrateAndLight();

		if ( workoutLapCallback != null )
		{
			workoutLapCallback.invoke();
		}		
		
		// Change the state to the rest state
		intervalState = ON_DURATION_REST_STEP;
	}

	function stepComplete()
	{
		if ( workoutLapCallback != null )
		{
			workoutLapCallback.invoke();
		}
				
		// Call the workout done callback
		workoutDoneCallback.invoke();
	}

	function timerUpdate()
	{
		if ( intervalState == ON_DURATION_NOT_STARTED )
		{
			_workStep.timerUpdate();
		}
		else if ( intervalState == ON_DURATION_WORK_STEP )
		{
			_workStep.timerUpdate();
		}
		else if ( intervalState == ON_DURATION_REST_STEP )
		{
			_recoveryStep.timerUpdate();
		}
		else
		{
		}
	}
	
	function timerUpdate_old()
	{
		var currentActivityInfo;
		
		currentActivityInfo = Activity.getActivityInfo();

		if ( _workStep.startActivityInfo != null )
		{
			if ( _workStep.startActivityInfo.timerTime != null && currentActivityInfo.timerTime != null )
			{
				// if the work step is running, pass this update through
				if ( intervalState == ON_DURATION_WORK_STEP )
				{
					_workStep.timerUpdate();
		
					// Calculate the remaining number of seconds in this step for the rest step
					remainingDuration = (( _workStep.startActivityInfo.timerTime + initialDuration) - currentActivityInfo.timerTime);
				
					// If we're out of time, limit the remaing duration to 0
					if ( remainingDuration <= 0 )
					{
						remainingDuration = 0;
					}
				}
				else if ( intervalState == ON_DURATION_REST_STEP )
				{
					// Calculate the remaining number of seconds in this step
					remainingDuration = (( _workStep.startActivityInfo.timerTime + initialDuration) - currentActivityInfo.timerTime);
				
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
		}
	}
	
	function getDoneCallback()
	{
		return method( :onDone );
	}
	
	function getCurrentInterval ()
	{
		if ( intervalState == ON_DURATION_NOT_STARTED )
		{
			return _workStep;
		}
		else if ( intervalState == ON_DURATION_WORK_STEP )
		{
			return _workStep;
		}
		else if ( intervalState == ON_DURATION_REST_STEP )
		{
			return _recoveryStep;
		}
		else
		{
			return null;
		}
		
	}
	
	function getNextInterval()
	{
		if ( intervalState == ON_DURATION_NOT_STARTED )
		{
			return _recoveryStep;
		}
		else if ( intervalState == ON_DURATION_WORK_STEP )
		{
			return _recoveryStep;
		}
		else if ( intervalState == ON_DURATION_REST_STEP )
		{
			return null;
		}
		else
		{
			return null;
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
class OnDistanceProcessor extends intervalFinderInterface
{
	hidden var _workStep;		//definition of the work step
	hidden var _recoveryStep;
	var intervalState;
	var workoutDoneCallback;
	var workoutLapCallback;
	
	function initialize( stepConfiguration, doneCallback, lapCallback )
	{
		_workStep = WorkoutProcessor.GetStepProcessor( stepConfiguration[ "workStep" ], getDoneCallback(), lapCallback, null );
		_recoveryStep = new DistanceIntervalModel( stepConfiguration[ "duration" ], "Recovery", null, getDoneCallback(), lapCallback, null ); 
		
		intervalState = ON_DURATION_NOT_STARTED;
		workoutDoneCallback = doneCallback;
		workoutLapCallback = lapCallback;
		
	}
	
	function dispose()
	{
		if ( _workStep != null )
		{
			_workStep.dispose();
			_workStep = null;
		}
		
		if ( _recoveryStep != null )
		{
			_recoveryStep.dispose();
			_recoveryStep = null;
		}
		
		intervalState = null;
	}
	
	function onStart()
	{
		
		// Start the work step
		if ( _workStep != null && _recoveryStep != null )
		{		
		
			// Take a snapshot of the activity at the start of the step
			// Set both the work step and recovery step to have the same start point
			_workStep.startActivityInfo = Activity.getActivityInfo();
			_recoveryStep.startActivityInfo = _workStep.startActivityInfo;
			
			// Change the state to the work step
			intervalState = ON_DURATION_WORK_STEP;
			
			_workStep.onStart();
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
			_workStep.onLap();
			
			// don't want to start the recovery step because it's really already running
		}
		else
		{
			stepComplete();
		}
	}
	
	// Callback called by a work step when it finishes
	function onDone()
	{
		alert.vibrateAndLight();
		
		if ( workoutLapCallback != null )
		{
			workoutLapCallback.invoke();
		}
		
		// Change the state to the rest state
		intervalState = ON_DURATION_REST_STEP;
	}

	function stepComplete()
	{
		if ( workoutLapCallback != null )
		{
			workoutLapCallback.invoke();
		}
		
		
		// Call the workout done callback
		workoutDoneCallback.invoke();
	}

	function timerUpdate()
	{
		if ( intervalState == ON_DURATION_NOT_STARTED )
		{
			_workStep.timerUpdate();
		}
		else if ( intervalState == ON_DURATION_WORK_STEP )
		{
			_workStep.timerUpdate();
		}
		else if ( intervalState == ON_DURATION_REST_STEP )
		{
			_recoveryStep.timerUpdate();
		}
		else
		{
		}
	}

	function timerUpdate_old()
	{
		var currentActivityInfo;
		
		currentActivityInfo = Activity.getActivityInfo();

		if ( startActivityInfo != null )
		{
			if ( startActivityInfo.elapsedDistance != null && currentActivityInfo.elapsedDistance != null )
			{
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
		}
	}
	
	
	function getDoneCallback()
	{
		return method( :onDone );
	}
	
	function getCurrentInterval ()
	{
		if ( intervalState == ON_DURATION_NOT_STARTED )
		{
			return _workStep;
		}
		else if ( intervalState == ON_DURATION_WORK_STEP )
		{
			return _workStep;
		}
		else if ( intervalState == ON_DURATION_REST_STEP )
		{
			return _recoveryStep;
		}
		else
		{
			return null;
		}
		
	}
	
	function getNextInterval()
	{
		if ( intervalState == ON_DURATION_NOT_STARTED )
		{
			return _recoveryStep;
		}
		else if ( intervalState == ON_DURATION_WORK_STEP )
		{
			return _recoveryStep;
		}
		else if ( intervalState == ON_DURATION_REST_STEP )
		{
			return null;
		}
		else
		{
			return null;
		}
	}
		
	function getRemainingDuration()
	{
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
// A repeater step which allows a set of interval steps to be repeated a specified number of times.
// A repeater contains a collection of other interval steps which are repeated in the same order everytime.
// A repeater may also contain another repeater.
// For example repeat the following 5 times: run 500 m (distance step), walk 60 seconds (time step)
class RepeatProcessor extends intervalFinderInterface
{

	var repeatCount;
	var currentRepeat;
	var currentStepId;
	var stepCount;
	var currentState;
	var workoutDoneCallback;
	var workoutLapCallback;
	hidden var _steps;
	var name;
	var currentStepProcessor; // a processor step instance for the current step
	var nextStepProcessor;	// a processor step instance for the next step
	
	function initialize( stepConfiguration, doneCallback, lapCallback )
	{
		repeatCount = stepConfiguration[ "repeatCount" ];
		currentRepeat = 1;
		currentStepId = 0;
		stepCount = stepConfiguration[ "steps" ].size();
		_steps = stepConfiguration[ "steps" ];
		name = stepConfiguration[ "name" ];
		currentState = REPEAT_SET_NOT_STARTED;
		workoutDoneCallback = doneCallback;
		workoutLapCallback = lapCallback;
		
		updateStepState();
		
	}
	
	function dispose()
	{
		_steps = null;
		currentState = null;
		
		if ( currentStepProcessor != null )
		{
			currentStepProcessor.dispose();
			currentStepProcessor = null;
		}
		
		
		if ( nextStepProcessor != null )
		{
			nextStepProcessor.dispose();
			nextStepProcessor = null;
		}
	}
	
	function onStart()
	{
		System.println ("Repeat Interval Started " + name);
		currentStepProcessor.onStart();
		currentState = REPEAT_SET_STARTED;
	}

	function onLap()
	{
		
		// Call the done callback
		currentStepProcessor.onLap();
	}
	
	function onDone()
	{
		workoutLapCallback.invoke();
	
		// if the step we're on within the current repeat is within repeat set, then increment and start the next step		
		if ( currentStepId + 1 < stepCount )
		{
			updateStepState();
			currentStepProcessor.onStart();
		} // otherwise, if our current repeat is with the total repeats, then increment and start a new repeat
		else if ( currentRepeat < repeatCount )
		{
			updateStepState();
			currentStepProcessor.onStart();
		}
		else
		{
			workoutDoneCallback.invoke();
		}
	}
	
	// periodic update of the workout to update the remaining duration of the current step and move to the next step when done
	function timerUpdate()
	{
		if ( currentStepId < stepCount )
		{
			currentStepProcessor.timerUpdate();
		}
	}
	
	function updateStepState()
	{
		
		if ( currentState == REPEAT_SET_NOT_STARTED )
		{
			currentStepId = 0;
			
			if ( stepCount > 0 )
			{
				//set the current step
				currentStepProcessor = WorkoutProcessor.GetStepProcessor ( _steps[ 0 ], getDoneCallback(), workoutLapCallback, new RepeatAttribute( currentRepeat, repeatCount ) );
			}
			
			if ( stepCount > 1 ) 
			{
				nextStepProcessor = WorkoutProcessor.GetStepProcessor ( _steps[ 1 ], getDoneCallback(), workoutLapCallback, new RepeatAttribute( currentRepeat, repeatCount ) );
			}
		}
		else if ( currentState == REPEAT_SET_STARTED )
		{
				
			// update the current step
			// if we have more steps
			if ( currentStepId + 1 < stepCount )
			{
				currentStepId = currentStepId + 1;
			}// else, if we have more repeats
			else if ( currentRepeat + 1 <= repeatCount )
			{
				currentRepeat = currentRepeat + 1;
				currentStepId = 0;
			}
			
			currentStepProcessor.dispose();
			currentStepProcessor = nextStepProcessor;
			
			// update the next step
			// if we have more steps after this one
			if ( currentStepId + 1 < stepCount )
			{
				nextStepProcessor = WorkoutProcessor.GetStepProcessor ( _steps[ currentStepId + 1 ], getDoneCallback(), workoutLapCallback, new RepeatAttribute( currentRepeat, repeatCount ) );
			}// else, if we have more repeats
			else if ( currentRepeat + 1 <= repeatCount )
			{
				nextStepProcessor = WorkoutProcessor.GetStepProcessor ( _steps[ 0 ], getDoneCallback(), workoutLapCallback, new RepeatAttribute( currentRepeat + 1, repeatCount ) );
			}
			else
			{ 
				nextStepProcessor = null;
			}

		}
		else
		{

			// Update the current step
			currentStepId = currentStepId + 1;
			currentStepProcessor.dispose();
			currentStepProcessor = nextStepProcessor;
			currentStepProcessor.onStart();
			
			nextStepProcessor = null;
		}
	}
	
	function getDoneCallback()
	{
		return method( :onDone );
	}
	
	function getCurrentInterval()
	{
		return currentStepProcessor.getCurrentInterval();
	}
	
	function getNextInterval()
	{
		if ( currentStepProcessor.getNextInterval() != null )
		{
			return currentStepProcessor.getNextInterval();
		}
		else if ( nextStepProcessor != null )
		{
			return nextStepProcessor.getCurrentInterval();
		}
		else
		{
			return null;
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

// The main workout processor
class WorkoutProcessor extends intervalFinderInterface
{
	var workoutConfiguration;
	var currentStepId;			// the array identity of the current step within the workout Configuration
	var currentStepProcessor; // a processor step instance for the current step
	var nextStepProcessor;	// a processor step instance for the next step
	var currentState;
	hidden var _session;
	
	function initialize( workout )
	{
		currentState = WORKOUT_NOT_STARTED;
		workoutConfiguration = workout;
		currentStepId = 0;
		_session = null;
		
		updateStepState();
	}
	
	function dispose ()
	{
		workoutConfiguration = null;
		currentStepId = null;
		
		if ( currentStepProcessor != null )
		{
			currentStepProcessor.dispose();
			currentStepProcessor = null;
		}
		
		
		if ( nextStepProcessor != null )
		{
			nextStepProcessor.dispose();
			nextStepProcessor = null;
		}
		
		_session = null;
		
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
				
		var vibrationPattern = new [3];
		
		vibrationPattern[0] = new Attention.VibeProfile( 50, 500 );
		
		vibrationPattern[1] = new Attention.VibeProfile( 0, 500 );
		
		vibrationPattern[2] = new Attention.VibeProfile( 50, 500 );
		
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
				// note the name parameter must be < 15 characters on the Vivoactive, but is ignored by Garmin Connect
                _session = Toybox.ActivityRecording.createSession({ :sport => Toybox.ActivityRecording.SPORT_RUNNING, :subSport => Toybox.ActivityRecording.SUB_SPORT_CARDIO_TRAINING, :name => "Interval Run"});
                _session.start();
                currentStepProcessor.onStart();
            }
            else if ( _session != null )
            {
            	_session.start();
            }
            
            currentState = WORKOUT_STARTED;
        }
	}
		
	function onStop()
	{
		if ( isRecording() )
		{
        	System.println ("Stop");
            _session.stop();
		}
	}
	
	function onSave()
	{
		if ( _session != null )
		{
            _session.save();
            _session = null;
            System.println("Saved");
        }
	}
	
	// the lap button always moves to the next interval step
	function onLap()
	{
		
		if ( isRecording() && currentStepId + 1 < workoutConfiguration[ "steps" ].size() )
		{
			saveLap();
			currentStepProcessor.onLap();
			return true;
		}
		else if ( isRecording() && currentStepId < workoutConfiguration[ "steps" ].size() )
		{
			saveLap();
			currentStepProcessor.onLap();
			return true;
		}
		else
		{
			return false;
		}
	}
	
	function saveLap()
	{
		_session.addLap();
		
		return null;
	}
	
	// Callback called by a step processor when it finishes
	function onDone()
	{
		if ( currentStepId + 1 < workoutConfiguration[ "steps" ].size() )
		{
			updateStepState();
			currentStepProcessor.onStart();
			
		}
		else if ( currentStepId < workoutConfiguration[ "steps" ].size() )
		{
			// this is the end of the workout
			onStop();
		
			currentState = WORKOUT_COMPLETE;
			
			updateStepState();
		}
	}
	
	// periodic update of the workout to update the remaining duration of the current step and move to the next step when done
	function timerUpdate()
	{
		if ( currentStepId < workoutConfiguration[ "steps" ].size() )
		{
			currentStepProcessor.timerUpdate();
		}
	}
	
	function updateStepState()
	{
		
		if ( currentState == WORKOUT_NOT_STARTED )
		{
			currentStepId = 0;
			
			if ( workoutConfiguration[ "steps" ].size() > 0 )
			{
				//set the current step
				currentStepProcessor = GetStepProcessor ( workoutConfiguration[ "steps" ][ 0 ], getDoneCallback(), getLapCallback(), null );
			}
			
			if ( workoutConfiguration[ "steps" ].size() > 1 )
			{
				nextStepProcessor = GetStepProcessor ( workoutConfiguration[ "steps" ][ 1 ], getDoneCallback(), getLapCallback(), null );
			}
		}
		else if ( currentState == WORKOUT_STARTED )
		{
				 
			// if the current step is a complex step then
			// prompt it to update its state
			// get the current and next steps from it
			// when it returns null for the next step, get the step from the workout configuration
			
			// how do we know when to advance the workout step counter?
			// how do we deal with back to back complex steps
			
			// Update the current step
			currentStepId = currentStepId + 1;
			currentStepProcessor.dispose();
			currentStepProcessor = nextStepProcessor;
		
			// Set up the next step

			if ( currentStepId + 1 < workoutConfiguration[ "steps" ].size() )
			// if there are more steps in the configuration
			{
				nextStepProcessor = GetStepProcessor ( workoutConfiguration[ "steps" ][ currentStepId + 1 ], getDoneCallback(), getLapCallback(), null );
			}
			else
			{
				nextStepProcessor = new completeWorkoutModel();
			}

		}
		else
		{

			// Update the current step
			currentStepId = currentStepId + 1;
			currentStepProcessor.dispose();
			currentStepProcessor = nextStepProcessor;
			currentStepProcessor.onStart();
			
			nextStepProcessor = null;
		}
	}
	
	static function GetStepProcessor ( stepConfiguration, doneCallback, lapCallback, repeatInfo )
	{
		var step = null;
		
		if ( stepConfiguration[ "type" ] == STEP_LAP )
		{
			step = new LapIntervalModel( stepConfiguration[ "name" ], null, doneCallback, repeatInfo );
		}
		else if ( stepConfiguration[ "type" ] == STEP_TIME )
		{
			step = new TimeIntervalModel( stepConfiguration[ "duration" ], stepConfiguration[ "name" ], null, doneCallback, repeatInfo );
		}
		else if ( stepConfiguration[ "type" ] == STEP_DISTANCE )
		{
			step = new DistanceIntervalModel( stepConfiguration[ "duration" ], stepConfiguration[ "name" ], null, doneCallback, repeatInfo );
		}
		else if ( stepConfiguration[ "type" ] == SET_ON_TIME )
		{
			step = new OnTimeProcessor( stepConfiguration, doneCallback, lapCallback );
		}
		else if ( stepConfiguration[ "type" ] == SET_ON_DISTANCE )
		{
			step = new OnDistanceProcessor( stepConfiguration, doneCallback, lapCallback );
		}
		else if ( stepConfiguration[ "type" ] == REPEATER )
		{
			step = new RepeatProcessor( stepConfiguration, doneCallback, lapCallback );
		}
	
		return step;	
	}
		
	function getDoneCallback()
	{
		return method( :onDone );
	}
		
	function getLapCallback()
	{
		return method( :saveLap );
	}
	
	function getCurrentInterval()
	{
		return currentStepProcessor.getCurrentInterval();
	}
	
	function getNextInterval()
	{
		if ( currentStepProcessor.getNextInterval() != null )
		{
			return currentStepProcessor.getNextInterval();
		}
		else if ( nextStepProcessor != null )
		{
			return nextStepProcessor.getCurrentInterval();
		}
		else
		{
			return null;
		}
	}
}