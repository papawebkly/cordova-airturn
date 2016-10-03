//
//  AirTurnInfoViewController.h
//  AirTurnInterface
//
//  Created by Nick Brook on 19/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AirTurnInfoViewController : NSObject

/*!
 *  If `YES`, a 2 finger 6 tap gesture recognizer is added to the key window on App start. Default YES. To prevent the recognizer ever being added to the window, set `NO` before a window becomes key.
 */
@property(nonatomic, assign) BOOL tapGestureRecognizerEnabled;

/*!
 *  Get the shared instance
 *
 *  @return The shared instance
 */
+ (instancetype)sharedInfoViewController;

/*!
 *  Display the info view
 */
- (void)display;

@end
