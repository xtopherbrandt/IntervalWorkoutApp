using Toybox.System;
using Toybox.Lang;

class WorkoutFactory
{
	static function generateWorkout ( workoutId )
	{
		if ( workoutId == 0 )
		{
			return FourOneOneTemplate(10000);
		}
		else if ( workoutId == 1 )
		{
			return FourThreeTwoOneTemplate( 15000 );
		}
		else if ( workoutId == 2 )
		{
			return OnTimeRepeatWorkout();
		}
		else
		{
			return null;
		}
	}
	
	static function WorkoutTemplateNameList()
	{
		return
		{
			"templates" => 
			[
				{
					:name => "Simple Workout",
					:id => 0
				},
				{
					:name => "1-2-2-1",
					:id => 1
				},
				{
					:name => "Timed Repeats",
					:id => 2
				},
				{
					:name => "4 + 1 Repeats",
					:id => 3
				},
				{
					:name => "4-1-1",
					:id => 4
				},
				{
					:name => "4-3-2-1",
					:id => 3
				},
				{
					:name => "On Time Repeats",
					:id => 6
				}
				
			]
		};
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
	
	static function OnTimeRepeatWorkout()
	{
		return 
		{ 
			"name" => "On Time Repeats",
			"steps" => 
			[
				{
					"name" => "Warm Up",
					"type" => STEP_LAP
				},
				{
					"name" => "Hill Set",
					"type" => REPEATER,
					"repeatCount" => 4,
					"steps" =>
					[
						{
							"name" => "On Time",
							"type" => SET_ON_TIME,
							"duration" => 180000,
							"workStep" =>
							{
								"name" => "20 Steps",
								"type" => STEP_LAP
							}
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
	
	static function TimedRepeatWorkout()
	{
		return 
		{ 
			"name" => "Timed Repeats",
			"steps" => 
			[
				{
					"name" => "Warm Up",
					"type" => STEP_LAP
				},
				{
					"name" => "Interval Set",
					"type" => REPEATER,
					"repeatCount" => 3,
					"steps" =>
					[
						{
							"name" => "First Part",
							"type" => STEP_TIME,
							"duration" => 60000
						},
						{
							"name" => "Second Part",
							"type" => STEP_TIME,
							"duration" => 30000
						},
						{
							"name" => "Recovery",
							"type" => STEP_TIME,
							"duration" => 15000
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
	
	static function TwoPlusOneRepeatWorkout()
	{
		return 
		{ 
			"name" => "4 + 1 Repeats",
			"steps" => 
			[
				{
					"name" => "Warm Up",
					"type" => STEP_LAP
				},
				{
					"name" => "Interval Set",
					"type" => REPEATER,
					"repeatCount" => 3,
					"steps" =>
					[
						{
							"name" => "10K Pace",
							"type" => STEP_DISTANCE,
							"duration" => 2000
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

	static function FourOneOneTemplate ( totalIntervalDistance )
	{
		var intervalDistanceFloat;
		intervalDistanceFloat = totalIntervalDistance.toFloat();
		
		var workout;
		workout = 
		{ 
			"name" => "4-1-1 Workout",
			"steps" => 
			[
				{
					"name" => "Warm Up",
					"type" => STEP_LAP
				},
				{
					"name" => "10k Pace",
					"type" => STEP_DISTANCE,
					"duration" => 4000
				},
				{
					"name" => "Recovery",
					"type" => STEP_DISTANCE,
					"duration" => 1000
				},
				{
					"name" => "5k Pace",
					"type" => STEP_DISTANCE,
					"duration" => 1000
				},
				{
					"name" => "Recovery",
					"type" => STEP_DISTANCE,
					"duration" => 1000
				},
				{
					"name" => "5k Pace",
					"type" => STEP_DISTANCE,
					"duration" => 1000
				},
				{
					"name" => "Cool Down",
					"type" => STEP_LAP
				}
			] 
		};
		
		var templateIntervalDistance = workout["steps"][1]["duration"].toFloat() + workout["steps"][2]["duration"].toFloat() + workout["steps"][3]["duration"].toFloat() + workout["steps"][4]["duration"].toFloat() + workout["steps"][5]["duration"].toFloat();

		workout["steps"][1]["duration"] = workout["steps"][1]["duration"].toFloat() / templateIntervalDistance * totalIntervalDistance;

		workout["steps"][2]["duration"] = workout["steps"][2]["duration"].toFloat() / templateIntervalDistance * totalIntervalDistance;
		workout["steps"][3]["duration"] = workout["steps"][3]["duration"].toFloat() / templateIntervalDistance * totalIntervalDistance;
		workout["steps"][4]["duration"] = workout["steps"][4]["duration"].toFloat() / templateIntervalDistance * totalIntervalDistance;
		workout["steps"][5]["duration"] = workout["steps"][5]["duration"].toFloat() / templateIntervalDistance * totalIntervalDistance;
		
		return workout;
	}

	static function FourThreeTwoOneTemplate ( totalIntervalDistance )
	{
		
		var templateIntervalDistance;
		var intervalDistanceFloat;
		var workout;
		
		intervalDistanceFloat = totalIntervalDistance.toFloat();
		
		workout = 
		{ 
			"name" => "4-3-2-1 Workout",
			"steps" => 
			[
				{
					"name" => "Warm Up",
					"type" => STEP_LAP
				},
				{
					"name" => "21k Pace",
					"type" => STEP_DISTANCE,
					"duration" => 4000
				},
				{
					"name" => "Recovery",
					"type" => STEP_DISTANCE,
					"duration" => 2000
				},
				{
					"name" => "15k Pace",
					"type" => STEP_DISTANCE,
					"duration" => 3000
				},
				{
					"name" => "Recovery",
					"type" => STEP_DISTANCE,
					"duration" => 1500
				},
				{
					"name" => "10k Pace",
					"type" => STEP_DISTANCE,
					"duration" => 2000
				},
				{
					"name" => "Recovery",
					"type" => STEP_DISTANCE,
					"duration" => 1000
				},
				{
					"name" => "5k Pace",
					"type" => STEP_DISTANCE,
					"duration" => 1000
				},
				{
					"name" => "Recovery",
					"type" => STEP_DISTANCE,
					"duration" => 500
				},
				{
					"name" => "Cool Down",
					"type" => STEP_LAP
				}
			] 
		};

		templateIntervalDistance = 0;
		
		// add up all of the non-lap interval step durations
		for ( var step = 0; step < workout["steps"].size(); step++ )
		{
			if ( workout["steps"][step]["type"] != STEP_LAP )
			{
				templateIntervalDistance += workout["steps"][step]["duration"].toFloat();
			}
		}
		
		// set each step's distance based on the desired total distance
		for ( var step = 0; step < workout["steps"].size(); step++ )
		{
			if ( workout["steps"][step]["type"] != STEP_LAP )
			{
				workout["steps"][step]["duration"] = workout["steps"][step]["duration"].toFloat() / templateIntervalDistance * totalIntervalDistance;
			}
		}
			
		return workout;
	}
}