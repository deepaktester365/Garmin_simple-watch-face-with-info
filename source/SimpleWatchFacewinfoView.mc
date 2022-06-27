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

    var debug = false;

    var row1item1 = null;
    var row1item2 = null;
    var row1item3 = null;
    var row2item1 = null;
    var row2item2 = null;
    var row2item3 = null;


    var dataFields = [
        null,
        "Date",
        "Bluetooth", 
        "Battery", 
        "Steps",
        "Calories",
        "Notifications"
    ];

    var fonts = {
        "icon" => WatchUi.loadResource(Rez.Fonts.iconFont),
        "date" => Graphics.FONT_TINY,
        // "time_reg" => WatchUi.loadResource(Rez.Fonts.kdamRegFont),
        // "time_bold" => WatchUi.loadResource(Rez.Fonts.kdamBoldFont)
        "time_reg" => Graphics.FONT_NUMBER_HOT,
        "time_bold" => Graphics.FONT_SYSTEM_NUMBER_HOT
    };

    var Colors = {
        "backGround" => Application.getApp().getProperty("BackgroundColor"),
        "foreGround" => Application.getApp().getProperty("ForegroundColor"),
        "minsNumber" => Application.getApp().getProperty("MinsColor"),
        "hoursNumber" => Application.getApp().getProperty("HoursColor"),
        "stepsPrimary" => Application.getApp().getProperty("StepsCircleColor1"),
        "stepsSecondary" => Application.getApp().getProperty("StepsCircleColor2")
    };

    var stepsCircle = Application.getApp().getProperty("StepsCircle");
    var miltFormat = Application.getApp().getProperty("UseMilitaryFormat");


    function initialize() {
        WatchUi.WatchFace.initialize();
    }

    function onLayout(dc){
        // constants = new constants();
        width = dc.getWidth();
        height = dc.getHeight();

        row1item1 = Application.getApp().getProperty("Row1Prop1");
        row1item2 = Application.getApp().getProperty("Row1Prop2");
        row1item3 = Application.getApp().getProperty("Row1Prop3");
        row2item1 = Application.getApp().getProperty("Row2Prop1");
        row2item2 = Application.getApp().getProperty("Row2Prop2");
        row2item3 = Application.getApp().getProperty("Row2Prop3");

        onUpdate(dc);
    }

    function onUpdate(dc){        
        dc.setColor(Colors["backGround"], Colors["backGround"]);
        dc.clear();
        timeUpdate(dc);
        var field_array_1 = [];
        var field_array_2 = [];        

        if (dataFields[row1item1]) {
            field_array_1.add(dataFields[row1item1]);
            System.println(dataFields[row1item1] + row1item1);
        } 
        if (dataFields[row1item2]) {
            field_array_1.add(dataFields[row1item2]);
            System.println(dataFields[row1item2] + row1item2);
        } 
        if (dataFields[row1item3]) {
            field_array_1.add(dataFields[row1item3]);
            System.println(dataFields[row1item3] + row1item3);
        } 
        if (dataFields[row2item1]) {
            field_array_2.add(dataFields[row2item1]);
            System.println(dataFields[row2item1] + row2item1);
        } 
        if (dataFields[row2item2]) {
            field_array_2.add(dataFields[row2item2]);
            System.println(dataFields[row2item2] + row2item2);
        } 
        if (dataFields[row2item3]) {
            field_array_2.add(dataFields[row2item3]);
            System.println(dataFields[row2item3] + row2item3);
        } 

        fieldUpdate(dc, 1, field_array_1);

        fieldUpdate(dc, 2, field_array_2);

        if (stepsCircle) {
            drawStepsCircle(dc);
        }
    }

    function on123PartialUpdate(dc){     
        dc.setClip(width/2, height/2, width/4, height/4);   
        dc.setColor(Colors["backGround"], Colors["backGround"]);
        dc.clear();
        dc.clearClip();  
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

        var main_data = [];

        if (miltFormat==1 || (miltFormat == 2 &&  !System.getDeviceSettings().is24Hour)) {
            hours = hours % 12;
            if (hours == 0) {
                hours = 12;}
        }

        main_data.add({"text" => hours.toString(), "font" => "time_bold", "color" => "hoursNumber"});
        main_data.add({"text" => mins.toString(), "font" => "time_reg", "color" => "minsNumber"});

        drawLineText(dc, width/2, height/2, main_data);
    }

    function getDateData() {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var day_of_week = today.day_of_week;
        var day = today.day;

        return {"text" => day_of_week + " " + day, "font" => "date", "color" => "foreGround"};
    }

    function getBleData() {
        var value = false;
        if (System.getDeviceSettings().phoneConnected) {
            value = true;
        } 
        return value;
    }

    function getBatteryData() {
        var stats = System.getSystemStats();
        var bat_value = (stats.battery/13.5).toNumber();
        return {"text" => bat_value.toString(), "font" => "icon", "color" => "foreGround"};
    }

    function getStepData() {
        var steps_data = (ActivityMonitor.getInfo().steps).toString();
        return {"text" => steps_data, "font" => "date", "color" => "foreGround"};
    }

    function getCaloriesData() {
        var calories_data = (ActivityMonitor.getInfo().calories).toString();
        return {"text" => calories_data, "font" => "date", "color" => "foreGround"};
    }

    function getCaloriesLeftData() {
        var calories_data = ActivityMonitor.getInfo().calories;
        var calories_goal_data = 2000;
        var calories_left_data = (calories_goal_data - calories_data).toString();
        return {"text" => calories_left_data, "font" => "date", "color" => "foreGround"};
    }

    function getNotificationData() {
        var mySettings = System.getDeviceSettings();
        var notif_data = mySettings.notificationCount.toNumber();
        return {"text" => notif_data.toString(), "font" => "date", "color" => "foreGround"};
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
            dc.setColor(Colors["stepsSecondary"], Colors["backGround"]);
            dc.setPenWidth(width/50);
            dc.drawArc(width/2, height/2, width/2, Graphics.ARC_CLOCKWISE, 90, 90 - steps_end);             
        }
        else {
            if (steps_end > 0) {
                dc.setColor(Colors["stepsSecondary"], Colors["backGround"]);
                dc.setPenWidth(width/50);
                dc.drawArc(width/2, height/2, width/2, Graphics.ARC_CLOCKWISE, 90, 90 - steps_end);             
            }
            if (required_steps_end > steps_end) {
                dc.setColor(Colors["stepsPrimary"], Colors["backGround"]);
                dc.setPenWidth(width/50);
                dc.drawArc(width/2, height/2, width/2, Graphics.ARC_CLOCKWISE, 90 - steps_end, 90 - required_steps_end);             
            }
        }

    }

    function drawLineText(dc, x_loc, y_loc, main_array) {
        var len = main_array.size();
        var total_text_width = 0;
        var temp_color = null;
 
        for (var i = 0; i < len; i += 1) {
            main_array[i]["textwidth"] = dc.getTextWidthInPixels(main_array[i]["text"], fonts[main_array[i]["font"]]);
            total_text_width += main_array[i]["textwidth"];
        }

        var x_val = x_loc - (total_text_width/2);

        for (var i = 0; i < len; i += 1) {
            temp_color = Colors[main_array[i]["color"]];
            // dc.setColor(temp_color, Colors["backGround"]);
            var boxText = new WatchUi.Text({
				:text=>main_array[i]["text"],
				:color=>temp_color,
				:font=>fonts[main_array[i]["font"]],
				:locX =>x_val,
				:locY=>y_loc,
				:justification=>Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER
			});
			boxText.draw(dc);

            x_val += main_array[i]["textwidth"];
        } 
    }

    function cleanArray(dirty_array) {
        return dirty_array;
    }

    function fieldUpdate(dc, field_num, field_array) {
        var main_data = [];
        var len = field_array.size();
        for (var i = 0; i < len; i += 1) {
            var field = field_array[i]; 
            var temp_array = null;
            if (field) {
                if (i > 0) {
                    main_data.add({"text" => " ", "font" => "date", "color" => "foreGround"});
                }
                switch (field) {
                    case dataFields[1]:
                        main_data.add(getDateData());
                        break;
                    case dataFields[2]:
                        if (getBleData()) {
                            main_data.add({"text" => "b", "font" => "icon", "color" => "foreGround"});
                        }
                        break;
                    case dataFields[3]:
                        main_data.add(getBatteryData());
                        break;
                    case dataFields[4]:
                        temp_array = getStepData();
                        if (temp_array["text"].toNumber() > 0) {
                            main_data.add({"text" => "s", "font" => "icon", "color" => "foreGround"});
                            main_data.add({"text" => " ", "font" => "date", "color" => "foreGround"});
                            main_data.add(temp_array);
                        }
                        break;
                    case dataFields[5]:
                        temp_array = getCaloriesData();
                        if (temp_array["text"].toNumber() > 0) {
                            main_data.add({"text" => "c", "font" => "icon", "color" => "foreGround"});
                            main_data.add({"text" => " ", "font" => "date", "color" => "foreGround"});
                            main_data.add(temp_array);
                        }
                        break;
                    case dataFields[6]:
                        temp_array = getNotificationData();
                        if (temp_array["text"].toNumber() > 0) {
                            main_data.add({"text" => "n", "font" => "icon", "color" => "foreGround"});
                            main_data.add({"text" => " ", "font" => "date", "color" => "foreGround"});
                            main_data.add(temp_array);
                        }
                        break;
                }
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
