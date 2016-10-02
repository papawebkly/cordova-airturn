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

/*!
 *  Controls the AirTurn user interface table view
 *
 *  By default the AirTurnUIConnectionController class will automatically restore the AirTurn Interface to it's previous state when the App was last used, i.e. enabled/disabled and BTLE/HID mode.
 * If you would rather the UI/framework starts in the default disabled state, add the key `AirTurnUIRestoreState` to your info.plist and set it to boolean NO. This is discouraged, as it means your users will have to re-enable AirTurn support every time the App is launched.
 */
@interface AirTurnUIConnectionController : UITableViewController

#pragma mark Essential
/*!
 *  Support for HID devices (BT-105)
 */
@property(nonatomic, readonly) IBInspectable BOOL supportHID;

/*!
 *  Support for BTLE devices (PED)
 */
@property(nonatomic, readonly) IBInspectable BOOL supportBTLE;

/*!
 *  Defines the maximum number of AirTurns that can be connected simultaneously. Default is 1. Set to 0 for unlimited. An alert is displayed if already connected to max number and user attempts to connect to another.
 */
@property(nonatomic, assign) IBInspectable NSUInteger maxNumberOfBTLEAirTurns;

/*!
 *  Init method, use this instead of -init
 *
 *  @param hid  Enable support for HID devices (BT-105)
 *  @param btle Enable support for BTLE devices (PED)
 *
 *  @return UI controller object
 */
- (nonnull instancetype)initSupportingHIDAirTurn:(BOOL)hid BTLEAirTurn:(BOOL)btle;

#pragma mark Basic
/*!
 *  AirTurn UI delegate
 */
@property(nonatomic, weak, nullable) IBOutlet id <AirTurnUIDelegate> delegate;

/*!
 *  Indicates if the peripheral view is currently displayed in the navigation controller.
 */
@property(nonatomic, readonly) BOOL isPeripheralViewDisplayed;

/*!
 *  Display the peripheral detail view in the navigation controller
 *
 *  @param animated whether to animate the controller or not
 */
- (void)displayConnectedAirTurnViewForAirTurn:(nonnull AirTurnPeripheral *)AirTurn animated:(BOOL)animated;

#pragma mark Advanced
/*!
 *  If `true`, displays the 'AirTurn support' enabled/disable toggle switch.  If `false` when loaded from nib, the `enabled` property is `true` by default.  Default `true`.
 */
@property(nonatomic, assign) IBInspectable BOOL displayEnableToggle;

/*!
 *  Toggle the AirTurn framework on or off (same action as switch in UI)
 */
@property(nonatomic, assign) BOOL enabled;

/*!
 *  Toggle between BTLE (`true`) and HID (`false`) modes.
 */
@property(nonatomic, assign) BOOL BTLEMode;

/*!
 *  Get a description of the HID key code
 *
 *  @param keyCode The key code to retrieve a description for
 *
 *  @return A description of the key
 */
+ (nullable NSString *)keyDescriptionFromKeyCode:(AirTurnKeyCode)keyCode;

@end

@protocol AirTurnUIDelegate <NSObject>

/*!
 *  The AirTurn UI is requesting that it is displayed.  The return value indicates if it has been or will be displayed.
 *
 *  @param connectionController The AirTurn UI requesting display
 *
 *  @return Return YES is the AirTurn UI will be displayed
 */
- (BOOL)AirTurnUIRequestsDisplay:(nonnull AirTurnUIConnectionController *)connectionController;

@end
