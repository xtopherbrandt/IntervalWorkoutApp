using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class WorkoutPickerChooser extends Ui.Picker {

    function initialize() {
        var title = new Ui.Text({:text=>Rez.Strings.pickerChooserTitle, :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color=>Gfx.COLOR_WHITE});
        var factory = new WordFactory([Rez.Strings.pickerChooserColor, Rez.Strings.pickerChooserDate, Rez.Strings.pickerChooserString, Rez.Strings.pickerChooserTime, Rez.Strings.pickerChooserLayout], {:font=>Gfx.FONT_MEDIUM});
        Picker.initialize({:title=>title, :pattern=>[factory]});
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

class WorkoutPickerChooserDelegate extends Ui.PickerDelegate 
{
    function onCancel() 
    {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

    function onAccept(values) 
    {
        //values[0] 
        Ui.pushView(new ColorPicker(), new ColorPickerDelegate(), Ui.SLIDE_IMMEDIATE);
        
    }
}
