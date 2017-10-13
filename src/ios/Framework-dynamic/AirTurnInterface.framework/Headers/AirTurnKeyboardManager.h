//
//  AirTurnKeyboardManager.h
//  AirTurnInterface
//
//  Created by Nick Brook on 10/04/2012.
//  Copyright (c) 2012 Nick Brook. All rights reserved.
//
//  Note: This class is only intended for use with the HID part of the framework.  If you are not supporting HID AirTurns, do not use this class.
//

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnTypes.h>

/**
 Posted after the Keyboard Manager is initialised on App launch
 */
AIRTURN_EXTERN NSString * _Nonnull AirTurnKeyboardManagerReadyNotification;

/**
 The keyboard manager class provides manual control over keyboard show/hide using only the public iOS SDK
 */
@interface AirTurnKeyboardManager : NSObject

/**
 The frame of the keyboard in the `UIWindow`
 */
@property(nonatomic, readonly) CGRect keyboardFrame;

/**
 The frame containing the keyboard and dismiss bar
 */
@property(nonatomic, readonly) CGRect keyboardFrameIncludingBar;

/**
 Determines if virtual keyboard is managed automatically. Default is `YES` if `automaticKeyboardManagementAvailable` is YES. If `automaticKeyboardManagementAvailable` is `NO`, this property cannot be set to `YES`.
 */
@property(nonatomic, assign) BOOL automaticKeyboardManagementEnabled;

/**
 If `NO`, automatic keyboard management is unavailable in this application. `NO` by default. To activate automatic keyboard management, add the AirTurnAutomaticKeyboardManagement key in your App's info.plist and set to boolean `YES`
 
 @return Determines if automatic keyboard management is available.
 */
+ (BOOL)automaticKeyboardManagementAvailable;

/**
 Get the shared keyboard manager object. `nil` before `UIApplicationDidFinishLaunchingNotification`.
 
 @return The shared keyboard manager object
 */
+ (nullable AirTurnKeyboardManager *)sharedManager;

/**
 Show or hide the virtual keyboard
 
 @param visible `YES` to show
 @param animate `YES` to animate the keyboard on/off screen
 */
- (void)setKeyboardVisible:(BOOL)visible animate:(BOOL)animate;

/**
 Determines if the keyboard is currently visible on the screen
 
 @return `YES` if the keyboard is visible
 */
- (BOOL)isKeyboardVisible;

@end
