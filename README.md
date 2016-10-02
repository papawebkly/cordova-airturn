Cordova AirTurn
=====================

Cordova Plugin For AirTurn Device

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

### IOS

```Objective-C
    In Xcode
    1) Add followings in Info.plist
    - 'Required background modes'
        'item 0' String 'App communicates using CoreBluetooth'
    - 'AirTurnAutomaticKeyboardManagement' Boolean YES
    - 'Privacy - Media Library Usage Description' String 'Uses music to demonstrate the PED working in the background to play and pause'
    2) 
    - Drag the appropriate `AirTurnInterface.framework` package into your project (check 'Copy Items' and make sure your App target is checked)
    - Add the CoreBluetooth framework to your link list
    - Select your project in the project navigator
        Select the App target
        Select the "Build Phases" tab
        Expand "Link Binary With Libraries"
        Click the plus icon
        Add `CoreBluetooth.framework`
        Click the plus at the top of "Build Phases" and click "New Copy Files Phase"
        In the new copy files phase at the bottom, change 'Destination' to 'Frameworks', then click the plus and select AirTurnInterface.framework
        Click the plus at the top of "Build Phases" and click "New Run Script Phase"
        Paste:
        <pre><code>script="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/AirTurnInterface.framework/strip-frameworks.sh"
        if [ -f "$script" ]; then
        bash "$script"
        fi</code></pre>

```
