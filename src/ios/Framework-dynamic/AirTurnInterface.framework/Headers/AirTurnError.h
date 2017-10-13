//
//  AirTurnError.h
//  AirTurnInterface
//
//  Created by Nick Brook on 11/03/2014.
//  Copyright (c) 2014 Nick Brook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AirTurnInterface/AirTurnTypes.h>

/**
 `AirTurnCentral` error domain
 */
extern NSString * const _Nonnull AirTurnCentralErrorDomain;

/**
 `AirTurnCentral` error codes
 */
typedef NS_ENUM(NSInteger, AirTurnCentralError) {
    /**
     Unhandled error
     */
    AirTurnCentralErrorUnhandled,
    /**
     Unexpected error that cannot be resolved.
     */
    AirTurnCentralErrorUnexpectedUnresolvable,
    /**
     Connection timed out
     */
    AirTurnCentralErrorConnectionTimedOut,
    /**
     Not connected to the peripheral
     */
    AirTurnCentralErrorNotConnected,
    /**
     Device is not ready to perform this action (usually when connecting)
     */
    AirTurnCentralErrorNotReady,
    /**
     The peripheral closed the connection or went out of range
     */
    AirTurnCentralErrorPeripheralDisconnected,
    /**
     The device was not paired, or pairing was cancelled
     */
    AirTurnCentralErrorPeripheralNotPaired,
};

/**
 `AirTurnPeripheral` error domain
 */
extern NSString * _Nonnull const AirTurnPeripheralErrorDomain;

/**
 `AirTurnPeripheral` error codes
 */
typedef NS_ENUM(NSInteger, AirTurnPeripheralError) {
    /**
     Unhandled error
     */
    AirTurnPeripheralErrorUnhandled,
    /**
     Unexpected error that cannot be resolved.
     */
    AirTurnPeripheralErrorUnexpectedUnresolvable,
    /**
     Connection timed out
     */
    AirTurnPeripheralErrorConnectionTimedOut,
    /**
     Not connected to the peripheral
     */
    AirTurnPeripheralErrorNotConnected,
    /**
     Device is not ready to perform this action (usually when connecting)
     */
    AirTurnPeripheralErrorNotReady,
    /**
     The peripheral closed the connection or went out of range
     */
    AirTurnPeripheralErrorPeripheralDisconnected,
    /**
     The device was not paired, or pairing was cancelled
     */
    AirTurnPeripheralErrorPeripheralNotPaired,
    /**
     The operation was cancelled
     */
    AirTurnPeripheralErrorOperationCancelled,
    /**
     The write to the attribute went beyond the bounds of the attribute's size
     */
    AirTurnPeripheralErrorAttributeWriteTooLarge,
    /**
     Writing to the attribute failed but can be retried later
     */
    AirTurnPeripheralErrorAttributeWriteFailedTryLater,
    /**
     Required services were missing
     */
    AirTurnPeripheralErrorMissingServices,
    /**
     An ATT error occurred discovering services
     */
    AirTurnPeripheralErrorATTErrorDiscoveringServices,
    /**
     Required characteristics were missing
     */
    AirTurnPeripheralErrorMissingCharacteristics,
    /**
     An ATT error occurred discovering characteristics, see AirTurnPeripheralErrorServiceKey for the CBUUID of the service
     */
    AirTurnPeripheralErrorATTErrorDiscoveringCharacteristics,
    /**
     Data read from the device was invalid. Could suggest the GATT cache is invalid, requiring a Bluetooth toggle.
     */
    AirTurnPeripheralErrorInvalidData,
    /**
     The device is not compatible with this App based on its model number. See AirTurnPeripheralErrorIncompatibleModelNumberKey for the model number
     */
    AirTurnPeripheralErrorIncompatibleModel,
    /**
     Peripheral discovery timed out
     */
    AirTurnPeripheralErrorDiscoveryTimedOut
};

/**
 The UUID string of the service the error occurred on
 */
extern NSString * _Nonnull const AirTurnPeripheralErrorServiceKey;

/**
 The incompatible model number NSString that was discovered for this device
 */
extern NSString * _Nonnull const AirTurnPeripheralErrorIncompatibleModelNumberKey;

