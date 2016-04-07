
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
	
	static function simpleRepeatWorkout()
	{
		return 
		{ 
			"name" => "Simple Workout",
			"steps" => 
			[
				{
					"name" => "Warm Up",
					"type" => STEP_LAP
				},
				{
					"name" => "Hard Effort",
					"type" => STEP_TIME,
					"duration" => 60000
				},
				{
					"name" => "Recovery",
					"type" => STEP_DISTANCE,
					"duration" => 1000
				},
				{
					"name" => "On Time",
					"type" => SET_ON_TIME,
					"duration" => 60000,
					"workStep" =>
					{
						"name" => "10 Steps",
						"type" => STEP_LAP
					}
				},
				{
					"name" => "Cool Down",
					"type" => STEP_LAP
				}
			] 
		};
	}	
	
	static function OneTwoTwoOneWorkout()
	{
		return 
		{ 
			"name" => "1-2-2-1 Workout",
			"steps" => 
			[
				{
					"name" => "Warm Up",
					"type" => STEP_LAP
				},
				{
					"name" => "On Distance",
					"type" => SET_ON_DISTANCE,
					"duration" => 1500,
					"workStep" =>
					{
						"name" => "10K Pace",
						"type" => STEP_DISTANCE,
						"duration" => 1000
					}
				},
				{
					"name" => "On Distance",
					"type" => SET_ON_DISTANCE,
					"duration" => 3000,
					"workStep" =>
					{
						"name" => "15K Pace",
						"type" => STEP_DISTANCE,
						"duration" => 2000
					}
				},
				{
					"name" => "On Distance",
					"type" => SET_ON_DISTANCE,
					"duration" => 3000,
					"workStep" =>
					{
						"name" => "15K Pace",
						"type" => STEP_DISTANCE,
						"duration" => 2000
					}
				},
				{
					"name" => "On Distance",
					"type" => SET_ON_DISTANCE,
					"duration" => 1500,
					"workStep" =>
					{
						"name" => "10K Pace",
						"type" => STEP_DISTANCE,
						"duration" => 1000
					}
				},
				{
					"name" => "Cool Down",
					"type" => STEP_LAP
				}
			] 
		};
	}		
	
	
	static function TwoPlusOneRepeatWorkout()
	{
		return 
		{ 
			"name" => "2 + 1 Repeats",
			"steps" => 
			[
				{
					"name" => "Warm Up",
					"type" => STEP_LAP
				},
				{
					"name" => "Interval Set",
					"type" => REPEATER,
					"repeatCount" => 4,
					"steps" =>
					[
						{
							"name" => "10K Pace",
							"type" => STEP_DISTANCE,
							"duration" => 1000
						},
						{
							"name" => "5K Pace",
							"type" => STEP_DISTANCE,
							"duration" => 500
						},
						{
							"name" => "Recovery",
							"type" => STEP_DISTANCE,
							"duration" => 1000
						}
					]
				},
				{
					"name" => "Cool Down",
					"type" => STEP_LAP
				}
			] 
		};
	}		

}