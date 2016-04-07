using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Position as Position;
using Toybox.Sensor as Sensor;

var count1 = 0;
var timersRunning = false;
var mainDelegate;
var initialView;
var updateTimer;
var alert;

class IntervalTimerApp extends App.AppBase 
{

	
    // onStart() is called on application start up
    function onStart() 
    {
    	
		initialView = new IntervalTimerListView();
		updateTimer = new Timer.Timer();		
		Position.enableLocationEvents( Position.LOCATION_ONE_SHOT, method(:onPosition) );
		Sensor.enableSensorEvents( null );
		Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
		
		alert = new Alert();
		
		mainDelegate = new IntervalTimerDelegate( -1, initialView );    	
    
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
