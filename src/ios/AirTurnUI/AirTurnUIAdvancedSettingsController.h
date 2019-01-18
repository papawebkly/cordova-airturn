//
//  AirTurnUIPeripheralAdvancedController.h
//  AirTurn
//
//  Created by Nick Brook on 21/11/2017.
//

#import <UIKit/UIKit.h>

#import <AirTurnInterface/AirTurnPeripheral.h>

extern const AirTurnPeripheralFeaturesAvailable advancedFeatures;

@class AirTurnUIAdvancedSettingsController;

@protocol AirTurnUIAdvancedSettingsControllerDelegate <NSObject>

@required

- (void)advancedSettingsControllerDidUpdateDeviceName:(AirTurnUIAdvancedSettingsController *)controller;

- (void)advancedSettingsControllerDidUpdateKeyRepeatMode:(AirTurnUIAdvancedSettingsController *)controller;

- (void)advancedSettingsControllerDidUpdateFastResponseEnabled:(AirTurnUIAdvancedSettingsController *)controller;

- (void)advancedSettingsControllerDidUpdatePairingMethod:(AirTurnUIAdvancedSettingsController *)controller;

- (void)advancedSettingsControllerDidUpdateDebounceTime:(AirTurnUIAdvancedSettingsController *)controller;

@end

@interface AirTurnUIAdvancedSettingsController : UITableViewController <UITextFieldDelegate>

@property(nonatomic, weak) id <AirTurnUIAdvancedSettingsControllerDelegate> delegate;

@property(nonatomic, strong) NSString *deviceName;
@property(nonatomic, strong) NSString *defaultDeviceName;

@property(nonatomic, assign) BOOL keyRepeatEnabled;
@property(nonatomic, assign) BOOL isOSKeyRepeat;

@property(nonatomic, assign) BOOL fastResponseEnabled;

@property(nonatomic, assign) BOOL pairingMethodEnabled;
@property(nonatomic, assign) AirTurnPeripheralPairingMethod pairingMethod;
@property(nonatomic, assign) AirTurnPeripheralPairingState pairingState;
@property(nonatomic, assign) uint8_t numberOfPairedDevices;

@property(nonatomic, assign) BOOL debounceTimeEnabled;
@property(nonatomic, assign) AirTurnPeripheralDebounceTime debounceTime;

@end

