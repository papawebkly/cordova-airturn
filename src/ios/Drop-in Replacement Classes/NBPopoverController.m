//
//  NBPopoverController.m
//
//  Created by Nick Brook on 21/09/2011.
//  Copyright (c) 2011 Nick Brook. All rights reserved.
//
// This class is simple subclass of uipopovercontroller which disables the airturn interface on display and enables it again on hide.
//

#import "NBPopoverController.h"
#import <AirTurnInterface/AirTurnViewManager.h>

@interface NBPopoverController() <UIPopoverControllerDelegate> {
    id <UIPopoverControllerDelegate> _NBDelegate;
}

- (void)_enableAirturn;
- (void)_disableAirturn;

@end

@implementation NBPopoverController

- (id)init {
    self = [super init];
    if(self) {
        super.delegate = self;
    }
    return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController {
    self = [super initWithContentViewController:viewController];
    if(self) {
        super.delegate = self;
    }
    return self;
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    [self _disableAirturn];
    dispatch_async(dispatch_get_main_queue(), ^{
        [super presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
    });
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    [self _disableAirturn];
    dispatch_async(dispatch_get_main_queue(), ^{
        [super presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
    });
}

- (void)dismissPopoverAnimated:(BOOL)animated {
    [super dismissPopoverAnimated:animated];
    [self _enableAirturn];
}

#pragma mark - Additional Methods

- (void)_enableAirturn {
    if(self.shouldReenableAirTurnOnClose) {
        [AirTurnViewManager sharedViewManager].paused = NO;
        self.shouldReenableAirTurnOnClose = NO;
    }
}

- (void)_disableAirturn {
    if([AirTurnViewManager sharedViewManager].enabled) {
        self.shouldReenableAirTurnOnClose = YES;
        [AirTurnViewManager sharedViewManager].paused = YES;
    }
}

- (void)dismissPopoverAnimated:(BOOL)animated willRedisplay:(BOOL)willRedisplay {
    if(willRedisplay)
        [super dismissPopoverAnimated:animated];
    else
        [self dismissPopoverAnimated:animated];
}

- (void)setDelegate:(id<UIPopoverControllerDelegate>)delegate {
    _NBDelegate = delegate;
}

- (id<UIPopoverControllerDelegate>)delegate {
    return _NBDelegate;
}

#pragma mark UIPopoverControllerDelegate methods

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    if(_NBDelegate != nil && [_NBDelegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)])
        return [_NBDelegate popoverControllerShouldDismissPopover:popoverController];
    else return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self _enableAirturn];
    if([_NBDelegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
        [_NBDelegate popoverControllerDidDismissPopover:popoverController];
}

@end
