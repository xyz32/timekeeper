import QtQuick 1.1
import "clock"
import "calendar"
import "luna"
import "wheels"
import "timekeeper"
import org.kde.plasma.core 0.1 as PlasmaCore
import "luna/phases.js"   as Phases
import "luna/lunacalc.js" as LunaCalc


Rectangle {
    FontLoader { id: fixedFont; source: "clock/Engravers_MT.ttf"}
//*
    Component.onCompleted: {
        plasmoid.setBackgroundHints(NoBackground);


        // refresh moon image
        plasmoid.addEventListener("dataUpdated", dataUpdated);
        dataEngine("time").connectSource("Local", luna, 360000, PlasmaCore.AlignToHour);

        dataUpdated()
        // plasmoid.setAspectRatioMode(ConstrainedSquare);
    }
// */

    function dataUpdated(today) {
        if(!today) today = new Date();

        calendar.month = today.getMonth() * 30 - today.getDate();

        luna.phase = LunaCalc.getTodayPhases(today);
        luna.svg_sourse = "luna-gskbyte" + luna.phase + ".svg"
        luna.degree = 185 + 12.41 * luna.phase
        luna.home_degree = calendar.month + 180
    }
    function timeChanged() {
        var date = new Date;
        clock.hours    = clock ? date.getUTCHours()   + Math.floor(clock.shift)  : date.getHours()
        clock.minutes  = clock ? date.getUTCMinutes() + ((clock.shift % 1) * 60) : date.getMinutes()
        clock.seconds  = date.getUTCSeconds();
        clock.day      = Qt.formatDateTime(date, "ddd")

        timekeeper.day   = Qt.formatDateTime(date, "dd")
        timekeeper.month = Qt.formatDateTime(date, "MMM")
        timekeeper.year  = Qt.formatDateTime(date, "yy")

//        if(calendar.lock){
//            calendar.tak  = clock.seconds * 6;
//        }
    }

    Timer {
        interval: 100; running: true; repeat: true;
        onTriggered: timeChanged()
    }


    width: 500; height: 500
    color: "transparent"

    Calendar {
        id:calendar;
        anchors.centerIn: parent

        Wheel{ x: 3;y: 177 } // x: -13;y: 178

        Clock {
            id: clock;
            // x: -9; y: 42;
            x: 29; y: 60
            shift: 4
        }

        Timekeeper{
            id: timekeeper;
            x: 285;y: 186
        }

        Luna  {
            id:luna;
            x: 162;y: 90
        }
    }
}
