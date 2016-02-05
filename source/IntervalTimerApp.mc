using Toybox.Application as App;
using Toybox.WatchUi as Ui;

var timer1;
var count1 = 0;
var timersRunning = false;
var mainDelegate;
var workoutList;
var initialView;

class IntervalTimerApp extends App.AppBase 
{

	
    // onStart() is called on application start up
    function onStart() 
    {
    	workoutList = testWorkouts();
		initialView = new IntervalTimerListView();
        timer1 = new Timer.Timer();

		mainDelegate = new IntervalTimerDelegate( -1, initialView, workoutList  );    	
    
    }

    // onStop() is called when your application is exiting
    function onStop() 
    {
    }

    // Return the initial view of your application here
    function getInitialView() 
    {
    	
        return [ initialView, mainDelegate ];
    }

}
