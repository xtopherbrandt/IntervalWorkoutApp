using Toybox.Application as App;
using Toybox.WatchUi as Ui;

var timer1;
var count1 = 0;
var timersRunning = false;

class IntervalTimerApp extends App.AppBase 
{

    // onStart() is called on application start up
    function onStart() 
    {
    
        timer1 = new Timer.Timer();
    
    }

    // onStop() is called when your application is exiting
    function onStop() 
    {
    }

    // Return the initial view of your application here
    function getInitialView() {
    	
        return [ new IntervalTimerListView(), new IntervalTimerDelegate( -1 ) ];
    }

}
