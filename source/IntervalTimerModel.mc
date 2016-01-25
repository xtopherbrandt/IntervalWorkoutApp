using Toybox.System as Sys;

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
}

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
}

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
		currentRepeat = 1;
		currentStepId = 0;
		stepCount = numberOfSteps;
		intervalSteps = new [numberOfSteps];
		IntervalStepBaseModel.initialize( stepName, stepPerformanceTarget, stepDoneCallback );
	}
	
	function onStart()
	{
		System.println ("Repeat Interval Started " + name);
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
	
}


class Workout
{
	var name;
	var workoutSteps; 	// an array of IntervalStepBaseModel
	var currentStepId;	// the array identity of the current step
	var totalSteps;
	
	function initialize( topLevelStepCount )
	{
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
		System.println( "...Step Done..." );
		
		if ( currentStepId < totalSteps - 1 )
		{
			currentStepId = currentStepId + 1;
			workoutSteps[currentStepId].onStart();
		}
		else
		{
			System.println( "Workout Complete!" );
		}
	}
	
	function getDoneCallback()
	{
		return method( :onDone );
	}
}

function testWorkout ()
{
	var workout = new Workout(3);
	
	workout.workoutSteps[0] = new LapIntervalModel( "Warm Up", "Easy", workout.getDoneCallback() );
	workout.workoutSteps[1] = new IntervalRepeatModel( 2, 1, "Repeats", "Work", workout.getDoneCallback() );
	
	workout.workoutSteps[1].intervalSteps[0] = new TimeIntervalModel( 5, "5 sec", "Work", workout.workoutSteps[1].getDoneCallback() );

	workout.workoutSteps[2] = new LapIntervalModel( "Cool Down", "Easy", workout.getDoneCallback() );
	
	return workout;
}