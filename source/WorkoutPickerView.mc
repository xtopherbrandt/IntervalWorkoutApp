using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class WorkoutPickerView extends Ui.View 
{

    //! Load your resources here
    function onLayout(dc) 
    {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This include
    //! loading resources into memory.
    function onShow() 
    {
 
        // find and modify the labels based on what is in the object store
        var workout = findDrawableById("workout_2");
        var workoutNames = WorkoutFactory.WorkoutTemplateNameList();
        
        workout.setText( workoutNames[ "templates" ][0] );
    }

    //! Update the view
    function onUpdate(dc) 
    {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() 
    {
    }

}

class MainViewDelegate extends Ui.BehaviorDelegate 
{
    function onMenu() {
        Ui.pushView(new PickerChooser(), new PickerChooserDelegate(), Ui.SLIDE_IMMEDIATE);
        return true;
    }
}
