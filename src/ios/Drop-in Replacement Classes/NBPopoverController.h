//
//  NBPopoverController.h
//
//  Created by Nick Brook on 21/09/2011.
//  Copyright (c) 2011 Nick Brook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NBPopoverController : UIPopoverController

- (void)dismissPopoverAnimated:(BOOL)animated willRedisplay:(BOOL)willRedisplay;

@property(nonatomic, assign) BOOL shouldReenableAirTurnOnClose;

@end