//
//  AirTurnTypes.h
//  AirTurnInterface
//
//  Created by Nick Brook on 04/01/2012.
//  Copyright (c) 2012 Nick Brook. All rights reserved.
//
//  Permission is hereby granted, to any person (the “Licensee”) who has 
//  legitimately purchased a copy of this framework, example code and 
//  associated documentation (the “Software”) from AirTurn Inc, to use the 
//  compiled binary framework and any parts of the example code within their 
//  own software for distribution and sale on the Apple App Store. The 
//  Software must remain unmodified except any portion of the example source 
//  code which may be used and modified without restriction. The Licensee has 
//  no right to distribute any part of the Software further beyond this 
//  Agreement.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//

#ifndef AirTurnInterface_AirTurnTypes_h
#define AirTurnInterface_AirTurnTypes_h

#import <AirTurnInterface/AirTurnDefines.h>
#import <AirTurnInterface/AirTurnKeyCodes.h>

NS_ASSUME_NONNULL_BEGIN

/// ---------------------------------
/// @name Standard userInfo keys
/// ---------------------------------

/*!
 *  The notification `userInfo` key for the peripheral that the notification is concerning. The value is an `AirTurnPeripheral` object. Only present on BTLE device notifications.
 */
AIRTURN_EXTERN NSString * AirTurnPeripheralKey;

/*!
 *  The notification `userInfo` key for the AirTurn identifier. The value is a `NSString` object. Only present on BTLE device notifications.
 */
AIRTURN_EXTERN NSString * AirTurnIDKey;

/*!
 *  The notification `userInfo` key for the device type on connection notification. The value is an `NSNumber` object containing an integer which is one of the `AirTurnDeviceType` enum values.
 */
AIRTURN_EXTERN NSString * AirTurnDeviceTypeKey;

/// ---------------------------------
/// @name Pedal State Notifications
/// ---------------------------------

/*!
 *  A notification indicating which pedal was pressed. A press occurs on pedal down, then at the key repeat rate after intial repeat delay. The `userInfo` dictionary contains all standard keys and the key `AirTurnPortNumberKey` contains the port of the pedal that was pressed and `AirTurnPortStateKey` contains the state of the pedal, which will be `AirTurnPortStateDown`. For HID devices, `AirTurnKeyCodeKey` contains the key code. For PED devices, `AirTurnPedalRepeatCount` contains the number of key repeats.
 */
AIRTURN_EXTERN NSString * AirTurnPedalPressNotification;
/*!
 *  A notification indicating a pedal was pressed down. The `userInfo` dictionary contains all standard keys and the key `AirTurnPortNumberKey` contains the port of the pedal that was pressed and `AirTurnPortStateKey` contains the state of the pedal, which will be `AirTurnPortStateDown`.
 */
AIRTURN_EXTERN NSString * AirTurnPedalDownNotification;
/*!
 *  A notification indicating a pedal was lifted. The `userInfo` dictionary contains all standard keys and the key `AirTurnPortNumberKey` contains the port of the pedal that was lifted and `AirTurnPortStateKey` contains the state of the pedal, which will be `AirTurnPortStateUp`. For PED devices, `AirTurnPedalRepeatCount` contains the number of key repeats that occurred.
 */
AIRTURN_EXTERN NSString * AirTurnPedalUpNotification;

/*!
 *  The notification `userInfo` key for the port number. The value is an `NSNumber` object containing an integer which is one of the `AirTurnPort` enum values.
 */
AIRTURN_EXTERN NSString * AirTurnPortNumberKey;

/*!
 *  The notification `userInfo` key for the port state. The value is an `NSNumber` object containing an integer which is one of the `AirTurnPortState` enum values.
 */
AIRTURN_EXTERN NSString * AirTurnPortStateKey;

/*!
 *  The notification `userInfo` key for the port state from a HID device only. The value is an `NSNumber` object containing an integer which is one of the `AirTurnKeyCode` enum values.
 */
AIRTURN_EXTERN NSString * AirTurnKeyCodeKey;

/*!
 *  The notification `userInfo` key for the repeat count when a pedal is held. Only present for PED devices. The value is an `NSNumber` object containing an integer representing the number of repeats. This will be 0 on the first pedal press event and increment subsequently.
 */
AIRTURN_EXTERN NSString * AirTurnPedalRepeatCount;

/// ---------------------------------
/// @name BTLE Central State Notifications
/// ---------------------------------

/*!
 *  A notification indicating the state of the central has changed. The `userInfo` key `AirTurnCentralStateKey` contains an `NSNumber` object containing an integer which is one of the `AirTurnCentralState` enum values
 */
AIRTURN_EXTERN NSString * AirTurnCentralStateChangedNotification;

/*!
 *  The notification `userInfo` key for the new central state. The value is an `NSNumber` object containing one of the `AirTurnCentralState` enum values
 */
AIRTURN_EXTERN NSString * AirTurnCentralStateKey;


/// ---------------------------------
/// @name BTLE Devices Discovered Notifications
/// ---------------------------------

/*!
 *  A notification indicating the list of BTLE Devices discovered has changed. The `userInfo` dictionary contains all standard keys and the key `AirTurnDiscoveredPeripheralsKey` contains the set of all discovered devices, and `AirTurnPeripheralKey` contains the device just discovered
 */
AIRTURN_EXTERN NSString * AirTurnDiscoveredNotification;

/*!
 *  The notification `userInfo` key for all discovered BTLE devices. The value is an `NSSet` object containing `AirTurnPeripheral` objects. Pass a peripheral object back to `-connectToAirTurn:` on `AirTurnCentral` to connect.
 */
AIRTURN_EXTERN NSString * AirTurnDiscoveredPeripheralsKey;

/*!
 *  A notification indicating the list of BTLE Devices discovered has changed. The `userInfo` dictionary contains all standard keys and the key `AirTurnDiscoveredDevicesKey` contains the set of all discovered devices, and `AirTurnPeripheralKey` contains the device just lost. The device could have been lost if we have not received an advertising packet within a 10 second window, 10 seconds after disconnecting from a device without receiving an advertising packet, or when the state of the Bluetooth radio changes.
 */
AIRTURN_EXTERN NSString * AirTurnLostNotification;

/// ---------------------------------
/// @name Connection Notifications
/// ---------------------------------

/*!
 *  A notification indicating the BTLE central is connecting to an AirTurn. The `userInfo` dictionary contains all standard keys.
 */
AIRTURN_EXTERN NSString * AirTurnConnectingNotification;

/*!
 *  A notification indicating the connection state changed. The `userInfo` dictionary contains all standard keys and the key `AirTurnConnectionStateKey` contains the new connection state
 */
AIRTURN_EXTERN NSString * AirTurnConnectionStateChangedNotification;
/*!
 *  A notification indicating an AirTurn device connected. The `userInfo` dictionary contains all standard keys and the key `AirTurnConnectionStateKey` contains the new connection state
 */
AIRTURN_EXTERN NSString * AirTurnDidConnectNotification;
/*!
 *  A notification indicating an AirTurn device failed to connect. The `userInfo` dictionary contains all standard keys and the key `AirTurnConnectionStateKey` contains the new connection state
 */
AIRTURN_EXTERN NSString * AirTurnDidFailToConnectNotification;
/*!
 *  A notification indicating an AirTurn device disconnected. The `userInfo` dictionary contains all standard keys and the key `AirTurnConnectionStateKey` contains the new connection state
 */
AIRTURN_EXTERN NSString * AirTurnDidDisconnectNotification;

/*!
 *  The notification `userInfo` key for the connected state. The value is an `NSNumber` object containing an integer which is one of the `AirTurnConnectionState` enum values
 */
AIRTURN_EXTERN NSString * AirTurnConnectionStateKey;

/*!
 *  The notification `userInfo` key for the error. The value is an `NSError` object.
 */
AIRTURN_EXTERN NSString * AirTurnErrorKey;

/// ---------------------------------
/// @name Storage notifications
/// ---------------------------------

/*!
 *  A notification indicating an AirTurn device was added. The `userInfo` dictionary contains all standard keys
 */
AIRTURN_EXTERN NSString * AirTurnAddedNotification;

/*!
 *  A notification indicating an AirTurn device was removed. The `userInfo` dictionary contains all standard keys
 */
AIRTURN_EXTERN NSString * AirTurnRemovedNotification;

/*!
 *  A notification indicating an AirTurn device was invalidated, meaning the identifier originally used is no longer valid and your Application should removed any stored data relating to that identifier. This notification can only occur at App start. The `userInfo` key `AirTurnIDKey` contains a unique identifier string for the device.
 */
AIRTURN_EXTERN NSString * AirTurnInvalidatedNotification;

/// ---------------------------------
/// @name Peripheral Notifications
/// ---------------------------------

/*!
 *  A notification indicating an error has occurred while performing an action on the peripheral. The `userInfo` dictionary contains all standard keys and the key `AirTurnErrorKey` contains the `NSError` object. The posting object is the `AirTurnPeripheral`.
 */
AIRTURN_EXTERN NSString * AirTurnEncounteredErrorNotification;

/*!
 *  A notification indicating a value has been written successfully to the peripheral. The `userInfo` dictionary contains all standard keys and the key `AirTurnWriteTypeKey` contains a `NSNumber` object containing an integer which is one of the `AirTurnPeripheralWriteType` values. The posting object is the `AirTurnPeripheral`.
 */
AIRTURN_EXTERN NSString * AirTurnWriteCompleteNotification;

/*!
 *  The notification `userInfo` key for the type of value just written on write complete notification. The value is an `NSNumber` object containing an integer which is one of the `AirTurnPeripheralWriteType` values.
 */
AIRTURN_EXTERN NSString * AirTurnWriteTypeKey;

/*!
 *  A notification indicating the name of the peripheral has changed. The `userInfo` dictionary contains all standard keys. The posting object is the `AirTurnPeripheral`.
 */
AIRTURN_EXTERN NSString * AirTurnDidUpdateNameNotification;

/// ---------------------------------
/// @name Keyboard Notifications
/// ---------------------------------

/*!
 *  A notification indicating automatic keyboard management was enabled or disabled.
 */
AIRTURN_EXTERN NSString * AirTurnAutomaticKeyboardManagementEnabledChangedNotification;

/*!
 *  A notification indicating the virtual keyboard will be displayed.  The posting object is the `AirTurnKeyboardManager` shared object. The `userInfo` dictionary contains the keys `AirTurnVirtualKeyboardFrameBeginUserInfoKey`, `AirTurnVirtualKeyboardFrameEndUserInfoKey`, `AirTurnVirtualKeyboardAnimationCurveUserInfoKey` and `AirTurnVirtualKeyboardAnimationDurationUserInfoKey`.
 */
AIRTURN_EXTERN NSString * AirTurnVirtualKeyboardWillShowNotification;

/*!
 *  A notification indicating the virtual keyboard was displayed.  The posting object is the `AirTurnKeyboardManager` shared object. The `userInfo` dictionary contains the keys `AirTurnVirtualKeyboardFrameBeginUserInfoKey`, `AirTurnVirtualKeyboardFrameEndUserInfoKey`, `AirTurnVirtualKeyboardAnimationCurveUserInfoKey` and `AirTurnVirtualKeyboardAnimationDurationUserInfoKey`.
 */
AIRTURN_EXTERN NSString * AirTurnVirtualKeyboardDidShowNotification;

/*!
 *  A notification indicating the virtual keyboard will be hidden.  The posting object is the `AirTurnKeyboardManager` shared object. The `userInfo` dictionary contains the keys `AirTurnVirtualKeyboardFrameBeginUserInfoKey`, `AirTurnVirtualKeyboardFrameEndUserInfoKey`, `AirTurnVirtualKeyboardAnimationCurveUserInfoKey` and `AirTurnVirtualKeyboardAnimationDurationUserInfoKey`.
 */
AIRTURN_EXTERN NSString * AirTurnVirtualKeyboardWillHideNotification;

/*!
 *  A notification indicating the virtual keyboard was hidden.  The posting object is the `AirTurnKeyboardManager` shared object. The `userInfo` dictionary contains the keys `AirTurnVirtualKeyboardFrameBeginUserInfoKey`, `AirTurnVirtualKeyboardFrameEndUserInfoKey`, `AirTurnVirtualKeyboardAnimationCurveUserInfoKey` and `AirTurnVirtualKeyboardAnimationDurationUserInfoKey`.
 */
AIRTURN_EXTERN NSString * AirTurnVirtualKeyboardDidHideNotification;

/*!
 *  The notification `userInfo` key for the frame of the keyboard at the beginning of an animation at a show/hide notification.  The value is an `NSValue` object containing a `CGRect`.
 */
AIRTURN_EXTERN NSString * AirTurnVirtualKeyboardFrameBeginUserInfoKey;

/*!
 *  The notification `userInfo` key for the frame of the keyboard at the end of an animation at a show/hide notification.  The value is an `NSValue` object containing a `CGRect`.
 */
AIRTURN_EXTERN NSString * AirTurnVirtualKeyboardFrameEndUserInfoKey;

/*!
 *  The notification `userInfo` key for the keyboard animation curve at a show/hide notification.  The value is an `NSNumber` object containing a `UIViewAnimationCurve` constant.
 */
AIRTURN_EXTERN NSString * AirTurnVirtualKeyboardAnimationCurveUserInfoKey;

/*!
 *  The notification `userInfo` key for the keyboard animation duration at a show/hide notification.  The value is an `NSNumber` object containing a `double` that identifies the duration of the animation in seconds.
 */
AIRTURN_EXTERN NSString * AirTurnVirtualKeyboardAnimationDurationUserInfoKey;

/// ---------------------------------
/// @name enums
/// ---------------------------------

typedef struct {
    BOOL AirTurnPort1State;
    BOOL AirTurnPort2State;
    BOOL AirTurnPort3State;
    BOOL AirTurnPort4State;
    BOOL AirTurnPort5State;
} AirTurnPortStates;

/*!
 *  Constants defining the AirTurn port numbers
 */
typedef NS_ENUM(NSInteger, AirTurnPort) {
    /*!
     *  An invalid port number
     */
    AirTurnPortInvalid = 0,
    /*!
     *  AirTurn Port 1, usually 'Up'
     */
    AirTurnPort1 = 1,
    /*!
     *  AirTurn Port 2, usually 'Left'
     */
    AirTurnPort2 = 2,
    /*!
     *  AirTurn Port 3, usually 'Down'
     */
    AirTurnPort3 = 3,
    /*!
     *  AirTurn Port 4, usually 'Right'
     */
    AirTurnPort4 = 4,
    /*!
     *  AirTurn Port 5
     */
    AirTurnPort5 = 5,
    /*!
     *  AirTurn Port 6
     */
    AirTurnPort6 = 6
};

/*!
 *  Constants defining the AirTurn port states
 */
typedef NS_ENUM(NSInteger, AirTurnPortState) {
    /*!
     *  Invalid port state
     */
    AirTurnPortStateInvalid = -1,
    /*!
     *  The port state is up, i.e. the pedal is not pressed
     */
    AirTurnPortStateUp = 0,
    /*!
     *  The port state is down, i.e. the pedal is pressed
     */
    AirTurnPortStateDown = 1
};

/*!
 *  Constants defining the AirTurn device type. If the device is connected via HID the device type cannot be determined and so will be `AirTurnDeviceTypeUnknown`
 */
typedef NS_ENUM(NSInteger, AirTurnDeviceType) {
    /*!
     *  Invalid device type that the framework does not support
     */
    AirTurnDeviceTypeInvalid = -1,
    /*!
     *  Unknown device type
     */
    AirTurnDeviceTypeUnknown = 0,
    /*!
     *  HID device type (probably BT-105)
     */
    AirTurnDeviceTypeHID,
    /*!
     *  AirTurn PED device type
     */
    AirTurnDeviceTypePED
};

/*!
 *  Constants defining the AirTurn connection states
 */
typedef NS_ENUM(NSInteger, AirTurnConnectionState) {
    /*!
     *  Unknown connection state
     */
    AirTurnConnectionStateUnknown = 0,
    /*!
     *  The AirTurn is disconnected
     */
    AirTurnConnectionStateDisconnected,
    /*!
     *  The AirTurn is connecting
     */
    AirTurnConnectionStateConnecting,
    /*!
     *  The AirTurn is connected
     */
    AirTurnConnectionStateConnected
};

/*!
 *  Defines which value has been written
 */
typedef NS_ENUM(NSInteger, AirTurnPeripheralWriteType) {
    /*!
     *  The delay before repeat value has been written
     */
    AirTurnPeripheralWriteTypeDelayBeforeRepeat = 1,
    /*!
     *  The repeat rate has been written
     */
    AirTurnPeripheralWriteTypeRepeatRate,
    /*!
     *  The idle power off has been written
     */
    AirTurnPeripheralWriteTypeIdlePowerOff,
    /*!
     *  The connection configuration has been written
     */
    AirTurnPeripheralWriteTypeConnectionConfiguration
};

/*!
 *  Defines the Connection Configuration options
 */
typedef NS_ENUM(uint8_t, AirTurnPeripheralConnectionConfiguration){
    /*!
     *  The connection will be optimised for power saving. Default.
     */
    AirTurnPeripheralConnectionConfigurationLowPower = 0,
    /*!
     *  The connection will be optimised for responsiveness
     */
    AirTurnPeripheralConnectionConfigurationLowLatency = 1
};

/*!
 *  Defines the features that are available on a peripheral above the base features
 */
typedef NS_OPTIONS(NSUInteger, AirTurnPeripheralFeaturesAvailable){
    /*!
     *  Indicates connection speed configuration is available
     */
    AirTurnPeripheralFeaturesAvailableConnectionSpeedConfiguration = 1 << 0,
    /*!
     *  Indicates OS key repeat configuration is available
     */
    AirTurnPeripheralFeaturesAvailableOSKeyRepeatConfiguration = 1 << 1
};

/*!
 *  Defines the central state
 */
typedef NS_ENUM(NSInteger, AirTurnCentralState) {
    /*!
     *  Unknown central state
     */
    AirTurnCentralStateUnknown = 0,
    /*!
     *  The central manager is resetting, wait for next state change...
     */
    AirTurnCentralStateResetting,
    /*!
     *  Bluetooth low energy is not supported on this device
     */
    AirTurnCentralStateUnsupported,
    /*!
     *  Bluetooth low energy is not authorised for this application
     */
    AirTurnCentralStateUnauthorized,
    /*!
     *  Bluetooth is powered off
     */
    AirTurnCentralStatePoweredOff,
    /*!
     *  AirTurn Central is disabled
     */
    AirTurnCentralStateDisabled,
    /*!
     *  AirTurn Central is not connected to an AirTurn
     */
    AirTurnCentralStateDisconnected,
    /*!
     *  AirTurn Central is connected
     */
    AirTurnCentralStateConnected
};

NS_ASSUME_NONNULL_END

#endif
