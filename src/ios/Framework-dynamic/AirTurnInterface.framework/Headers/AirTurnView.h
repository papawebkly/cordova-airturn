//
//  AirTurnView.h
//  AirTurnInterface
//
//  Created by Nick Brook on 04/01/2012.
//  Copyright (c) 2012 Nick Brook. All rights reserved.
//
//  Note: This class is only intended for use with the HID part of the framework.  If you are not supporting HID AirTurns, do not use this class.
//

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnTypes.h>
#import <AirTurnInterface/ARCHelper.h>

@protocol AirTurnViewDelegate;

/*!
 AirTurnViewManager manages this AirTurnView class automatically; using AirTurnView directly allows you to manage the virtual keyboard and first responder control however you want.  AirTurnKeyboardManager is provided to help you control the virtual keyboard should you wish to take that approach.  You can achieve everything that AirTurnViewManager does through the public interfaces provided in this header and AirTurnKeyboardManager.
 
 If you use AirTurnView directly do not use the AirTurnViewManager class at all as the first time you use the AirTurnViewManager class it assumes control over the shared AirTurnView instance.
 
 This class has a singleton method.  You should use this to obtain the shared instance of the AirTurnView.  I can see no real need to have more than one instance of AirTurnView, but if you do create multiple instances it should not cause any problems.
 
 */
@interface AirTurnView : UIView

/// ---------------------------------
/// @name Singleton methods
/// ---------------------------------

/*!
 *  Determine if the shared view object has been initialized without triggering initialization
 *
 *  @return YES if initialized
 */
+ (BOOL)initialized;

/*!
 *  Get the shared view
 *
 *  @return The shared view object
 */
+ (nonnull AirTurnView *)sharedView;

/// ---------------------------------
/// @name Delegate
/// ---------------------------------

/*!
 *  The AirTurnView delegate
 */
@property(nonatomic, ah_weak_delegate, nullable) NSObject<AirTurnViewDelegate> *delegate;

/// ---------------------------------
/// @name Input view
/// ---------------------------------

/*!
 *  You can set your own input view (an empty view with a CGRectZero frame) as another way to disable the virtual keyboard when the AirTurnView is first responder.  This will alleviate issues with popovers as the keyboard will have no height, but it will also remove the animation of the keyboard when changing first responder.
 */
@property (readwrite, strong, nullable) UIView *inputView;


/// ---------------------------------
/// @name Parent view
/// ---------------------------------

/*!
 *  The superview of this view
 */
@property(nonatomic, ah_weak_delegate, nullable) UIView *parentView;

/*!
 *  Remove the AirTurn View from a parent view.  Passing the parent view ensures the AirTurn View is only removed if the passed parent view is its current superview.  If the passed view is not the superview, this method does nothing.
 *  After removing itself from the passed view the AirTurn view will automatically attach to the view of the root view controller of the key window.
 *
 *  @param view The view you would like to remove the AirTurn view from
 */
- (void)resignParentView:(nonnull UIView *)view;

/*!
 *  Remove the AirTurn view from the view heirarchy completely.  The AirTurn view will not be a member of a window after this.
 */
- (void)removeFromViewHierarchy;

/// ---------------------------------
/// @name First responder
/// ---------------------------------

/*!
 *  The default resignFirstResponder calls the delegate methods which will usually be set up to show the keyboard automatically or something.  If you want to just resign first responder with nothing else (ie the super method) call this.
 *
 *  @return YES if the responder was resigned as first responder
 */
- (BOOL)resignFirstResponderNoDelegate;

@end

/*!
 *  The `AirTurnViewDelegate` protocol provides notifications of `AirTurnView` view heirarchy and first responder events
 */
@protocol AirTurnViewDelegate <NSObject>
@optional

/// ---------------------------------
/// @name View Heirarchy
/// ---------------------------------

/*!
 *  The `AirTurnView` object will remove itself from the view heirarchy
 */
- (void)AirTurnViewWillRemoveFromViewHierarchy;

/*!
 *  The `AirTurnView` object did remove itself from the view heirarchy
 */
- (void)AirTurnViewDidRemoveFromViewHierarchy;

/// ---------------------------------
/// @name Window
/// ---------------------------------

/*!
 *  The `AirTurnView` object will move to a new window
 *
 *  @param window The new window the view will move to
 */
- (void)AirTurnViewWillMoveToWindow:(nullable UIWindow *)window;

/*!
 *  The `AirTurnView` moved to a new window
 *
 *  @param window The new parent window
 */
- (void)AirTurnViewDidMoveToWindow:(nullable UIWindow *)window;

/// ---------------------------------
/// @name Becoming First Responder
/// ---------------------------------

/*!
 *  Determine if the view should become first responder
 *
 *  @return Return `NO` to prevent the `AirTurnView` from becoming first responder
 */
- (BOOL)AirTurnViewShouldBecomeFirstResponder;

/*!
 *  The `AirTurnView` will attempt to become first responder
 */
- (void)AirTurnViewWillBecomeFirstResponder;

/*!
 *  The `AirTurnView` did become first responder
 */
- (void)AirTurnViewDidBecomeFirstResponder;

/*!
 *  The `AirTurnView` did not become first responder
 */
- (void)AirTurnViewDidNotBecomeFirstResponder;

/// ---------------------------------
/// @name Resigning First Responder
/// ---------------------------------

/*!
 *  Determine if the view should resign first responder
 *
 *  @return Return `NO` to prevent the `AirTurnView` from resigning first responder
 */
- (BOOL)AirTurnViewShouldResignFirstResponder;

/*!
 *  The `AirTurnView` will attempt to resign first responder
 */
- (void)AirTurnViewWillResignFirstResponder;

/*!
 *  The `AirTurnView` did resign first responder
 */
- (void)AirTurnViewDidResignFirstResponder;

/*!
 *  The `AirTurnView` did not resign first responder
 */
- (void)AirTurnViewDidNotResignFirstResponder;


@required
/// ---------------------------------
/// @name Port actions
/// ---------------------------------

/*!
 *  The `AirTurnView` did detect a port action
 *
 *  @param port The port that the action occurred on
 *  @param key  Any associated key code
 */
- (void)AirTurnViewPortPressed:(AirTurnPort)port key:(AirTurnKeyCode)key;

@end
