using Toybox.System as Sys;


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
	
	function initialize( stepName, stepPerformanceTarget, stepDoneCallback )
	{
		name = stepName;
		performanceTarget = stepPerformanceTarget;
		doneCallback = stepDoneCallback;
	}
	
	function onStart()
	{
	}
	
	function getNextStepInfo()
	{
		return null;
	}
}

// A simple interval step which ends when the lap (back) button is pushed.
class LapIntervalModel extends IntervalStepBaseModel
{
	
	function initialize( stepName, stepPerformanceTarget, stepDoneCallback )
	{
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback );
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
		return {"name" => name, "until" => "Lap Button", "type" => STEP_LAP };
	}

}

// An interval step which ends once the specified distance is reached within this interval.
// For example, run for 1Km.
class DistanceIntervalModel extends IntervalStepBaseModel
{
	var distance;
	
	function initialize( intervalDistance, stepName, stepPerformanceTarget, stepDoneCallback )
	{
		distance = intervalDistance;
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback );
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
	
	function initialize(  intervalDuration, stepName, stepPerformanceTarget, stepDoneCallback )
	{
		duration = intervalDuration;
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback );
	}
	
	function onStart()
	{
		System.println ("Time Interval Started " + name);
	}

	function onLap()
	{
		// Call the done callback
		doneCallback.invoke();
	}
	
	function getCurrentStepInfo()
	{
		return {"name" => name, "until" => duration, "type" => STEP_TIME };
	}

}

// An interval step type that has a work step added to it (like lap, distance or time) and includes an embedded rest step
// Allows for intervals that repeat on a certain distance: can do stuff like 2 x 500m on 1000m --> every 1Km start a 500 m work interval.
class OnTimeIntervalModel extends IntervalStepBaseModel
{
	var totalTime;		// total length of this duration step including the work step
	var workStep;		//definition of the work step
	
	function initialize( totalIntervalDuration, workIntervalStep, stepName, stepPerformanceTarget, stepDoneCallback )
	{
		totalTime = totalIntervalDuration;
		workStep = workIntervalDistance;
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback );
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
	
	function initialize( workoutName, topLevelStepCount )
	{
		name = workoutName;
		currentStepId = 0;
		totalSteps = topLevelStepCount;
		workoutSteps = new [ topLevelStepCount ];
	}
	
	// the lap button always moves to the next interval step
	function onLap()
	{
		workoutSteps[ currentStepId ].onLap();
	}
	
	function onStart()
	{
		System.println( "Workout Started...");
		workoutSteps[currentStepId].onStart();
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
			currentStepId = currentStepId + 1;
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
	var workout = new Workout( "Test Workout", 3);
	
	workout.workoutSteps[0] = new LapIntervalModel( "Warm Up", "Easy", workout.getDoneCallback() );
	workout.workoutSteps[1] = new IntervalRepeatModel( 2, 2, "Repeats", "Work", workout.getDoneCallback() );
	
	workout.workoutSteps[1].intervalSteps[0] = new TimeIntervalModel( 60, "Hard Effort", "Work", workout.workoutSteps[1].getDoneCallback() );
	workout.workoutSteps[1].intervalSteps[1] = new TimeIntervalModel( 30, "Recovery", "Easy", workout.workoutSteps[1].getDoneCallback() );

	workout.workoutSteps[2] = new LapIntervalModel( "Cool Down", "Easy", workout.getDoneCallback() );
	
	return workout;
}