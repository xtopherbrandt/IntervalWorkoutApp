using Toybox.WatchUi as Ui;
using Toybox.System as Sys;


class IntervalTimerDelegate extends Ui.BehaviorDelegate
{
	hidden var _page;
	hidden var _workout;
	hidden var _view;

    function initialize( page, view, workout )
    {
    	// initialize the page to -1 --> workout list page
        _page = page;
        _workout = workout;
        _view = view;
        
    }

	// Cycle through the pages after -1
    function onNextPage()
    {
        _page = (_page + 1) % 2;
        System.println( "Page: " + _page );
                
        switchToView( Ui.SLIDE_UP);
    }

    function onPreviousPage() 
    {
        _page = _page - 1;
        
        if (_page < 0)
        {
            _page = 2;
        }
        
        _page = _page % 2;
        
        switchToView( Ui.SLIDE_DOWN);
    }
	
    function onMenu()
    {
    	Sys.println( "Menu pushed" );
        return true;
    }
    
    function onBack()
    {   
    	_workout.onLap();
		
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
            	_workout.onStart();
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
   	
        count1 += 1;
        
        Ui.requestUpdate();
    }
	
    function switchToView( transition )
    {
 
        if( -1 == _page )
        {
            _view = new IntervalTimerListView();
        }
        else if( 0 == _page )
        {
            _view = new StepView( _workout );
        }
        else if( 1 == _page )
        {
            _view = new Page2View();
        }
        else
        {
            _view = new IntervalTimerListView();
        }

		Ui.switchToView( _view, getDelegate(), transition );
        
        return _view;
    }

    function getDelegate()
    {
        var delegate = new IntervalTimerDelegate( _page, _view, _workout );
        return delegate;
    }    
}
