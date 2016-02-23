using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Position as Position;
using Toybox.Sensor as Sensor;


var timer1;
var count1 = 0;
var timersRunning = false;
var mainDelegate;
var workoutList;
var initialView;
var backlightTimer;
var backlightIsOn;

class IntervalTimerApp extends App.AppBase 
{

	
    // onStart() is called on application start up
    function onStart() 
    {
    	workoutList = testWorkouts();
		initialView = new IntervalTimerListView();
        timer1 = new Timer.Timer();
		backlightTimer = new Timer.Timer();
		backlightIsOn = false;
				
		Position.enableLocationEvents( Position.LOCATION_ONE_SHOT, method(:onPosition) );
		Sensor.enableSensorEvents( null );
		Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );

		mainDelegate = new IntervalTimerDelegate( -1, initialView, workoutList  );    	
    
    }

    // onStop() is called when your application is exiting
    function onStop() 
    {
    	Position.enableLocationEvents( Position.LOCATION_DISABLE, method(:onPosition) );
		Sensor.setEnabledSensors( [] );
    }

    function onPosition(info) 
    {
    }

    // Return the initial view of your application here
    function getInitialView() 
    {
    	
        return [ initialView, mainDelegate ];
    }

}
