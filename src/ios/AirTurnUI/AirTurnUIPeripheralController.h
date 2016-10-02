//
//  AirTurnUIPeripheralController.h
//  AirTurnExample
//
//  Created by Nick Brook on 04/03/2014.
//
//

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnPeripheral.h>

#define AirTurnUILocalizedString(key, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"AirTurnUI"]

@interface AirTurnUIPeripheralController : UITableViewController

@property(nonatomic, readonly, nonnull) AirTurnPeripheral *peripheral;

- (nonnull instancetype)initWithPeripheral:(nonnull AirTurnPeripheral *)peripheral;

@end
