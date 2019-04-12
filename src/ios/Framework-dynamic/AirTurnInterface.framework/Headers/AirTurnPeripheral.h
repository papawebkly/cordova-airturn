//
//  AirTurnPeripheral.h
//  AirTurnInterface
//
//  Created by Nick Brook on 27/02/2014.
//  Copyright (c) 2014 Nick Brook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AirTurnInterface/AirTurnTypes.h>
#import <AirTurnInterface/AirTurnError.h>
#import <AirTurnInterface/ARCHelper.h>
#import <AirTurnInterface/EDSemver.h>

/**
 Represents one AirTurn peripheral
 */
@interface AirTurnPeripheral : NSObject

/// ---------------------------------
/// @name Peripheral state
/// ---------------------------------

/**
 The current state of the peripheral
 */
@property(nonatomic, readonly) AirTurnConnectionState  state;

/**
 The type of connected device
 */
@property(nonatomic, readonly) AirTurnDeviceType deviceType;

/**
 The type of inputs this device has
 */
@property(nonatomic, readonly) AirTurnInputType inputType;

/**
 The order the ports are arranged physically on the device
 */
@property(nonatomic, readonly, nonnull) NSArray<NSNumber *> *physicalDigitalPortOrder;

/**
 The user-readable model name of the device
 */
@property(nonatomic, readonly, nonnull) NSString * model;

/**
 YES if the last connection attempt to the device failed
 */
@property(nonatomic, readonly) BOOL lastConnectionFailed;

/**
 Indicates if the peripheral has bonding, probably to another device. Can't connect to it if it does (unless the system connects automatically for us).
 */
@property(nonatomic, assign) BOOL hasBonding;

/**
 `YES` if pairing failed
 */
@property(nonatomic, readonly) BOOL pairingFailed;

/// ---------------------------------
/// @name Peripheral values
/// ---------------------------------

/**
 A unique identifier for this device
 */
@property(nonatomic, readonly, nonnull) NSString *identifier;

/**
 The name of the peripheral
 */
@property(nonatomic, readonly, nullable) NSString * name;

/**
 The default name of the peripheral
 */
@property(nonatomic, readonly, nullable) NSString * defaultName;

/**
 The firmware version of the peripheral
 */
@property(nonatomic, readonly, nullable) EDSemver * firmwareVersion;

/**
 The previous firmware version of the peripheral when it was last connected
 */
@property(nonatomic, readonly, nullable) EDSemver * previousFirmwareVersion;

/**
 The hardware version of the peripheral
 */
@property(nonatomic, readonly, nullable) EDSemver * hardwareVersion;

/**
 A bit field describing the features available on this peripheral
 */
@property(nonatomic, readonly) AirTurnPeripheralFeaturesAvailable featuresAvailable;

/**
 The current mode of this AirTurn
 */
@property(nonatomic, readonly) AirTurnMode currentMode;

/**
 The number of modes on this AirTurn
 */
@property(nonatomic, readonly) uint8_t numberOfModes;

/**
 The number of digital ports available on this AirTurn
 */
@property(nonatomic, readonly) uint8_t numberOfDigitalPortsAvailable;

/**
 The number of analog ports available on this AirTurn
 */
@property(nonatomic, readonly) uint8_t numberOfAnalogPortsAvailable;

/**
 The peripheral battery level, a percentage 0-100%
 */
@property(nonatomic, readonly) uint8_t batteryLevel;

/**
 The peripheral charging state
 */
@property(nonatomic, readonly) AirTurnPeripheralChargingState chargingState;

/**
 Defines the delay before key repeat, a programmable property on the device.  The delay before repeat is calculated, in seconds, as `delay = AirTurnPeripheralMaxDelayBeforeRepeatSeconds * value / 255`.  The maximum delay currently defined as 4s, the minimum is 0.015625 seconds.  If the value of the divisor is zero and `repeatRateDivisor` is zero, there will be no key repeat.
 */
@property(nonatomic, readonly) uint8_t delayBeforeRepeatMultiplier;

/**
 Defines the key repeat rate, a programmable property on the device.  The key repeat rate is calculated, in seconds, as `time between repeat = AirTurnPeripheralMaxRepeatRateSeconds / value`.  The maximum time between repeat is currently defined as 4s, the minimum is 0.015625 seconds.  If the value of the divisor is zero, there will be no key repeat. If it is one, and `delayBeforeRepeatMultiplier` is zero, key repeat will be left to the OS.
 */
@property(nonatomic, readonly) uint8_t repeatRateDivisor;

/**
 Defines if key repeat is enabled. This is a calculated property, true if `delayBeforeRepeatMultiplier` and `repeatRateDivisor` are non-zero
 */
@property(nonatomic, readonly) BOOL keyRepeatEnabled;

/**
 Defines if the key repeat mode is operating system. This is a calculated property, true if `delayBeforeRepeatMultiplier` is 0 and `repeatRateDivisor` is 1
 */
@property(nonatomic, readonly) BOOL OSKeyRepeat;

/**
 Defines the idle power off interval, a programmable property on the device.  The idle power off interval is defined in seconds.  If the value of the interval is zero, there will be no idle power off.
 */
@property(nonatomic, readonly) uint16_t idlePowerOff;

/**
 Defines the connection configuration, a programmable property on the device.  This can be used to adjust the power/performance balance of the connection.
 */
@property(nonatomic, readonly) AirTurnPeripheralConnectionConfiguration connectionConfiguration;

/**
 The peripheral pairing method
 */
@property(nonatomic, readonly) AirTurnPeripheralPairingMethod pairingMethod;

/**
 The peripheral pairing state
 */
@property(nonatomic, readonly) AirTurnPeripheralPairingState pairingState;

/**
 The peripheral debounce time
 */
@property(nonatomic, readonly) AirTurnPeripheralDebounceTime debounceTime;

/**
 The default debounce time in ms
 */
@property(nonatomic, readonly) AirTurnPeripheralDebounceTime defaultDebounceTime;

/**
 The number of pairings the AirTurn has to devices
 */
@property(nonatomic, readonly) uint8_t numberOfPairedDevices;

/**
 Determine if the peripheral has all the given features

 @param features A bitfield of features
 */
- (BOOL)hasFeatures:(AirTurnPeripheralFeaturesAvailable)features;

/**
 The features for a given mode on this Airturn
 
 @param mode The mode
 @return The features available on the specified mode
 */
- (AirTurnModeFeatures)featuresForMode:(AirTurnMode)mode;

/**
 Indicates if a specific digital port is available
 
 @param port The port
 @return YES if the port is available
 */
- (BOOL)digitalPortAvailable:(AirTurnPort)port;

/**
 Indicates if a specific analog port is available
 
 @param port The port
 @return YES if the port is available
 */
- (BOOL)analogPortAvailable:(AirTurnPort)port;

/**
 Get the port state for a given port.
 @param port The port
 @return The port state
 */
- (AirTurnPortState)digitalPortState:(AirTurnPort)port;

/**
 Get the value for the port.
 
 @param port The port
 @return The current analog value. This value is between 0 and UINT8_MAX, and is the analog value scaled between its calibrated min and max.
 */
- (AirTurnPeripheralAnalogValue)analogPortValue:(AirTurnPort)port;

/// ---------------------------------
/// @name Programming
/// ---------------------------------

/**
 Write the delay before repeat divisor to the device.
 @param multiplier The delay before repeat is calculated, in seconds, as `delay = 4 * multiplier / 255`.  The maximum delay is therefore 4 seconds, the minimum is 0.015625 seconds.  If the value of the multiplier is zero, if the repeat rate is 1 the key repeat will be left to the operating system, else there will be no key repeat.
 */
- (void)writeDelayBeforeRepeat:(uint8_t)multiplier;

/**
 Write the key repeat rate divisor to the device
 @param divisor The key repeat rate is calculated, in seconds, as `time between repeat = 4 / divisor`.  The maximum time between repeat is therefore 4 seconds, the minimum is 0.015625 seconds.  If the value of the divisor is zero and the delay before repeat is zero, there will be no key repeat.
 */
- (void)writeRepeatRate:(uint8_t)divisor;

/**
 Write the idle power off interval to the device
 @param idlePowerOff The idle power off duration in seconds.  0 is 'Never'
 */
- (void)writeIdlePowerOff:(uint16_t)idlePowerOff;

/**
 Write the connection configuration to the device
 
 @param connectionConfiguration The connection configuration
 */
- (void)writeConnectionConfiguration:(AirTurnPeripheralConnectionConfiguration)connectionConfiguration;

/**
 Write a pairing method to the device

 @param pairingMethod The pairing method to switch to
 */
- (void)writePairingMethod:(AirTurnPeripheralPairingMethod)pairingMethod;

/**
 Write the debounce time to the device
 
 @param debounceTime The new debounce time
 */
- (void)writeDebounceTime:(AirTurnPeripheralDebounceTime)debounceTime;

/**
 Store the device name locally
 
 @param deviceName The device name. Max length defined in `AirTurnPeripheralMaxNameLength`. Pass a `nil` value or empty string to reset the device name to default.
 */
- (void)storeDeviceName:(nullable NSString *)deviceName;

/// ---------------------------------
/// @name Firmware updates
/// ---------------------------------

/**
 Check for a firmware update for this AirTurn
 
 @param callback Called back on result. YES if an update is available.
 */
- (void)checkForFirmwareUpdate:(void (^_Nonnull)(EDSemver * _Nullable newVersion))callback;

@end
