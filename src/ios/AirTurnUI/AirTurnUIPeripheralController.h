//
//  AirTurnUIPeripheralController.h
//  AirTurnExample
//
//  Created by Nick Brook on 04/03/2014.
//
//

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnPeripheral.h>

typedef NS_ENUM(NSUInteger, AirTurnErrorContext) {
    AirTurnErrorContextNone,
    AirTurnErrorContextConnecting,
    AirTurnErrorContextWritingDelayBeforeRepeat,
    AirTurnErrorContextWritingRepeatRate,
    AirTurnErrorContextWritingIdlePowerOff,
    AirTurnErrorContextWritingConnectionConfiguration,
};

typedef NS_ENUM(NSUInteger, AirTurnErrorHandlingResult) {
    AirTurnErrorHandlingResultNotHandled,
    AirTurnErrorHandlingResultNoError,
    AirTurnErrorHandlingResultAlert,
    AirTurnErrorHandlingResultModelNotSupported,
};

#define AirTurnUILocalizedString(key, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"AirTurnUI"]

@protocol AirTurnUIPeripheralControllerInternalDelegate;

@interface AirTurnUIPeripheralController : UITableViewController

@property(nonatomic, weak, nullable) id<AirTurnUIPeripheralControllerInternalDelegate> internalDelegate;

@property(nonatomic, readonly, nonnull) AirTurnPeripheral *peripheral;

@property(nonatomic, readonly) BOOL isVisible;

@property(nonatomic, readonly, nullable) UIAlertController *displayedAlert;

+ (AirTurnErrorHandlingResult)handleError:(nullable NSError *)error context:(AirTurnErrorContext)context peripheral:(nullable AirTurnPeripheral *)peripheral alertController:(UIAlertController * _Nullable * _Nullable)alertController dismissHandler:(void (^ __nullable)(UIAlertAction * _Nonnull action))dismissHandler;

- (nonnull instancetype)initWithPeripheral:(nonnull AirTurnPeripheral *)peripheral;

/**
 Override in subclasses in order to insert other sections in table view
 
 @param section The real section actually displayed on the screen
 @return The section as numbered in code
 */
- (NSInteger)codeSectionForRealSection:(NSInteger)section;

@end

@protocol AirTurnUIPeripheralControllerInternalDelegate

@required

- (void)periheralControllerDidForgetAirTurn:(nonnull AirTurnUIPeripheralController *)peripheralController;

@end
