//
//  AirTurnManager.h
//  AirTurnInterface
//
//  Created by Nick Brook on 27/02/2014.
//  Copyright (c) 2014 Nick Brook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AirTurnInterface/AirTurnCentral.h>
#import <AirTurnInterface/AirTurnViewManager.h>
#import <AirTurnInterface/ARCHelper.h>

/**
 The overall HID + BTLE manager for AirTurn
 */
@interface AirTurnManager : NSObject

/**
 `YES` if an AirTurn is connected
 */
@property(nonatomic, readonly) BOOL isConnected;

/**
 The BTLE central
 */
@property(ah_weak_delegate, nonatomic, readonly, nullable) AirTurnCentral *central;

/**
 The AirTurn View manager (detects keyboard-based AirTurn events)
 */
@property(ah_weak_delegate, nonatomic, readonly, nullable) AirTurnViewManager *viewManager;

/**
 The shared manager, use this to get the shared `AirTurnManager` object
 
 @return The shared `AirTurnManager` object
 */
+ (nonnull AirTurnManager *)sharedManager;

@end
