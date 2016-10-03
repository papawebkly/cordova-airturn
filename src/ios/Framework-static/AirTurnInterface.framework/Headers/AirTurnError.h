//
//  AirTurnError.h
//  AirTurnInterface
//
//  Created by Nick Brook on 11/03/2014.
//  Copyright (c) 2014 Nick Brook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AirTurnInterface/AirTurnTypes.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  The userInfo key for the previous error object
 */
AIRTURN_EXTERN NSString * AirTurnErrorPreviousErrorKey;

/*!
 *  The error domain for general AirTurn errors
 */
AIRTURN_EXTERN NSString * AirTurnErrorDomain;

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSInteger, AirTurnError) {
    /*!
     *  Unhandled error.  Please contact AirTurn support for further assistance if this error occurs.
     */
    AirTurnErrorUnhandled = 0,
    /*!
     *  Unexpected error that cannot be resolved.  Please contact AirTurn support for further assistance if this error occurs.
     */
    AirTurnErrorUnexpectedUnresolvable,
    /*!
     *  An error occured performing the operation with the AirTurn.  Please contact AirTurn support for further assistance if this error occurs.
     */
    AirTurnErrorUnresolvablePeripheralError,
    /*!
     *  Connection timed out
     */
    AirTurnErrorConnectionTimedOut,
    /*!
     *  Not connected to the peripheral
     */
    AirTurnErrorNotConnected,
    /*!
     *  The device was not paired, or pairing was cancelled
     */
    AirTurnErrorPeripheralNotPaired,
    /*!
     *  The peripheral closed the connection or went out of range
     */
    AirTurnErrorPeripheralDisconnected,
    /*!
     *  The operation was cancelled
     */
    AirTurnErrorOperationCancelled,
    /*!
     *  Writing to the AirTurn failed but can be retried later
     */
    AirTurnErrorAttributeWriteFailedTryLater
};

