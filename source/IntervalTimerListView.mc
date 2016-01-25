using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class IntervalTimerListView extends Ui.View 
{

    function onLayout(dc)
    {
    	setLayout( Rez.Layouts.WorkoutListLayout( dc ) );
    }

	
    function onUpdate(dc)
    {
        var string;
		
		View.onUpdate ( dc );
/*		
        dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_BLACK );
        dc.clear();
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        string = "1K 2K 2K 1K";
        dc.drawText( 40, (dc.getHeight() / 2) - 65, Gfx.FONT_MEDIUM, string, Gfx.TEXT_JUSTIFY_LEFT );
        string = "5 x 1K Desc";
        dc.drawText( 40, (dc.getHeight() / 2) - 15, Gfx.FONT_MEDIUM, string, Gfx.TEXT_JUSTIFY_LEFT );
        string = "4K 1K 1K";
        dc.drawText( 40, (dc.getHeight() / 2) + 40, Gfx.FONT_MEDIUM, string, Gfx.TEXT_JUSTIFY_LEFT );
*/
    }
}

