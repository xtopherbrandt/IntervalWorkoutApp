using Toybox.WatchUi as Ui;
using Toybox.System as Sys;


class IntervalTimerDelegate extends Ui.BehaviorDelegate
{
	hidden var _page;
	var workout;

    function initialize( page )
    {
    	// initialize the page to -1 --> workout list page
        _page = page;
        workout = testWorkout();
    }

	// Cycle through the pages after -1
    function onNextPage()
    {
        _page = (_page + 1) % 2;
        System.println( "Page: " + _page );
        Ui.switchToView(getView(_page), getDelegate(_page), Ui.SLIDE_UP);
    }

    function onPreviousPage() 
    {
        _page = _page - 1;
        
        if (_page < 0)
        {
            _page = 2;
        }
        
        _page = _page % 2;
        
        Ui.switchToView(getView(_page), getDelegate(_page), Ui.SLIDE_DOWN);
    }
	
    function onMenu()
    {
    	Sys.println( "Menu pushed" );
        return true;
    }
    
    function onBack()
    {    	
    	System.println( workout.getCurrentStepInfo() );
    	workout.onLap();
    	return true;
    }
    
    function onTap( evt )
    {
		
		// if we're on the workout list page
		if ( _page == -1 )
		{
			// Tap the first line
			if ( evt.getCoordinates()[1] < 50 )
			{
				onNextPage();
			}
			else if ( evt.getCoordinates()[1] < 100 ) // Tap the second line
			{
				Sys.println ( "2nd line" );
			}
			else if ( evt.getCoordinates()[1] > 100 ) // Tap the third line
			{
				Sys.println ( "3rd line" );
			}
		}
		else
		{
			onNextPage();
		}
		
 		return true;
    }
    
    function onKey( evt )
    {
		var key = evt.getKey();
		
        if( key == KEY_ENTER || key == KEY_START )
        {
        	if ( timersRunning )
        	{
        		System.println ("Stop");
            	timer1.stop();
            	timersRunning = false;
            }
            else
            {
                startTimer();
            	workout.onStart();
            }
        }    	
 
 		return true;
    }

	function startTimer()
	{
        System.println ("Start");

        timer1.start( method(:callback1), 500, true );
        
        timersRunning = true;

	}
    
    function callback1()
    {
    	var view;
    	
        count1 += 1;
        
		view = getView(_page);
		view.update();
    }

    function getView(_page)
    {
        var view;

        if( -1 == _page )
        {
            view = new IntervalTimerListView();
        }
        else if( 0 == _page )
        {
            view = new StepView();
        }
        else if( 1 == _page )
        {
            view = new Page2View();
        }
        else
        {
            view = new IntervalTimerListView();
        }

        return view;
    }

    function getDelegate(_page)
    {
        var delegate = new IntervalTimerDelegate( _page );
        return delegate;
    }    
}
