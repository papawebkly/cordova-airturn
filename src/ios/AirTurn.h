//
//  BrotherPrinterPlugin.h
//  BrotherPrinterPlugin
//
//  Created by Ye Star on 4/9/16.
//
//

#import <Cordova/CDVPlugin.h>
#import <AirTurnInterface/AirTurnInterface.h>
#import "AirTurnUIPeripheralController.h"
#import <AirTurnInterface/AirTurnKeyboardManager.h>

#ifndef IBInspectable
#define IBInspectable
#endif

@interface AirTurn : CDVPlugin<UIPopoverPresentationControllerDelegate>
/*
 AirTurn Support On/Off
 Detect AirTurn connected
 Get Device Name
 Get AirTurn Interface Version
 */
- (void)initAirTurn:(CDVInvokedUrlCommand*)command;
- (void)setting:(CDVInvokedUrlCommand*)command;
- (void)killApp:(CDVInvokedUrlCommand*)command;
- (void)isConnected:(CDVInvokedUrlCommand*)command;
- (void)getInfo:(CDVInvokedUrlCommand*)command;

- (void)addEventListener:(CDVInvokedUrlCommand*)command;
- (void)removeEventListener:(CDVInvokedUrlCommand*)command;

@property (nonatomic,strong) NSMutableDictionary *observerMap;
@end
