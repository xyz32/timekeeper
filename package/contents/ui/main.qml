import QtQuick 2.1
import org.kde.plasma.plasmoid 2.0

import "clock"
import "clock/wheels"
import "terra"
import "calendar"
import "timekeeper"


import "luna/phase.js"        as Moon
import "terra/planets.js"     as Eth

Rectangle {
    id: main
    width: 478; height: 478

    color: "transparent"
    Plasmoid.backgroundHints: "NoBackground"

    property alias lx : luna.x
    property alias ly : luna.y
    property int count: 0


    readonly property string fontName:   plasmoid.configuration.fontName
    readonly property int fontWeekSize:  plasmoid.configuration.fontWeekSize
    readonly property int fontMonthSize: plasmoid.configuration.fontMonthSize

    // TODO marble
    // readonly property double lon:        plasmoid.configuration.lon
    // readonly property double lat:        plasmoid.configuration.lat

    property string mainState:         plasmoid.configuration.mainState
    property string clockState:        plasmoid.configuration.clockState
    property bool calendarLock:      plasmoid.configuration.calendarLock
    property bool whellLock:         plasmoid.configuration.whellLock
    property string stainedglassState: plasmoid.configuration.stainedglassState

    FontLoader {
        id:   fixedFont;
        name: fontName;
        source: "clock/Engravers_MT.ttf";
        onStatusChanged: {
            if (fixedFont.status == FontLoader.Error) console.log("Cannot load font");
            // console.log(fixedFont.name, fixedFont.source)
        }
    }

    Component.onCompleted: {
        defaultDate()
        // TODO marble
        //*
        // plasmoid.setBackgroundHints(NoBackground);
        // calendar.ms = "calendar/Marble.qml"

        // var vlat = plasmoid.readConfig("lat")
        // var vlon = plasmoid.readConfig("lon")
        // if (vlat != 0 && vlon != 0 ){ lat = vlat; lon = vlon }
        // */

        clock.state              = clockState
        whell.lock               = whellLock
        timekeeper.stained_glass = stainedglassState
        calendar.lock            = calendarLock
        main.state               = mainState
    }


    function nowTimeAndMoonPhase(today) {
        if(!today) today = new Date();

        Moon.touch(today)
        var age = Math.round(Moon.AGE)
        if( age == 0 || age == 30 ) luna.phase = 29
                               else luna.phase = age

        if(luna.state != "big_moon" && main.state != "small"){
            luna.earth_degree = Eth.angle(today)
            luna.moon_degree  = 180 + 12.41 * luna.phase
        }

        var dtime = Qt.formatDateTime(today, "ddd,dd,MMM,yy,yyyy")
        var now = dtime.toString().split(",")
        clock.week_day   = now[0]
        timekeeper.day   = now[1]
        timekeeper.month = now[2]
        timekeeper.year  = now[3]
        timekeeper.yyyy  = now[4]
    }
    function defaultDate(today) {
        if(!today) today = new Date();

        var MM = [0, -31, -62, -93, -123, -153, -182.5, -212, -241.5, -270.5, -299.5, -329.2]
        var month = today.getMonth()
        var date  = today.getDate()-1
        calendar.ring_degree = MM[month] - date;

        nowTimeAndMoonPhase(today)
        count = 0
        timekeeper.stained_glass = ""
    }
    function forTimer() {
        var date = new Date;
        
        clock.hours    = date.getHours()
        clock.minutes  = date.getMinutes()
        clock.seconds  = date.getSeconds()
        if(!side.flipped){

            if(calendar.lock){
                timekeeper.ang = (clock.seconds|3) * 6 * -1;
                calendar.count_angle = clock.seconds * 6;
            }
            if(whell.lock){
                whell.ang = clock.seconds * 6;
            }

            if(Qt.formatDateTime(date, "hhmmss") == "000000") defaultDate()

            // TODO marble
            /*
            if(main.state == "marble" && clock.minutes%10  == 0 && clock.seconds%60 == 0 && calendar.ch){
                //console.log(clock.seconds)
                calendar.mar.citylights_off();
                calendar.mar.citylights_on();
            }
            // */

        }else{

        }
    }


    Timer {
        id: time
        interval: 1000; running: true; repeat: true;
        onTriggered: forTimer()
    }


    Flipable {
        id: side
        property bool flipped: false
        //anchors.left: parent.left
        //anchors.leftMargin: 30

        front: Item {
            width: 478; height: 478
            Calendar {
                id:calendar;
                z: 1
                property bool ch: true
            }
            
            Timekeeper{
                id: timekeeper;
                x: 285;y: 186;
                z: 9
                Item{
                    id: def
                    MouseArea {
                        id: color_ma
                        x: 131; y: 25
                        width: 9; height: 11
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if(timekeeper.stained_glass == "purple" ) {
                                timekeeper.color = "purple"; 
                                timekeeper.stained_glass = "green" 
                            } else if (timekeeper.stained_glass == "green") {
                                timekeeper.color = "";
                                timekeeper.stained_glass = ""
                            } else if (timekeeper.stained_glass == "") {
                                timekeeper.color = "green";
                                timekeeper.stained_glass = "purple"
                            }

                            plasmoid.configuration.stainedglassState = timekeeper.stained_glass
                        }
                    }
                    MouseArea {
                        id: flip_ma
                        x: 154; y: 96
                        width: 10; height: 24
                        cursorShape: Qt.PointingHandCursor
                        // onClicked: { side.flipped = !side.flipped }
                    }
                    MouseArea {
                        id: default_ma
                        x: 178; y: 32
                        width: 12; height: 14
                        cursorShape: Qt.PointingHandCursor

                        onClicked: defaultDate()
                    }
                }

                MouseArea {
                    id: solarSystem_ma
                    x: 0; y: 49
                    width: 13; height: 14
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if(main.state != "solarSystem") {
                            main.state = "solarSystem";
                        } else {
                            main.state = ""; calendar.state = ""
                        }

                        plasmoid.configuration.mainState = main.state
                    }
                }
            }
            Clock {
                id: clock;
                x: 29; y: 60; 
                z: 7
                state: "in"


                Wheels {
                    id: whell
                    x: -26;y: 137;

                    MouseArea {
                        id: tiktak_ma
                        x: 41; y: 38
                        width: 14; height: 14
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if(!whell.lock){
                                whell.ang = -10
                                whell.lock = !whell.lock
                            } else if(!calendar.lock){
                                calendar.count_angle = 10
                                calendar.lock = !calendar.lock
                            } else {
                                whell.lock = !whell.lock
                                calendar.lock = !calendar.lock

                                whell.ang = 0
                                timekeeper.ang = 0
                                calendar.count_angle = 0
                            }
                            plasmoid.configuration.calendarLock = calendar.lock
                            plasmoid.configuration.whellLock = whell.lock
                        }
                    }
                }


                MouseArea {
                    id: center_ma
                    x: 80; y: 76
                    width: 14; height: 14
                    cursorShape: Qt.PointingHandCursor

                    onClicked:{
                        if(main.state == "marble") calendar.state = ""
                        if(main.state == "small") {main.state = "big"; luna.state = "home3"} else main.state = "small";
                        plasmoid.configuration.mainState = main.state
                    }
                }
                MouseArea {
                    id: in_out_ma
                    x: 62; y: 86
                    width: 11; height: 12
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        clock.state == "out" ? clock.state = "in" : clock.state = "out";
                        plasmoid.configuration.clockState = clock.state
                    }
                }
                MouseArea {
                    id: hide_ma
                    x: 101; y: 86
                    width: 11; height: 12
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        whell.hide = !whell.hide
                        plasmoid.configuration.whellState = whell.hide
                    }

                }
            }
            Terra {
                id:luna;
                x: 162; y: 90
                z: 2
            }

        }

        states: [
            State {
                name: "calendar"
                PropertyChanges { target: rotation; angle: 0 }
                when: !side.flipped
            }
        ]
        transform: Rotation {
            id: rotation
            origin.x: 239; origin.y: 239
            axis.x: 1; axis.y: 0; axis.z: 0     // set axis.y to 1 to rotate around y-axis
            angle: 0    // the default angle
        }
        transitions: Transition {
            // NumberAnimation { target: rotation; property: "angle";  duration: 400 }
            SpringAnimation { target: rotation; property: "angle";  spring: 4; damping: 0.3; modulus: 360 ;mass :4;}// velocity: 490}
        }
    }

    states: [
        State {
            name: "small"
            PropertyChanges {
                target: calendar
                scale: 0.3
                rotation: 360
                x: -119; y: -88
            }
            PropertyChanges { 
                target: timekeeper
                scale: 0.3
                x: 10; y: 20
                z: 1
            }
            PropertyChanges { target: whell}
            PropertyChanges { target: luna;  state: "home" }
        },
        State {
            name: "marble"
            PropertyChanges { target: def;      visible: false; }
            PropertyChanges { target: timekeeper; state: "out"; }
            PropertyChanges { target: clock;      state: "out"; }
            PropertyChanges { target: luna;       state: "big_earth"; moon_z: -1 }
        },
        State {
            name: "solarSystem"
            PropertyChanges { target: def;      visible: false; }
            PropertyChanges { target: timekeeper; state: "out"; }
            PropertyChanges { target: clock;      state: "out"; }
            PropertyChanges { target: luna;       state: "home"; moon_z: -1 }
        }
    ]
    transitions: [
        Transition {
            from: "*"; to: "big"
            NumberAnimation { properties: "scale"; duration: 2700 } //InOutBack
            NumberAnimation { properties: "x, y "; duration: 700 }
        },
        Transition {
            from: "*"; to: "small"
            NumberAnimation { properties: "scale"; duration: 1000 }
            NumberAnimation { properties: "rotation, x, y "; duration: 2700 }
        }
    ]

}
