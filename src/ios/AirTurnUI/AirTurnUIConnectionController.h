//
//  AirTurnUIController.h
//  AirTurnExample
//
//  Created by Nick Brook on 01/03/2014.
//
//

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnInterface.h>
#import "AirTurnUIPeripheralController.h"

#ifndef IBInspectable
#define IBInspectable
#endif

@protocol AirTurnUIDelegate;

/**
 Controls the AirTurn user interface table view
 
 By default the AirTurnUIConnectionController class will automatically restore the AirTurn Interface to it's previous state when the App was last used, i.e. enabled/disabled and BTLE/HID mode.
 
 If you would rather the UI/framework starts in the default disabled state, add the key `AirTurnUIRestoreState` to your info.plist and set it to boolean NO. This is discouraged, as it means your users will have to re-enable AirTurn support every time the App is launched.
 */
@interface AirTurnUIConnectionController : UITableViewController

#pragma mark Essential
/**
 Support for Keyboard AirTurns (BT-105, BT-106, DIGIT, DIGIT II, QUAD, STOMP6)
 */
@property(nonatomic, readonly) IBInspectable BOOL supportKeyboard;

/**
 Support for AirDirect AirTurns (PED, PEDpro, DIGIT III)
 */
@property(nonatomic, readonly) IBInspectable BOOL supportAirDirect;

/**
 Defines the maximum number of AirTurns that can be connected simultaneously. Default is 1. Set to 0 for unlimited. An alert is displayed if already connected to max number and user attempts to connect to another.
 */
@property(nonatomic, assign) IBInspectable NSUInteger maxNumberOfAirDirectAirTurns;

/**
 Check for firmware updates when an AirTurn connects. Offers to take the user to the AirTurn App if an update is available. Default NO.
 */
@property(nonatomic, readonly) IBInspectable BOOL checkForFirmwareUpdates;

/**
 Init method, use this instead of -init
 
 @param hid  Enable support for Keyboard AirTurns (BT-105, BT-106, DIGIT, DIGIT II, QUAD, STOMP6)
 @param btle Enable support for AirDirect AirTurns (PED, PEDpro, DIGIT III)
 
 @return UI controller object
 */
- (nonnull instancetype)initSupportingKeyboardAirTurn:(BOOL)keyboard AirDirectAirTurn:(BOOL)AirDirect;

#pragma mark Basic
/**
 AirTurn UI delegate
 */
@property(nonatomic, weak, nullable) IBOutlet id <AirTurnUIDelegate> delegate;

/**
 The currently displayed peripheral controller, nil if none is displayed
 */
@property(nonatomic, readonly, nullable) AirTurnUIPeripheralController * displayedPeripheralController;

/**
 Present the peripheral detail view in the navigation controller
 
 @param peripheral The AirTurn peripheral to present
 @param animated whether to animate the controller or not
 */
- (void)presentAirTurnPeripheralControllerForPeripheral:(nonnull AirTurnPeripheral *)peripheral animated:(BOOL)animated;

#pragma mark Advanced
/**
 An array of all displayed peripherals, ordered as in table view
 */
@property(nonatomic, readonly, nonnull) NSArray<AirTurnPeripheral *> *peripherals;
/**
 If `true`, displays the 'AirTurn support' enabled/disable toggle switch.  If `false` when loaded from nib, the `enabled` property is `true` by default.  Default `true`.
 */
@property(nonatomic, assign) IBInspectable BOOL displayEnableToggle;

/**
 Toggle the AirTurn framework on or off (same action as switch in UI)
 */
@property(nonatomic, assign) BOOL enabled;

/**
 Toggle between AirDirect (`true`) and Keyboard (`false`) modes.
 */
@property(nonatomic, assign) BOOL AirDirectMode;

/**
 Get a description of the Keyboard key code
 
 @param keyCode The key code to retrieve a description for
 
 @return A description of the key
 */
+ (nullable NSString *)keyDescriptionFromKeyCode:(AirTurnKeyCode)keyCode;


/**
 Set the class to be used for peripheral UI.

 @param peripheralClass The class to use for peripheral UI. Must be a subclass of AirTurnUIPeripheralController
 */
+ (void)setUIPeripheralClass:(nonnull Class)peripheralClass;

/**
 Override in subclasses in order to insert other sections in table view

 @param section The real section actually displayed on the screen
 @return The section as numbered in code
 */
- (NSInteger)codeSectionForRealSection:(NSInteger)section;

#pragma mark Deprecated

/**
 Support for HID devices (BT-105)
 */
@property(nonatomic, readonly) BOOL supportHID DEPRECATED_MSG_ATTRIBUTE("Use supportKeyboard instead");

/**
 Support for BTLE devices (PED)
 */
@property(nonatomic, readonly) BOOL supportBTLE DEPRECATED_MSG_ATTRIBUTE("Use supportAirDirect instead");

/**
 Defines the maximum number of AirTurns that can be connected simultaneously. Default is 1. Set to 0 for unlimited. An alert is displayed if already connected to max number and user attempts to connect to another.
 */
@property(nonatomic, assign) NSUInteger maxNumberOfBTLEAirTurns DEPRECATED_MSG_ATTRIBUTE("Use maxNumberOfAirDirectAirTurns instead");

/**
 Init method, use this instead of -init
 
 @param hid  Enable support for HID devices (BT-105)
 @param btle Enable support for BTLE devices (PED)
 
 @return UI controller object
 */
- (nonnull instancetype)initSupportingHIDAirTurn:(BOOL)hid BTLEAirTurn:(BOOL)btle DEPRECATED_MSG_ATTRIBUTE("Use -initSupportingKeyboardAirTurn:AirDirectAirTurn: instead");

/**
 Toggle between BTLE (`true`) and HID (`false`) modes.
 */
@property(nonatomic, assign) BOOL BTLEMode DEPRECATED_MSG_ATTRIBUTE("Use AirDirectMode instead");

@end


/**
 The AirTurnUI delegate
 */
@protocol AirTurnUIDelegate <NSObject>

@optional

/**
 Indicates the controller is about to display a peripheral controller
 
 @param connectionController The connection controller
 @param peripheralController The peripheral controller
 */
- (void)AirTurnUI:(nonnull AirTurnUIConnectionController *)connectionController willDisplayPeripheral:(nonnull AirTurnUIPeripheralController *)peripheralController;

@end
