using Toybox.WatchUi as Ui;
using Toybox.System as Sys;


class IntervalTimerDelegate extends Ui.BehaviorDelegate
{
	hidden var _page;
	hidden var _view;
	hidden var _workout;

    function initialize( page, view )
    {
    	// initialize the page to -1 --> workout list page
        _page = page;
        _view = view;
        startTimer();
        _workout = null;
    }

	// Cycle through the pages after -1
    function onNextPage()
    {
        _page = (_page + 1) % 2;
                
        switchToView( Ui.SLIDE_UP );
    }

    function onPreviousPage() 
    {
        _page = _page - 1;
        
        if (_page < 0)
        {
            _page = 2;
        }
        
        _page = _page % 2;
        
        switchToView( Ui.SLIDE_DOWN );
    }
	
    function onMenu()
    {
    	Sys.println( "Menu pushed" );
        return true;
    }
    
    function onBack()
    {   
    	if ( _page == -1 )
    	{
    		System.exit();
    	}
    	
    	if ( _workout != null && !_workout.onLap() )
    	{
    		_workout.onSave();
    		
    		_workout = null;
    		
    		// go back to the main page
    		_page = -1;
    		switchToView ( Ui.SLIDE_UP );
    	}
    		
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
				_workout = WorkoutFactory.generateWorkout( 0 );
			}
			else if ( evt.getCoordinates()[1] < 100 ) // Tap the second line
			{
				_workout = WorkoutFactory.generateWorkout( 1 );
			}
			else if ( evt.getCoordinates()[1] > 100 ) // Tap the third line
			{
				_workout = WorkoutFactory.generateWorkout( 2 );
			}
			
    		_workout.reset();
			onNextPage();
			
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
        	if ( _workout != null )
        	{
	        	if ( _workout.isRecording() )
	        	{
	        		_workout.onStop();
	            }
	            else
	            {
	        		_workout.onStart();
	            }
            }
        }    	
 		
 		return true;
    }

	function startTimer()
	{

        timer1.start( method(:callback1), 500, true );
        
        timersRunning = true;

	}
    
    function callback1()
    {
   	
        count1 += 1;
        
        if ( _workout != null )
        {
       		_workout.timerUpdate();
       	}
        
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
            _view = new Page2View( );
        }
        else
        {
            _view = new IntervalTimerListView();
        }

		Ui.switchToView( _view, mainDelegate, transition );
        
        return _view;
    }
}
