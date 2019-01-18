//
//  AirTurnCentral.h
//  AirTurnInterface
//
//  Created by Nick Brook on 27/02/2014.
//  Copyright (c) 2014 Nick Brook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AirTurnInterface/AirTurnTypes.h>
#import <AirTurnInterface/AirTurnError.h>
#import <AirTurnInterface/AirTurnPeripheral.h>
#import <AirTurnInterface/ARCHelper.h>

/**
 The `AirTurnCentral` class provides an interface for discovering and connecting to Bluetooth Low Energy AirTurn devices
 */
@interface AirTurnCentral : NSObject

/**
 Enable/Disable AirTurn Central, will also stop scanning if set to NO
 */
@property(nonatomic, assign) BOOL enabled;

/**
 Scan for AirTurn devices, will also enable AirTurn Central if set to YES
 */
@property(nonatomic, assign) BOOL scanning;



/**
 The current AirTurn Central state
 */
@property(nonatomic, readonly) AirTurnCentralState state;

/**
 A set of AirTurns stored from previous connection
 */
@property(nonatomic, readonly, nonnull) NSSet<AirTurnPeripheral *> *storedAirTurns;

/**
 A set of the currently discovered AirTurns
 */
@property(nonatomic, readonly, nonnull) NSSet<AirTurnPeripheral *> *discoveredAirTurns;

/**
 A set of the currently connecting AirTurns
 */
@property(nonatomic, readonly, nonnull) NSSet<AirTurnPeripheral *> *connectingAirTurns;

/**
 The currently connected peripherals
 */
@property(nonatomic, readonly, nonnull) NSSet<AirTurnPeripheral *> * connectedAirTurns;

/**
 Controls if the central automatically connects to AirTurns that are currently connected to the system.  Default `NO`
 */
@property(nonatomic, assign) BOOL autoConnectToConnectedAirTurns;

/**
 Determine if the shared central object has been initialized without triggering initialization
 
 @return `YES` if initialized
 */
+ (BOOL)initialized;

/**
 Determines if background operation has been enabled in the Application's plist
 
 @return YES if background operation has been enabled
 */
+ (BOOL)backgroundOperationEnabled;

/**
 Get the shared central object
 
 @return The shared central object
 */
+ (nonnull AirTurnCentral *)sharedCentral;

/**
 Connect to an AirTurn
 
 @param AirTurn The AirTurn to connect to
 */
- (void)connectToAirTurn:(nonnull AirTurnPeripheral *)AirTurn;

/**
 Disconnect from a connected AirTurn, or cancel a connection attempt
 
 @param AirTurn The AirTurn Peripheral to cancel the connection of
 */
- (void)cancelAirTurnConnection:(nonnull AirTurnPeripheral *)AirTurn;

/**
 Forget the AirTurn (do not connect automatically in future)
 
 @param AirTurn The AirTurn to connect to
 */
- (void)forgetAirTurn:(nonnull AirTurnPeripheral *)AirTurn;

/**
 "Discover" a mock peripheral for testing
 */
- (void)discoverMockPeripheralModel:(AirTurnDeviceType)deviceType;

@end
