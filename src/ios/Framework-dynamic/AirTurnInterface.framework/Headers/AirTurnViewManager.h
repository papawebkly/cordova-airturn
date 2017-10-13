//
//  AirTurnViewManager.h
//
//  Created by Nick Brook on 03/01/2012.
//  Copyright 2012 Nick Brook. All rights reserved.
//
//  Note: This class is only intended for use with the HID part of the framework.  If you are not supporting HID AirTurns, do not use this class.
//

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnTypes.h>
#import <AirTurnInterface/ARCHelper.h>

/**
 The `AirTurnViewManager` class manages the shared `AirTurnView` object, controlling its location in the view heirarchy, first responder state, and managing the keyboard appropriately.
 */
@interface AirTurnViewManager : NSObject

/// ---------------------------------
/// @name Singleton methods
/// ---------------------------------

/**
 Determine if the shared view manager object has been initialized without triggering initialization
 
 @return `YES` if initialized
 */
+ (BOOL)initialized;

/**
 Get the shared view manager
 
 @return The shared view manager object
 */
+ (nonnull AirTurnViewManager *)sharedViewManager;

/// ---------------------------------
/// @name View manager state
/// ---------------------------------

/**
 @property enabled
 @brief A Boolean value that determines whether the `AirTurnView` manager is enabled
 @discussion If set to `YES`, the view manager will attempt to make the view the first responder, removing focus from any text field. Changing the value of this will also dispatch connection notifications.
 */
@property(nonatomic, assign) BOOL enabled;

/**
 @property connected
 @brief A Boolean value that determines whether an AirTurn is connected
 @discussion This property is provided for informational purposes only and is not guaranteed to be accurate.
 */
@property(nonatomic, readonly) BOOL connected;

/**
 @property paused
 @brief A Boolean value that determines whether the manager is paused
 @discussion If set `YES`, resigns the `AirTurnView` as first responder until set back to `NO`.
 Performs operations synchronously on the main queue – if you are calling from another queue, use `dispatch_async` with the main queue when setting.
 */
@property(nonatomic, assign) BOOL paused;

/// ---------------------------------
/// @name Parent view management
/// ---------------------------------

/**
 @property parentView
 @brief The parent view of the `AirTurnView`
 @discussion You can manually set the parent window for the `AirturnView`.  If you do not do this, it is added to the view of the root view controller of the key window when enabled.
 */
@property(nonatomic, ah_weak_delegate, nullable) UIView *parentView;

/**
 Remove the `AirTurnView` from a parent view.  Passing the parent view ensures the `AirTurnView` is only removed if the passed parent view is its current superview.  If the passed view is not the superview, this method does nothing.
 After removing itself from the passed view the `AirTurnView` will automatically attach to the first subview of the key window.
 
 @param view The view you would like to remove the `AirTurnView` from
 */
- (void)resignParentView:(nonnull UIView *)view;

/**
 The hidden view is always persistent in the view hierarchy if the interface is used in your project.  To remove the view from your view hierarchy, call this method.
 This method also disables the interface.  If you enable the interface or set a new parent view, the view will be added back into your view hierarchy.
 */
- (void)removeFromViewHierarchy;

/// ---------------------------------
/// @name First responder management
/// ---------------------------------

/**
 Make the `AirTurnView` first responder.  Should be used if another text field has taken focus, to regain control to the AirTurn interface.
 
 @return `YES` if the `AirTurnView` became the first responder
 */
- (BOOL)becomeFirstResponder;

/**
 Check if the interface text view is currently the first responder.
 The interface may be enabled but not first responder if another view is temporarily first responder.
 
 @return `YES` if the `AirTurnView` is currently the first responder
 */
- (BOOL)isFirstResponder;

@end
