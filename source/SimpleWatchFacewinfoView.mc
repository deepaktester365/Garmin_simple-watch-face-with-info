import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class SimpleWatchFacewinfoView extends WatchUi.WatchFace {
    var width = null;
    var height = null;

    var timeRegFont = WatchUi.loadResource(Rez.Fonts.kdamRegFont);    
    var timeBoldFont = WatchUi.loadResource(Rez.Fonts.kdamBoldFont);    
    var dateFont = Graphics.FONT_TINY;
    var iconFont = WatchUi.loadResource(Rez.Fonts.iconFont);

    var debug = false;
    var fields = [
        "Date",
        "Battery", 
        "Steps",
        "Notifications"
    ];

    var fonts = {
        "icon" => iconFont,
        "date" => dateFont,
        "time_reg" => timeRegFont,
        "time_bold" => timeBoldFont
    };

    var backgroundColor = null;
    var foregroundColor = null;
    var minsColor = null;
    var hoursColor = null;
    var stepsColor1 = null;
    var stepsColor2 = null;

    var dateDisplay = null;
    var bleDisplay = null;
    var batteryDisplay = null;
    var stepsDisplay = null;
    var notificationsDisplay = null;
    var stepsCircle = null;
    var miltFormat = null;


    function initialize() {
        WatchUi.WatchFace.initialize();
    }

    function onLayout(dc){
        // constants = new constants();
        width = dc.getWidth();
        height = dc.getHeight();

        onUpdate(dc);
    }

    function onUpdate(dc){        
        backgroundColor = Application.getApp().getProperty("BackgroundColor");
        foregroundColor = Application.getApp().getProperty("ForegroundColor");
        hoursColor = Application.getApp().getProperty("HoursColor");
        minsColor = Application.getApp().getProperty("MinsColor");
        stepsColor1 = Application.getApp().getProperty("StepsCircleColor1");
        stepsColor2 = Application.getApp().getProperty("StepsCircleColor2");

        dateDisplay = Application.getApp().getProperty("DateDisplay");
        bleDisplay = Application.getApp().getProperty("BLEDisplay");
        batteryDisplay = Application.getApp().getProperty("BatteryDisplay");
        stepsDisplay = Application.getApp().getProperty("StepsDisplay");
        stepsCircle = Application.getApp().getProperty("StepsCircle");
        notificationsDisplay = Application.getApp().getProperty("NotificationsDisplay");

        miltFormat = Application.getApp().getProperty("UseMilitaryFormat");

        dc.setColor(backgroundColor, backgroundColor);
        dc.clear();
        timeUpdate(dc);
        var field_1 = null;
        var field_2 = null;
        var field_3 = null;
        var field_4 = null;

        if (dateDisplay) {
            field_1 = fields[0];
        } 
        if (batteryDisplay || bleDisplay) {
            field_2 = fields[1];
        } 
        if (stepsDisplay) {
            field_3 = fields[2];
        } 
        if (notificationsDisplay) {
            field_4 = fields[3];
        }
        if (field_1) {
            fieldUpdate(dc, 1, field_1, field_2);
        } else {
            fieldUpdate(dc, 1, field_2, field_1);
        }
        if (field_3) {
            fieldUpdate(dc, 2, field_3, field_4);
        } else {
            fieldUpdate(dc, 2, field_4, field_3);
        }
        if (stepsCircle) {
            drawStepsCircle(dc);
        }
    }


    function getTimeData() {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var mins = clockTime.min.format("%02d");
        var secs = clockTime.sec.format("%02d");
        return [hours, mins, secs];
    }

    function timeUpdate(dc) {
        var time_data = getTimeData();
        var hours = time_data[0];
        var mins = time_data[1];

        var main_data = new [2];

        if (!miltFormat) {
            hours = hours % 12;
            if (hours == 0) {
                hours = 12;}
        }

        main_data[0] = {"text" => hours.toString(), "font" => "time_bold", "color" => hoursColor};
        main_data[1] = {"text" => mins.toString(), "font" => "time_reg", "color" => minsColor};

        drawLineText(dc, width/2, height/2, main_data);
    }

    function getDateData() {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var day_of_week = today.day_of_week;
        var day = today.day;

        return {"text" => day_of_week + " " + day, "font" => "date", "color" => foregroundColor};
    }

    function getBleData() {
        var settings = System.getDeviceSettings();
        if (bleDisplay && settings.phoneConnected) {
            return true;
        } else {
            return false;
        }
    }

    function getBatteryData() {
        var stats = System.getSystemStats();
        var bat_value = (stats.battery/13.5).toNumber();
        return {"text" => bat_value.toString(), "font" => "icon", "color" => foregroundColor};
    }

    function getStepData() {
        var steps_data = (ActivityMonitor.getInfo().steps).toString();
        return {"text" => steps_data, "font" => "date", "color" => foregroundColor};
    }

    function getNotificationData() {
        var mySettings = System.getDeviceSettings();
        var notif_data = mySettings.notificationCount.toNumber();
        return {"text" => notif_data.toString(), "font" => "date", "color" => foregroundColor};
    }

    function drawStepsCircle(dc) {
        var time_data = getTimeData();
        var mins_elapsed = time_data[0].toNumber() * 60.00 + time_data[1].toNumber();
        var mins_counted = mins_elapsed - 8.00*60.00;
        var total_mins_counted = 12.00*60.00;
        var ratio = (mins_counted/total_mins_counted);
        if (ratio < 0) {
            ratio = 0;
        }
        else if (ratio >1) {
            ratio = 1;
        }

        var steps = ActivityMonitor.getInfo().steps*1.00;
        var steps_goal = ActivityMonitor.getInfo().stepGoal*1.00;
        var steps_end = (steps/steps_goal)*360.00;

        var required_num_steps = ratio * steps_goal;
        var required_steps_end = (required_num_steps/steps_goal)*360.00;

        if (steps > required_num_steps) {
            if (steps_end > 360) {
                steps_end = 360;
            }
            dc.setColor(stepsColor2, backgroundColor);
            dc.setPenWidth(width/50);
            dc.drawArc(width/2, height/2, width/2, Graphics.ARC_CLOCKWISE, 90, 90 - steps_end);             
        }
        else {
            if (steps_end > 0) {
                dc.setColor(stepsColor2, backgroundColor);
                dc.setPenWidth(width/50);
                dc.drawArc(width/2, height/2, width/2, Graphics.ARC_CLOCKWISE, 90, 90 - steps_end);             
            }
            if (required_steps_end > steps_end) {
                dc.setColor(stepsColor1, backgroundColor);
                dc.setPenWidth(width/50);
                dc.drawArc(width/2, height/2, width/2, Graphics.ARC_CLOCKWISE, 90 - steps_end, 90 - required_steps_end);             
            }
        }

    }

    function drawLineText(dc, x_loc, y_loc, main_array) {
        var len = main_array.size();
        var total_text_width = 0;
        var temp_font = null;
        var temp_text = null;
        var temp_width = null;
        var temp_color = null;
 
        for (var i = 0; i < len; i += 1) {
            if (main_array[i]) {
                temp_text = main_array[i]["text"];
                temp_font = main_array[i] ["font"];
                temp_width = dc.getTextWidthInPixels(temp_text, fonts[temp_font]);
                main_array[i]["textwidth"] = temp_width; 
                total_text_width += main_array[i]["textwidth"];
            } else {
                main_array.remove(i);
                i -= 1;
                len -= 1; }} 

        var x_val = x_loc - (total_text_width/2);


        for (var i = 0; i < len; i += 1) {

            temp_font = main_array[i]["font"];
            temp_text = main_array[i]["text"];
            temp_width = main_array[i]["textwidth"];
            temp_color = main_array[i]["color"];

            dc.setColor(temp_color, backgroundColor);
            dc.drawText(x_val, y_loc, fonts[temp_font], temp_text, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
            x_val += temp_width;
        } 
    }

    function fieldUpdate(dc, field_num, type_1, type_2) {
        var main_data = new [10];
        var count = 0;

        if (type_1 == fields[0]) {
            main_data[count] = getDateData();
            count += 1;
        } else if (type_1 == fields[1]) {
            if (getBleData()) {
                main_data[count] = {"text" => "b", "font" => "icon", "color" => foregroundColor};
                count += 1;
            }
            if (batteryDisplay){
                main_data[count] = getBatteryData();
                count += 1;
            }
        } else if (type_1 == fields[2]) {
            var temp_array = getStepData();
            if (temp_array["text"].toNumber() > 0) {
                main_data[count] = {"text" => "s", "font" => "icon", "color" => foregroundColor};
                count += 1;
                main_data[count] = {"text" => " ", "font" => "date", "color" => foregroundColor};
                count += 1;
                main_data[count] = temp_array;
                count += 1;
            }
        } else if (type_1 == fields[3]) {
            var temp_array = getNotificationData();
            if (temp_array["text"].toNumber() > 0) {
                main_data[count] = {"text" => "n", "font" => "icon", "color" => foregroundColor};
                count += 1;
                main_data[count] = {"text" => " ", "font" => "date", "color" => foregroundColor};
                count += 1;
                main_data[count] = temp_array;
                count += 1;
            }
        } 


        if (type_2 == fields[0]) {
            main_data[count] = {"text" => " ", "font" => "date", "color" => foregroundColor};
            count += 1;

            main_data[count] = getDateData();
            count += 1;
        } else if (type_2 == fields[1]) {
            main_data[count] = {"text" => " ", "font" => "date", "color" => foregroundColor};
            count += 1;

            if (getBleData()) {
                main_data[count] = {"text" => "b", "font" => "icon", "color" => foregroundColor};
                count += 1;
                main_data[count] = {"text" => " ", "font" => "date", "color" => foregroundColor};
                count += 1;
            }
            if (batteryDisplay){
                main_data[count] = getBatteryData();
                count += 1;
            }
        } else if (type_2 == fields[2]) {
            main_data[count] = {"text" => " ", "font" => "date", "color" => foregroundColor};
            count += 1;

            var temp_array = getStepData();
            if (temp_array["text"].toNumber() > 0) {
                main_data[count] = {"text" => "s", "font" => "icon", "color" => foregroundColor};
                count += 1;
                main_data[count] = {"text" => " ", "font" => "date", "color" => foregroundColor};
                count += 1;
                main_data[count] = temp_array;
                count += 1;
            }
        } else if (type_2 == fields[3]) {
            main_data[count] = {"text" => " ", "font" => "date", "color" => foregroundColor};
            count += 1;

            var temp_array = getNotificationData();
            if (temp_array["text"].toNumber() > 0) {
                main_data[count] = {"text" => "n", "font" => "icon", "color" => foregroundColor};
                count += 1;
                main_data[count] = {"text" => " ", "font" => "date", "color" => foregroundColor};
                count += 1;
                main_data[count] = temp_array;
                count += 1;
            }
        } 

        var y_loc = height/2 + Math.pow(-1, field_num) * height/4; 
        drawLineText(dc, width/2, y_loc, main_data);
    }

    function onShow(){
    }
    function onHide(){
    }
    function onExitSleep(){
    }
    function onEnterSleep(){
    }

}
