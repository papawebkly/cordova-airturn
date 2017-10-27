Cordova AirTurn
=====================

Cordova Plugin For AirTurn Device

Oktober 2017: Upgraded to the Airturn framework 3.1.0 Beta2 

IOS
===

> Providing bridge to **[NotificationCenter](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/index.html#//apple_ref/occ/instm/NSNotificationCenter/addObserverForName%3aobject%3aqueue%3ausingBlock%3a)**


INSTALL
========

```javascript
$ cordova create <PATH> [ID [NAME [CONFIG]]] [options]
$ cd <PATH>
$ cordova platform add ios
$ cordova plugin add https://github.com/mobilestar55555/cordova-airturn.git
```


USAGE:
======

## From Native to Javascript

### Javascript

```javascript
onDeviceReady: function() {

    //app.receivedEvent('deviceready');

    var initAirTurn    = document.getElementById('initAirTurn'),
    addEvent = document.getElementById('addEvent'),
    setting = document.getElementById('setting');
    killApp = document.getElementById('killApp');

    window.airturn.initAirTurn(function( e ) {
        window.airturn.addAirTurnEventListener( "AirTurnConnectionStateNotification", function( e ) {
            var connectionState = "";

            if(e.AirTurnConnectionStateKey == 0)
                connectionState = "Unknown";
            else if(e.AirTurnConnectionStateKey == 1)
                connectionState = "Disconnect";
            else if(e.AirTurnConnectionStateKey == 2)
                connectionState = "Connecting";
            else if(e.AirTurnConnectionStateKey == 3)
            {
                connectionState = "Connected";
                window.airturn.getInfo( function( e ) {
                    console.log(e);
                    connectionState += "<br>PeripheralName:"+e.PeripheralName;
                    connectionState += "<br>DeviceUniqueIdentifier:"+e.DeviceUniqueIdentifier;
                    connectionState += "<br>FirmwareVersion:"+e.FirmwareVersion;
                    connectionState += "<br>HardwareVersion:"+e.HardwareVersion;
                    document.getElementById("airturn").innerHTML = "Connection State: "+connectionState;
                });
            }
            document.getElementById("airturn").innerHTML = "Connection State: "+connectionState;
        });

        window.airturn.addAirTurnEventListener( "AirTurnPedalPressNotification", function( e ) {
            document.getElementById("airturn").innerHTML = "Port Number: "+e.AirTurnPortNumberKey;
        });

        // use this after a text or other field has taken focus and the Presses are no longer triggered
        window.airturn.makeActive()

        window.airturn.isConnected(function( e ) {//AirTurnPedalPressNotification
            var connectionState = "";
            if(e)
                connectionState = 'Connected';
            else
                connectionState = 'Disconnected';

            document.getElementById("airturn").innerHTML = "Connection State: "+connectionState;
        });
    });


    setting.addEventListener('click', function() {
        window.airturn.setting( function( e ) {
        });
    });

    killApp.addEventListener('click', function() {
        window.airturn.killApp( function( e ) {
        });
    });

}
```
