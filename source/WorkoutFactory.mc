
class WorkoutFactory
{
	static function generateWorkout ( workoutId )
	{
		if ( workoutId == 0 )
		{
			return simpleRepeatWorkout();
		}
		else if ( workoutId == 1 )
		{
			return OneTwoTwoOneWorkout();
		}
		else if ( workoutId == 2 )
		{
			return TwoPlusOneRepeatWorkout();
		}
		else
		{
			return null;
		}
	}
	
	static function simpleRepeatWorkout ()
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
	
	static function OneTwoTwoOneWorkout ()
	{
		var workout = new Workout( "1-2-2-1 Workout", 6);
		
		workout.workoutSteps[0] = new LapIntervalModel( "Warm Up", "Easy", workout.getDoneCallback() );
		
		var workStep1 = new DistanceIntervalModel( 1000, "Interval", "Work", workout.getDoneCallback(), null );
		workout.workoutSteps[1] = new OnDistanceIntervalModel( 1500, workStep1, "1 Km Hard", "Easy", workout.getDoneCallback(), null );
		
		var workStep2 = new DistanceIntervalModel( 2000, "Interval", "Work", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
		workout.workoutSteps[2] = new OnDistanceIntervalModel( 3000, workStep2, "2 Km Hard", "Easy", workout.getDoneCallback(), new RepeatAttribute( 1, 2 ) );
		
		var workStep3 = new DistanceIntervalModel( 2000, "Interval", "Work", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );
		workout.workoutSteps[3] = new OnDistanceIntervalModel( 1000, workStep3, "2 Km Hard", "Easy", workout.getDoneCallback(), new RepeatAttribute( 2, 2 ) );
		
		var workStep4 = new DistanceIntervalModel( 1000, "Interval", "Work", workout.getDoneCallback(), null );
		workout.workoutSteps[4] = new OnDistanceIntervalModel( 1500, workStep4, "1 Km Hard", "Easy", workout.getDoneCallback(), null );
	
		workout.workoutSteps[5] = new LapIntervalModel( "Cool Down", "Easy", workout.getDoneCallback() );
		
		return workout;
	}
	
	static function TwoPlusOneRepeatWorkout ()
	{
		var workout = new Workout( "2 + 1 Repeats", 14);
		
		workout.workoutSteps[0] = new LapIntervalModel( "Warm Up", "Easy", workout.getDoneCallback() );
		
		workout.workoutSteps[1] = new DistanceIntervalModel( 1000, "Interval", "Hard", workout.getDoneCallback(), new RepeatAttribute( 1, 4 ) );
		workout.workoutSteps[2] = new DistanceIntervalModel( 500, "Interval", "Harder", workout.getDoneCallback(), new RepeatAttribute( 1, 4 ) );
		workout.workoutSteps[3] = new DistanceIntervalModel( 1000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 1, 4 ) );
		
		workout.workoutSteps[4] = new DistanceIntervalModel( 1000, "Interval", "Hard", workout.getDoneCallback(), new RepeatAttribute( 2, 4 ) );
		workout.workoutSteps[5] = new DistanceIntervalModel( 500, "Interval", "Harder", workout.getDoneCallback(), new RepeatAttribute( 2, 4 ) );
		workout.workoutSteps[6] = new DistanceIntervalModel( 1000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 2, 4 ) );
		
		workout.workoutSteps[7] = new DistanceIntervalModel( 1000, "Interval", "Hard", workout.getDoneCallback(), new RepeatAttribute( 3, 4 ) );
		workout.workoutSteps[8] = new DistanceIntervalModel( 500, "Interval", "Harder", workout.getDoneCallback(), new RepeatAttribute( 3, 4 ) );
		workout.workoutSteps[9] = new DistanceIntervalModel( 1000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 3, 4 ) );
		
		workout.workoutSteps[10] = new DistanceIntervalModel( 1000, "Interval", "Hard", workout.getDoneCallback(), new RepeatAttribute( 4, 4 ) );
		workout.workoutSteps[11] = new DistanceIntervalModel( 500, "Interval", "Harder", workout.getDoneCallback(), new RepeatAttribute( 4, 4 ) );
		workout.workoutSteps[12] = new DistanceIntervalModel( 1000, "Recovery", "Easy", workout.getDoneCallback(), new RepeatAttribute( 4, 4 ) );
	
		workout.workoutSteps[13] = new LapIntervalModel( "Cool Down", "Easy", workout.getDoneCallback() );
		
		return workout;
	}
	
	static function onTimeOnDistanceRepeatWorkout ()
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
	
	static function outAndBackWorkout ()
	{
		var workout = new Workout( "Out and Back Workout", 2);
		
		workout.workoutSteps[0] = new DistanceIntervalModel( 2000, "Out", "Steady", workout.getDoneCallback(), null );
	
		workout.workoutSteps[1] = new LapIntervalModel( "Back", "Steady", workout.getDoneCallback() );
		
		return workout;
	}
}