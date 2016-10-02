//
//  NBTableViewController.m
//  AirTurnExample
//
//  Created by Nick Brook on 18/08/2013.
//
//

#import "NBTableViewController.h"
#import <AirTurnInterface/AirTurnKeyboardManager.h>

@interface NBTableViewController ()

- (void)adjustTableView;

@property(nonatomic, assign) AirTurnKeyboardManager *keyboardManager;

@end

@implementation NBTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.keyboardManager = [AirTurnKeyboardManager sharedManager];
    
    [self adjustTableView];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(event) name:UIKeyboardDidShowNotification object:nil];
    [nc addObserver:self selector:@selector(event) name:UIKeyboardDidHideNotification object:nil];
    [nc addObserver:self selector:@selector(event) name:AirTurnVirtualKeyboardDidShowNotification object:nil];
    [nc addObserver:self selector:@selector(event) name:AirTurnVirtualKeyboardDidHideNotification object:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)event {
    // perform after short timeout as insets do not appear to be set immediately by tableViewController
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(adjustTableView) userInfo:nil repeats:NO];
}

- (void)adjustTableView {
	UITableView *v = (UITableView *)self.view;
	UIEdgeInsets i = UIEdgeInsetsMake(0, 0, self.keyboardManager.isKeyboardVisible ? self.keyboardManager.keyboardFrameIncludingBar.size.height : 0, 0);
	v.contentInset = i;
	v.scrollIndicatorInsets = i;
}

@end
