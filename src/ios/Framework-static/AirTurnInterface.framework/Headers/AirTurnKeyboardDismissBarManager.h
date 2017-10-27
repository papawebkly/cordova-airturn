//
//  AirTurnKeyboardDismissBarManager.h
//  
//
//  Created by Nick Brook on 22/06/2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 Manages a dismiss bar which sits atop the virtual keyboard to allow it to be dismissed
 */
@interface AirTurnKeyboardDismissBarManager : NSObject

/**
 Determines if the manager is active
 
 @return `YES` if active
 */
+ (BOOL)isActive;

/**
 Set the manager active or inactive
 
 @param active `YES` if active
 */
+ (void)setActive:(BOOL)active;

/**
 Get the frame of the dismiss bar
 
 @return Dismiss bar frame
 */
+ (CGRect)barFrame;

@end
