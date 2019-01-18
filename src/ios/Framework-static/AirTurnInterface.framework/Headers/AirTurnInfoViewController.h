//
//  AirTurnInfoViewController.h
//  AirTurnInterface
//
//  Created by Nick Brook on 19/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 Controls the presentation and state of the AirTurn info view, which provides the AirTurnInterface version and port state on 6 × two finger taps
 */
@interface AirTurnInfoViewController : NSObject

/**
 If `YES`, a 2 finger 6 tap gesture recognizer is added to the key window on App start. Default `YES`. To prevent the recognizer ever being added to the window, set `NO` before a window becomes key.
 */
@property(nonatomic, assign) BOOL tapGestureRecognizerEnabled;

/**
 Get the shared instance
 
 @return The shared instance
 */
+ (nonnull instancetype)sharedInfoViewController;

/**
 Display the info view
 */
- (void)display;

@end
