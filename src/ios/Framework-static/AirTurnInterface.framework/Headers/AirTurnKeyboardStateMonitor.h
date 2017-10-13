//
//  AirTurnStateMonitor.h
//  AirTurnInterface
//
//  Created by Nick Brook on 28/09/2014.
//  Copyright (c) 2014 Nick Brook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Indicates the keyboard state monitor is ready
 */
extern NSString *AirTurnKeyboardStateMonitorReadyNotification;
/**
 Indicates the first responder has changed
 */
extern NSString *AirTurnKeyboardStateMonitorFirstResponderChangedNotification;


/**
 External keyboard connection status changed. Notifications do not occur if automatic keyboard management is disabled
 */
extern NSString *AirTurnKeyboardStateMonitorExternalKeyboardStateChangedNotification;

/**
 Virtual keyboard state changed. Notifications do not occur if automatic keyboard management is disabled
 */
extern NSString *AirTurnKeyboardStateMonitorVirtualKeyboardShouldBeShownChangedNotification;
/**
 The userinfo key for the direction the keyboard is going. The value is an NSNumber. 1 indicates the keyboard is coming on screen. -1 indicates the keyboard is going off screen.
 */
extern NSString *AirTurnKeyboardStateMonitorVirtualKeyboardDirectionKey;

NS_ASSUME_NONNULL_END

/**
 Determines the normal state of the virtual keyboard (i.e. the state the virtual keyboard is in as controlled by the OS)
 */
typedef NS_ENUM(NSUInteger, AirTurnVirtualKeyboardNormalState){
    /**
     The virtual keyboard is hidden
     */
    AirTurnVirtualKeyboardNormalStateHidden,
    /**
     The virtual keyboard is animating on screen
     */
    AirTurnVirtualKeyboardNormalStateAnimatingToVisible,
    /**
     The virtual keyboard is visible
     */
    AirTurnVirtualKeyboardNormalStateVisible,
    /**
     The virtual keyboard is animating off screen
     */
    AirTurnVirtualKeyboardNormalStateAnimatingToHidden
};

/**
 Monitors the state of the virtual keyboard and first responders, and from this determines the state of the external keyboard
 */
@interface AirTurnKeyboardStateMonitor : NSObject

/**
 The current first responder
 */
@property(nonatomic, readonly, weak, nullable) UIView *firstResponder;

/**
 Determines the normal virtual keyboard state
 */
@property(nonatomic, readonly) AirTurnVirtualKeyboardNormalState normalVirtualKeyboardState;

/**
 Determines if the virtual keyboard should be shown
 */
@property(nonatomic, readonly) BOOL virtualKeyboardShouldBeShown;

/**
 Determines if an external hardware keyboard (e.g. BT-105) is connected. Not valid if automatic keyboard management is disabled
 */
@property(nonatomic, readonly) BOOL isExternalKeyboardConnected;

/**
 Determines if the singleton has been initialised
 
 @return `YES` if initialised
 */
+ (BOOL)initialized;

/**
 The shared monitor object
 
 @return The shared state monitor
 */
+ (nullable AirTurnKeyboardStateMonitor *)sharedMonitor;

/**
 Reassess the external keyboard state after a period with no first responder
 
 @param completion Completion block
 */
- (void)reassessKeyboardState:(nonnull void (^)(void))completion;

@end
