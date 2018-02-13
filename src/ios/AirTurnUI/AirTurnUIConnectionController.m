//
//  AirTurnUIController.m
//  AirTurnExample
//
//  Created by Nick Brook on 01/03/2014.
//
//

#import "AirTurnUIConnectionController.h"
#import <AirTurnInterface/AirTurnInterface.h>
#import <AirTurnInterface/AirTurnKeyboardManager.h>
#import <WebKit/WebKit.h>

#define SECTION_ENABLE 0
#define SECTION_DEVICES 1
#define SECTION_SWITCH_MODE 2

#define FIRST_SECTION SECTION_ENABLE
#define LAST_SECTION SECTION_SWITCH_MODE

static NSString * const EnabledUserDefaultKey = @"AirTurnEnabled";
static NSString * const AutomaticKeyboardManagementUserDefaultKey = @"AirTurnAutomaticKeyboardManagement";
static NSString * const InitialModeDefaultKey = @"AirTurnAirDirectMode";
static NSString * const LastFirmwareUpdateVersionUserDefaultKey = @"LastFirmwareUpdateVersion";

static NSString * const AirTurnUIShouldRestoreUserInfoKey = @"AirTurnUIRestoreState";

static NSString * const ModernConnectionModeName = @"AirDirect";
static NSString * const LegacyConnectionModeName = @"Keyboard";

static NSString * const ModeSwitchInfoURL = @"https://www.airturn.com/framework/info/";
static NSString * const ModeSwitchInfoLoadNotification = @"Loaded";
static NSString * const ModeSwitchInfoTypeNotification = @"Type";
static NSString * const ModeSwitchInfoTypeNotificationContentAirDirect = @"AirDirect";
static NSString * const ModeSwitchInfoTypeNotificationContentKeyboard = @"Keyboard";

static NSString * const AppLinkURL = @"https://www.airturn.com/appLink/";

static AirTurnKeyCode LastPedalPressed = 0;

static Class PeripheralClass;

@interface UITableViewCell(AccessoryViewAdditions)

- (void)setAccessoryViews:(nullable NSArray<UIView *> *)views;

@end

@implementation UITableViewCell(AccessoryViewAdditions)

- (void)setAccessoryViews:(NSArray<UIView *> *)views {
    if(views.count == 0) {
        self.accessoryView = nil;
        return;
    }
    UIView *outer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    [outer setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [outer setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [outer setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [outer setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    UIView *lastView = nil;
    for(UIView *v in views) {
        v.translatesAutoresizingMaskIntoConstraints = NO;
        [outer addSubview:v];
        if(!lastView) {
            [outer addConstraint:[NSLayoutConstraint constraintWithItem:outer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:views[0] attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        }
        [outer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[v]->=0-|" options:0 metrics:nil views:@{@"v":v}]];
        [outer addConstraint:[NSLayoutConstraint constraintWithItem:outer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        if(lastView) {
            [outer addConstraint:[NSLayoutConstraint constraintWithItem:lastView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeLeft multiplier:1 constant:-8]];
        }
        [v setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [v setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [v setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [v setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        lastView = v;
    }
    [outer addConstraint:[NSLayoutConstraint constraintWithItem:outer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];

    outer.translatesAutoresizingMaskIntoConstraints = NO;
    [outer setNeedsLayout];
    [outer layoutIfNeeded];
    [outer sizeToFit];
    self.accessoryView = outer;
    outer.translatesAutoresizingMaskIntoConstraints = YES;
}

@end

@interface AirTurnUIConnectionController () <
AirTurnUIPeripheralControllerInternalDelegate,
WKScriptMessageHandler
>

@property(nonatomic, assign) AirTurnCentralState previousCentralState;

@property(nonatomic, assign) BOOL scanning;

@property(nonatomic, strong) UITableViewCell *enableCell;
@property(nonatomic, strong) UISwitch *enableSwitch;

@property(nonatomic, strong) UITableViewCell *automaticKeyboardManagementCell;
@property(nonatomic, strong) UISwitch *automaticKeyboardManagementSwitch;

@property(nonatomic, strong) UITableViewCell *scanningCell;

@property(nonatomic, strong) AirTurnPeripheral *requestedConnectPeripheral;

@property(nonatomic, strong) UITableViewHeaderFooterView *deviceHeaderView;
@property(nonatomic, strong) UIActivityIndicatorView *deviceHeaderSpinner;

@property(nonatomic, strong) UILabel *KeyboardKeyInfoTableFooter;
@property(nonatomic, strong) UITableViewHeaderFooterView *unsupportedFooterView;
@property(nonatomic, strong) UITableViewHeaderFooterView *forceKeyboardFooterView;
@property(nonatomic, strong) UIView *modeSwitchFooterView;
@property(nonatomic, strong) UILabel *modeSwitchFooterViewLabel;
@property(nonatomic, strong) UIViewController *modeSwitchInfoViewController;
@property(nonatomic, strong) WKWebView *modeSwitchInfoWebView;
@property(nonatomic, strong) UILabel *modeSwitchInfoLoadingView;

@property(nonatomic, strong) UIBarButtonItem *infoButton;

@property(nonatomic, assign) BOOL displayedPairingWarning;

@property(nonatomic, readonly) BOOL shouldPerformAirDirectTableChange;

@property(nonatomic, strong) NSMutableArray<AirTurnPeripheral *> *discoveredDevices;

@property(nonatomic, assign) BOOL supportKeyboard;
@property(nonatomic, assign) BOOL supportAirDirect;

@property(nonatomic, readonly) BOOL isPoweredOn;

- (IBAction)dismiss:(id)sender;

@end

@implementation AirTurnUIConnectionController

+ (NSString *)keyDescriptionFromKeyCode:(AirTurnKeyCode)keyCode {
    switch(keyCode) {
        case AirTurnKeyCodeUnknown: return AirTurnUILocalizedString(@"Unknown", @"Unknown key pressed");
        case AirTurnKeyCodeA: return AirTurnUILocalizedString(@"A", @"A key pressed");
        case AirTurnKeyCodeB: return AirTurnUILocalizedString(@"B", @"B key pressed");
        case AirTurnKeyCodeC: return AirTurnUILocalizedString(@"C", @"C key pressed");
        case AirTurnKeyCodeD: return AirTurnUILocalizedString(@"D", @"D key pressed");
        case AirTurnKeyCodeE: return AirTurnUILocalizedString(@"E", @"E key pressed");
        case AirTurnKeyCodeF: return AirTurnUILocalizedString(@"F", @"F key pressed");
        case AirTurnKeyCodeG: return AirTurnUILocalizedString(@"G", @"G key pressed");
        case AirTurnKeyCodeH: return AirTurnUILocalizedString(@"H", @"H key pressed");
        case AirTurnKeyCodeI: return AirTurnUILocalizedString(@"I", @"I key pressed");
        case AirTurnKeyCodeJ: return AirTurnUILocalizedString(@"J", @"J key pressed");
        case AirTurnKeyCodeK: return AirTurnUILocalizedString(@"K", @"K key pressed");
        case AirTurnKeyCodeL: return AirTurnUILocalizedString(@"L", @"L key pressed");
        case AirTurnKeyCodeM: return AirTurnUILocalizedString(@"M", @"M key pressed");
        case AirTurnKeyCodeN: return AirTurnUILocalizedString(@"N", @"N key pressed");
        case AirTurnKeyCodeO: return AirTurnUILocalizedString(@"O", @"O key pressed");
        case AirTurnKeyCodeP: return AirTurnUILocalizedString(@"P", @"P key pressed");
        case AirTurnKeyCodeQ: return AirTurnUILocalizedString(@"Q", @"Q key pressed");
        case AirTurnKeyCodeR: return AirTurnUILocalizedString(@"R", @"R key pressed");
        case AirTurnKeyCodeS: return AirTurnUILocalizedString(@"S", @"S key pressed");
        case AirTurnKeyCodeT: return AirTurnUILocalizedString(@"T", @"T key pressed");
        case AirTurnKeyCodeU: return AirTurnUILocalizedString(@"U", @"U key pressed");
        case AirTurnKeyCodeV: return AirTurnUILocalizedString(@"V", @"V key pressed");
        case AirTurnKeyCodeW: return AirTurnUILocalizedString(@"W", @"W key pressed");
        case AirTurnKeyCodeX: return AirTurnUILocalizedString(@"X", @"X key pressed");
        case AirTurnKeyCodeY: return AirTurnUILocalizedString(@"Y", @"Y key pressed");
        case AirTurnKeyCodeZ: return AirTurnUILocalizedString(@"Z", @"Z key pressed");
        case AirTurnKeyCode1: return AirTurnUILocalizedString(@"1", @"1 key pressed");
        case AirTurnKeyCode2: return AirTurnUILocalizedString(@"2", @"2 key pressed");
        case AirTurnKeyCode3: return AirTurnUILocalizedString(@"3", @"3 key pressed");
        case AirTurnKeyCode4: return AirTurnUILocalizedString(@"4", @"4 key pressed");
        case AirTurnKeyCode5: return AirTurnUILocalizedString(@"5", @"5 key pressed");
        case AirTurnKeyCode6: return AirTurnUILocalizedString(@"6", @"6 key pressed");
        case AirTurnKeyCode7: return AirTurnUILocalizedString(@"7", @"7 key pressed");
        case AirTurnKeyCode8: return AirTurnUILocalizedString(@"8", @"8 key pressed");
        case AirTurnKeyCode9: return AirTurnUILocalizedString(@"9", @"9 key pressed");
        case AirTurnKeyCode0: return AirTurnUILocalizedString(@"0", @"0 key pressed");
        case AirTurnKeyCodeBackslash: return AirTurnUILocalizedString(@"Backslash", @"Backslash key pressed");
        case AirTurnKeyCodeComma: return AirTurnUILocalizedString(@"Comma", @"Comma key pressed");
        case AirTurnKeyCodeEqual: return AirTurnUILocalizedString(@"Equal", @"Equal key pressed");
        case AirTurnKeyCodeGrave: return AirTurnUILocalizedString(@"Grave", @"Grave key pressed");
        case AirTurnKeyCodeKeypadMultiply: return AirTurnUILocalizedString(@"KP Multiply", @"KP Multiply key pressed");
        case AirTurnKeyCodeKeypadPlus: return AirTurnUILocalizedString(@"KP Plus", @"KP Plus key pressed");
        case AirTurnKeyCodeLeftBracket: return AirTurnUILocalizedString(@"Left Bracket", @"Left Bracket key pressed");
        case AirTurnKeyCodeRightBracket: return AirTurnUILocalizedString(@"Right Bracket", @"Right Bracket key pressed");
        case AirTurnKeyCodeMinus: return AirTurnUILocalizedString(@"Minus", @"Minus key pressed");
        case AirTurnKeyCodePeriod: return AirTurnUILocalizedString(@"Period", @"Period key pressed");
        case AirTurnKeyCodeQuote: return AirTurnUILocalizedString(@"Quote", @"Quote key pressed");
        case AirTurnKeyCodeSemicolon: return AirTurnUILocalizedString(@"Semicolon", @"Semicolon key pressed");
        case AirTurnKeyCodeSlash: return AirTurnUILocalizedString(@"Slash", @"Slash key pressed");
        case AirTurnKeyCodeForwardDelete: return AirTurnUILocalizedString(@"Forward Delete", @"Forward Delete key pressed");
        case AirTurnKeyCodeDelete: return AirTurnUILocalizedString(@"Delete", @"Delete key pressed");
        case AirTurnKeyCodeUpArrow: return AirTurnUILocalizedString(@"↑", @"Up Arrow key pressed");
        case AirTurnKeyCodeRightArrow: return AirTurnUILocalizedString(@"→", @"Right Arrow key pressed");
        case AirTurnKeyCodeDownArrow: return AirTurnUILocalizedString(@"↓", @"Down Arrow key pressed");
        case AirTurnKeyCodeLeftArrow: return AirTurnUILocalizedString(@"←", @"Left Arrow key pressed");
        case AirTurnKeyCodePageUp: return AirTurnUILocalizedString(@"Page Up", @"Page Up key pressed");
        case AirTurnKeyCodePageDown: return AirTurnUILocalizedString(@"Page Down", @"Page down key pressed");
        case AirTurnKeyCodeReturn: return AirTurnUILocalizedString(@"Return", @"Return key pressed");
        case AirTurnKeyCodeSpace: return AirTurnUILocalizedString(@"Space", @"Space key pressed");
        case AirTurnKeyCodeTab: return AirTurnUILocalizedString(@"Tab", @"Tab key pressed");
    }
    return nil;
}

+ (void)load {
    @autoreleasepool {
        NSNumber *n = [[NSBundle mainBundle] objectForInfoDictionaryKey:AirTurnUIShouldRestoreUserInfoKey];
        BOOL restoreEnabledState = n == nil || n.boolValue;
        // register for App loaded to spin up AirTurn classes if AirTurn support has previously been enabled
        if(restoreEnabledState && [[NSUserDefaults standardUserDefaults] boolForKey:EnabledUserDefaultKey]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeKey) name:UIWindowDidBecomeKeyNotification object:nil];
        }
        
        PeripheralClass = [AirTurnUIPeripheralController class];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pedalPressed:) name:AirTurnPedalPressNotification object:nil];
    }
}

+ (void)pedalPressed:(NSNotification *)note {
    NSNumber *num = note.userInfo[AirTurnKeyCodeKey];
    if(!num) return;
    LastPedalPressed = num.integerValue;
}

+ (void)setUIPeripheralClass:(Class)peripheralClass {
    NSAssert([peripheralClass isSubclassOfClass:[AirTurnUIPeripheralController class]], @"The peripheral class set is not a subclass of AirTurnUIPeriheralController");
    PeripheralClass = peripheralClass;
}

+ (void)windowDidBecomeKey {
#if DEBUG
    NSLog(@"Starting AirTurnUI...");
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeKeyNotification object:nil];
    if([[NSUserDefaults standardUserDefaults] boolForKey:InitialModeDefaultKey]) { // AirDirect
        [AirTurnCentral sharedCentral].enabled = YES;
    } else if([AirTurnKeyboardManager automaticKeyboardManagementAvailable]) {
        if([AirTurnKeyboardManager sharedManager]) {
            [self keyboardManagerReady];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardManagerReady) name:AirTurnKeyboardManagerReadyNotification object:nil];
        }
    } else {
        [AirTurnViewManager sharedViewManager].enabled = YES;
        
    }
}

+ (void)keyboardManagerReady {
    [AirTurnViewManager sharedViewManager].enabled = YES;
    [AirTurnKeyboardManager sharedManager].automaticKeyboardManagementEnabled = [self keyboardManagementShouldEnable];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AirTurnKeyboardManagerReadyNotification object:nil];
}

+ (BOOL)keyboardManagementShouldEnable {
    return [AirTurnKeyboardManager automaticKeyboardManagementAvailable] && ([[NSUserDefaults standardUserDefaults] objectForKey:AutomaticKeyboardManagementUserDefaultKey] == nil || [[NSUserDefaults standardUserDefaults] boolForKey:AutomaticKeyboardManagementUserDefaultKey]);
}

- (instancetype)initSupportingKeyboardAirTurn:(BOOL)keyboard AirDirectAirTurn:(BOOL)AirDirect {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        _displayEnableToggle = YES;
        _supportKeyboard = keyboard;
        _supportAirDirect = AirDirect;
        _maxNumberOfAirDirectAirTurns = 1;
        [self setup];
    }
    return self;
}

- (id)initSupportingHIDAirTurn:(BOOL)hid BTLEAirTurn:(BOOL)btle {
    return [self initSupportingKeyboardAirTurn:hid AirDirectAirTurn:btle];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _displayEnableToggle = YES;
        _supportAirDirect = YES;
        _supportKeyboard = YES;
        _maxNumberOfAirDirectAirTurns = 1;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _displayEnableToggle = YES;
        _supportAirDirect = YES;
        _supportKeyboard = YES;
        _maxNumberOfAirDirectAirTurns = 1;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    @throw([NSException exceptionWithName:@"AirTurnInvalidInit" reason:@"Please use -initSupportingHIDAirTurn:BTLEAirTurn: or use in Interface Builder" userInfo:nil]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if(self.tableView.style != UITableViewStyleGrouped)
        @throw([NSException exceptionWithName:@"AirTurnInvalidTableStyle" reason:@"Please set the table view style to grouped in interface builder" userInfo:nil]);
    [self setup];
}

- (void)setup {
    
    NSAssert(floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0, @"This version of the framework only supports iOS 8.0 and higher");
    
    if(!_supportKeyboard && !_supportAirDirect) {
        @throw([NSException exceptionWithName:@"AirTurnInvalidInit" reason:@"Please initialise the class setting Keyboard and/or AirDirect support true" userInfo:nil]);
    }
    
    self.previousCentralState = [AirTurnCentral sharedCentral].state;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 25;
    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionFooterHeight = 25;
    
    BOOL wantedTosupportAirDirect = _supportAirDirect;
    
#if !TARGET_OS_SIMULATOR
    if([AirTurnCentral sharedCentral].state == AirTurnCentralStateUnsupported || [AirTurnCentral sharedCentral].state == AirTurnCentralStateUnauthorized) {
        _supportAirDirect = NO;
    }
#endif
    
    self.navigationItem.title = @"AirTurn";
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setRightBarButtonItem:self.infoButton animated:NO];
    
    self.enableSwitch = [[UISwitch alloc] init];
    self.enableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.enableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.enableCell.accessoryView = self.enableSwitch;
    self.enableCell.textLabel.text = AirTurnUILocalizedString(@"AirTurn Support", @"Text to display next to the enable AirTurn switch");
    
    self.automaticKeyboardManagementSwitch = [[UISwitch alloc] init];
    self.automaticKeyboardManagementCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.automaticKeyboardManagementCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.automaticKeyboardManagementCell.accessoryView = self.automaticKeyboardManagementSwitch;
    self.automaticKeyboardManagementCell.textLabel.text = AirTurnUILocalizedString(@"Force Keyboard", @"Text to display on automatic keyboard management cell");
    
    {
        UIActivityIndicatorView *scanningSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [scanningSpinner startAnimating];
        
        self.scanningCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        self.scanningCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.scanningCell.textLabel.textColor = [UIColor lightGrayColor];
        self.scanningCell.accessoryView = scanningSpinner;
        self.scanningCell.textLabel.text = AirTurnUILocalizedString(@"Scanning...", @"Text to display in the placeholder for the list of devices when none have been found");
    }

    {
        self.modeSwitchFooterView = [UIView new];
        self.modeSwitchFooterViewLabel = [UILabel new];
        self.modeSwitchFooterViewLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.modeSwitchFooterViewLabel.text = AirTurnUILocalizedString(@"Which mode should I use?", @"Mode switch footer 'link' text");
        self.modeSwitchFooterViewLabel.textColor = [UIColor colorWithHue:(CGFloat)(219.0/360.0) saturation:0.79f brightness:0.96f alpha:1];
        self.modeSwitchFooterViewLabel.font = [UIFont systemFontOfSize:16];
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchModeFooterTapped)];
        [self.modeSwitchFooterView addGestureRecognizer:gr];
        [self.modeSwitchFooterView addSubview:self.modeSwitchFooterViewLabel];
        [self.modeSwitchFooterView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[l]-10-|" options:0 metrics:nil views:@{@"l":self.modeSwitchFooterViewLabel}]];
        [self.modeSwitchFooterView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[l]" options:0 metrics:nil views:@{@"l":self.modeSwitchFooterViewLabel}]];
        
        self.modeSwitchInfoViewController = [UIViewController new];
        self.modeSwitchInfoViewController.title = AirTurnUILocalizedString(@"Mode help", @"Mode switch info title");
        self.modeSwitchInfoLoadingView = [UILabel new];
        self.modeSwitchInfoLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
        self.modeSwitchInfoLoadingView.text = AirTurnUILocalizedString(@"Loading...", @"Text to display before mode switch info webpage has loaded");
        [self.modeSwitchInfoViewController.view addSubview:self.modeSwitchInfoLoadingView];
        [self.modeSwitchInfoViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.modeSwitchInfoViewController.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.modeSwitchInfoLoadingView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self.modeSwitchInfoViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.modeSwitchInfoViewController.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.modeSwitchInfoLoadingView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        WKUserContentController * controller = [[WKUserContentController alloc] init];
        [controller addScriptMessageHandler:self name:ModeSwitchInfoLoadNotification];
        [controller addScriptMessageHandler:self name:ModeSwitchInfoTypeNotification];
        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = controller;
        self.modeSwitchInfoWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        self.modeSwitchInfoWebView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.modeSwitchInfoViewController.view addSubview:self.modeSwitchInfoWebView];
        [self.modeSwitchInfoViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v":self.modeSwitchInfoWebView}]];
        [self.modeSwitchInfoViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:@{@"v":self.modeSwitchInfoWebView}]];
    }
    
    self.discoveredDevices = [AirTurnCentral sharedCentral].discoveredAirTurns.allObjects.mutableCopy;
    // setup device list header view
    UITableViewHeaderFooterView *v = [[UITableViewHeaderFooterView alloc] init];
    self.deviceHeaderView = v;
    UILabel *l = [[UILabel alloc] init];
    l.font = [UIFont systemFontOfSize:13];
    l.textColor = [UIColor grayColor];
    l.text = AirTurnUILocalizedString(@"DEVICES", @"The text in the heading above the list of devices");
    [l setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIActivityIndicatorView *av = self.deviceHeaderSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [av startAnimating];
    [av setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [v.contentView addSubview:l];
    [v.contentView addSubview:av];
    
    // constraints
    NSDictionary *d = @{@"l":l,@"av":av};
    [v.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[l]-[av]" options:0 metrics:nil views:d]];
    [v.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15.5-[l]-6.5-|" options:0 metrics:nil views:d]];
    [v.contentView addConstraint:[NSLayoutConstraint constraintWithItem:l attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:av attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    self.KeyboardKeyInfoTableFooter = [UILabel new];
    self.KeyboardKeyInfoTableFooter.font = [UIFont systemFontOfSize:18];
    self.KeyboardKeyInfoTableFooter.textColor = [UIColor grayColor];
    self.KeyboardKeyInfoTableFooter.textAlignment = NSTextAlignmentCenter;
    [self updatePedalPressed];
    
    
    self.unsupportedFooterView = [UITableViewHeaderFooterView new];
    if(!wantedTosupportAirDirect) {
        self.unsupportedFooterView.textLabel.text = [NSString stringWithFormat:AirTurnUILocalizedString(@"%$1@ is not supported in this App. You can connect %1$@ AirTurns in modes 2-6", @"AirDirect unsupported text"), ModernConnectionModeName];
    }
    
    self.forceKeyboardFooterView = [UITableViewHeaderFooterView new];
    self.forceKeyboardFooterView.textLabel.text = AirTurnUILocalizedString(@"If on, the virtual keyboard will be forced on screen when a text box is active and a BT-105 or external keyboard is connected", @"Automatic keyboard managment toggle description");
    
    if(!_supportAirDirect && wantedTosupportAirDirect) {
        [self AirDirectUnsupported];
    }
    
    _AirDirectMode = YES;
    if([[NSUserDefaults standardUserDefaults] objectForKey:InitialModeDefaultKey] != nil) {
        _AirDirectMode = [[NSUserDefaults standardUserDefaults] boolForKey:InitialModeDefaultKey];
    }
    if(_AirDirectMode) {
       if(!_supportAirDirect) {
           _AirDirectMode = NO;
       }
    } else {
        if(!_supportKeyboard) {
            _AirDirectMode = YES;
        }
    }
    
    if(_supportAirDirect) {
        // trigger initialisation and therefore CBCentralManager check
        AirTurnCentral *c = [AirTurnCentral sharedCentral];
        if(c.discoveredAirTurns.count) {
            for(AirTurnPeripheral *p in c.discoveredAirTurns) {
                [self insertAirTurn:p];
            }
        }
        if(c.storedAirTurns.count) {
            for(AirTurnPeripheral *p in c.storedAirTurns) {
                [self insertAirTurn:p];
            }
        }
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // enabled toggle setup
    _enabled = !_displayEnableToggle || ([AirTurnCentral initialized] && [AirTurnCentral sharedCentral].enabled) || ([AirTurnViewManager initialized] && [AirTurnViewManager sharedViewManager].enabled);
    self.enableSwitch.on = _enabled;
    
    
    [nc addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [nc addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    // keyboard management toggle setup
    [self.automaticKeyboardManagementSwitch addTarget:self action:@selector(automaticKeyboardManagementSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [nc addObserver:self selector:@selector(automaticKeyboardManagementEnabledChanged:) name:AirTurnAutomaticKeyboardManagementEnabledChangedNotification object:nil];
    
    // add event listener after intialising
    [self.enableSwitch addTarget:self action:@selector(enableSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    // other event listeners
    [nc addObserver:self selector:@selector(stateChanged:) name:AirTurnCentralStateChangedNotification object:nil];
    [nc addObserver:self selector:@selector(deviceDiscovered:) name:AirTurnDiscoveredNotification object:nil];
    [nc addObserver:self selector:@selector(deviceLost:) name:AirTurnLostNotification object:nil];
    [nc addObserver:self selector:@selector(connectionStateChanged:) name:AirTurnConnectionStateChangedNotification object:nil];
    [nc addObserver:self selector:@selector(didDisconnect:) name:AirTurnDidDisconnectNotification object:nil];
    [nc addObserver:self selector:@selector(deviceUpdatedName:) name:AirTurnDidUpdateNameNotification object:nil];
    [nc addObserver:self selector:@selector(deviceUpdatedBatteryLevel:) name:AirTurnDidUpdateBatteryLevelNotification object:nil];
    [nc addObserver:self selector:@selector(deviceUpdatedChargingState:) name:AirTurnDidUpdateChargingStateNotification object:nil];
    [nc addObserver:self selector:@selector(failedToConnect:) name:AirTurnDidFailToConnectNotification object:nil];
    [nc addObserver:self selector:@selector(pedalPressed:) name:AirTurnPedalPressNotification object:nil];
    [nc addObserver:self selector:@selector(airTurnAdded:) name:AirTurnAddedNotification object:nil];
    [nc addObserver:self selector:@selector(airTurnRemoved:) name:AirTurnRemovedNotification object:nil];
    
    // set AirDirect mode after registering for notifications so we get alerted of any changes immediately
    if([UIApplication sharedApplication].keyWindow.subviews.count) {
        // trigger setter actions
        _AirDirectMode = !_AirDirectMode;
        self.AirDirectMode = !_AirDirectMode;
    } else {
        [nc addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentSize"]) {
        CGSize size = [self preferredContentSize];
        size.height = self.tableView.contentSize.height;
        size.width = MAX(320, size.width);
        [self setPreferredContentSize:size];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    if(_AirDirectMode && [AirTurnCentral initialized]) {
        AirTurnCentralState state = [AirTurnCentral sharedCentral].state;
        if(state == AirTurnCentralStateConnected || state == AirTurnCentralStateDisconnected) {
            self.scanning = YES;
        }
    }
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    if(_AirDirectMode && [AirTurnCentral initialized]) {
        self.scanning = NO;
    }
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Compatibility

- (BOOL)BTLEMode {
    return self.AirDirectMode;
}

- (void)setBTLEMode:(BOOL)BTLEMode {
    [self setAirDirectMode:BTLEMode];
}

- (BOOL)supportBTLE {
    return self.supportAirDirect;
}

- (void)setSupportBTLE:(BOOL)supportBTLE {
    if(self.infoButton == nil) {
        @throw([NSException exceptionWithName:@"AirTurnUIInvalidInit" reason:@"Please rename the 'User defined runtime attributes' on AirTurnUIConnectionController in your storyboard: 'supportHID' -> 'supportKeyboard' and 'supportBTLE' -> 'supportAirDirect'" userInfo:nil]);
    }
    [self setSupportAirDirect:supportBTLE];
}

- (BOOL)supportHID {
    return self.supportKeyboard;
}

- (void)setSupportHID:(BOOL)supportHID {
    if(self.infoButton == nil) {
        @throw([NSException exceptionWithName:@"AirTurnUIInvalidInit" reason:@"Please rename the 'User defined runtime attributes' on AirTurnUIConnectionController in your storyboard: 'supportHID' -> 'supportKeyboard' and 'supportBTLE' -> 'supportAirDirect'" userInfo:nil]);
    }
    [self setSupportKeyboard:supportHID];
}

#pragma mark Properties

- (BOOL)scanning {
    if(_AirDirectMode) {
        if([AirTurnCentral initialized] && [AirTurnCentral sharedCentral].scanning)
            return YES;
    } else {
        if([AirTurnViewManager initialized] && [AirTurnViewManager sharedViewManager].enabled && ![AirTurnViewManager sharedViewManager].connected)
            return YES;
    }
    return NO;
}

- (void)setScanning:(BOOL)scanning {
    if(!_AirDirectMode) return;
    [AirTurnCentral sharedCentral].scanning = scanning;
    NSMutableSet *s = AirTurnCentral.sharedCentral.discoveredAirTurns.mutableCopy;
    for(AirTurnPeripheral *p in _discoveredDevices.copy) {
        if([s containsObject:p]) {
            [s removeObject:p];
        } else {
            [_discoveredDevices removeObject:p];
        }
    }
    [_discoveredDevices addObjectsFromArray:s.allObjects];
    NSUInteger section = [self realSectionForCodeSection:SECTION_DEVICES];
    if(self.tableView.numberOfSections > section) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        scanning && self.discoveredDevices.count > 0 ? [self.deviceHeaderSpinner startAnimating] : [self.deviceHeaderSpinner stopAnimating];
    }
}

- (void)setAirDirectMode:(BOOL)AirDirectMode {
    if(_AirDirectMode == AirDirectMode) { return; }
    if((AirDirectMode && !_supportAirDirect) || (!AirDirectMode && !_supportKeyboard)) return;
    _AirDirectMode = AirDirectMode;
    [[NSUserDefaults standardUserDefaults] setBool:_AirDirectMode forKey:InitialModeDefaultKey];
    // stop scanning
    if(!_AirDirectMode && [AirTurnCentral initialized]) {
        self.scanning = NO;
    }
    self.tableView.tableFooterView = _AirDirectMode ? nil : self.KeyboardKeyInfoTableFooter;
    [self.tableView reloadData];
    if(self.tableView.numberOfSections > LAST_SECTION && _supportKeyboard && _supportAirDirect) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self realSectionForCodeSection:SECTION_SWITCH_MODE]] withRowAnimation:UITableViewRowAnimationNone];
    }
    // make the change
    [self applyEnabled];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if(self.enableSwitch.on != _enabled) {
        self.enableSwitch.on = enabled;
    }
    [[NSUserDefaults standardUserDefaults] setBool:_enabled forKey:EnabledUserDefaultKey];
    [self applyEnabled];
}

- (void)applyEnabled {
    [self animateTableChanges];
    BOOL KeyboardEnabled = _enabled && _supportKeyboard && !_AirDirectMode;
    if(KeyboardEnabled || [AirTurnViewManager initialized]) {
        [AirTurnViewManager sharedViewManager].enabled = KeyboardEnabled;
        self.automaticKeyboardManagementSwitch.on = [AirTurnUIConnectionController keyboardManagementShouldEnable];
        [AirTurnKeyboardManager sharedManager].automaticKeyboardManagementEnabled = KeyboardEnabled && self.automaticKeyboardManagementSwitch.on;
    }
    BOOL AirDirectEnabled = _enabled && _supportAirDirect && _AirDirectMode;
    if(AirDirectEnabled || [AirTurnCentral initialized]) {
        [AirTurnCentral sharedCentral].enabled = AirDirectEnabled;
    }
#if TARGET_OS_SIMULATOR
    [self addMockPeripheral];
#endif
}

#if TARGET_OS_SIMULATOR
- (void)addMockPeripheral {
    if(_enabled && _AirDirectMode && [AirTurnCentral sharedCentral].discoveredAirTurns.count == 0) {
        [[AirTurnCentral sharedCentral] discoverMockPeripheralModel:AirTurnDeviceTypePEDpro];
    }
}
#endif

- (void)setDisplayEnableToggle:(BOOL)displayEnableToggle {
    if(_displayEnableToggle == displayEnableToggle) return;
    _displayEnableToggle = displayEnableToggle;
    [self animateTableChanges];
}

- (void)animateTableChanges {
    if(![self isViewLoaded]) return;
    NSInteger diff = [self numberOfSectionsInTableView:self.tableView] - self.tableView.numberOfSections;
    if(diff < 0) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.tableView.numberOfSections + diff, -diff)] withRowAnimation:UITableViewRowAnimationFade];
    } else if(diff > 0) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.tableView.numberOfSections, diff)] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }
}

- (BOOL)isPoweredOn {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    if(!_supportAirDirect) return YES;
    AirTurnCentralState state = [AirTurnCentral sharedCentral].state;
    return state == AirTurnCentralStateDisconnected || state == AirTurnCentralStateConnected || state == AirTurnCentralStateDisabled;
#endif
}

- (AirTurnUIPeripheralController *)displayedPeripheralController {
    for(UIViewController *c in self.navigationController.viewControllers) {
        if([c isKindOfClass:[AirTurnUIPeripheralController class]]) {
            return (AirTurnUIPeripheralController *)c;
        }
    }
    return nil;
}

- (void)presentAirTurnPeripheralControllerForPeripheral:(AirTurnPeripheral *)peripheral animated:(BOOL)animated {
    if(self.displayedPeripheralController || !peripheral) return;
    AirTurnUIPeripheralController *vc = [[PeripheralClass alloc] initWithPeripheral:peripheral];
    vc.internalDelegate = self;
    if([self.delegate respondsToSelector:@selector(AirTurnUI:willDisplayPeripheral:)]) {
        [self.delegate AirTurnUI:self willDisplayPeripheral:vc];
    }
    [self.navigationController pushViewController:vc animated:animated];
}

- (void)presentAlert:(UIAlertController *)alertController presentGlobally:(BOOL)presentGlobally animated:(BOOL)animated {
    if(!alertController) { return; }
    if(self.viewLoaded && self.view.window) {
        if([self.presentedViewController isKindOfClass:[UIAlertController class]]) {
            [self.presentedViewController dismissViewControllerAnimated:NO completion:^{
                [self presentAlert:alertController presentGlobally:presentGlobally animated:NO];
            }];
            return;
        }
        [self presentViewController:alertController animated:animated completion:nil];
    } else if(presentGlobally) {
        // display alert in a new window
        UIWindow *alertWindow = [UIWindow new];
        alertWindow.windowLevel = UIWindowLevelAlert;
        alertWindow.backgroundColor = nil;
        alertWindow.opaque = NO;
        UIViewController *rvc = [[UIViewController alloc] init];
        rvc.view.backgroundColor = nil;
        rvc.view.opaque = NO;
        alertWindow.rootViewController = rvc;
        alertWindow.frame = [UIScreen mainScreen].bounds;
        [alertWindow makeKeyAndVisible];
        [alertWindow.rootViewController presentViewController:alertController animated:animated completion:nil];
    }
}

- (void)presentAlert:(UIAlertController *)alertController presentGlobally:(BOOL)presentGlobally animated:(BOOL)animated fromPeripheral:(AirTurnPeripheral *)peripheral {
    alertController.message = [NSString stringWithFormat:@"%@: %@", peripheral.name, alertController.message];
    [self presentAlert:alertController presentGlobally:presentGlobally animated:animated];
}

- (AirTurnErrorHandlingResult)handleError:(nullable NSError *)error context:(AirTurnErrorContext)context peripheral:(AirTurnPeripheral *)peripheral {
    if(!error) {
        return AirTurnErrorHandlingResultNoError;
    }
    UIAlertController *ac = nil;
    AirTurnErrorHandlingResult result = [AirTurnUIPeripheralController handleError:error context:context peripheral:peripheral alertController:&ac dismissHandler:nil];
    if(ac) {
        [self presentViewController:ac animated:YES completion:nil];
    }
    return result;
}

- (AirTurnErrorHandlingResult)handleError:(nullable NSError *)error peripheral:(AirTurnPeripheral *)peripheral {
    return [self handleError:error context:AirTurnErrorContextNone peripheral:peripheral];
}

- (NSArray<AirTurnPeripheral *> *)peripherals {
    return self.discoveredDevices;
}

#pragma mark - Notifications

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // trigger setter actions
    _AirDirectMode = !_AirDirectMode;
    self.AirDirectMode = !_AirDirectMode;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // ensure user defaults always persist
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // ensure user defaults always persist
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)automaticKeyboardManagementEnabledChanged:(NSNotification *)notification {
    self.automaticKeyboardManagementSwitch.on = [AirTurnKeyboardManager sharedManager].automaticKeyboardManagementEnabled;
}

- (BOOL)shouldPerformAirDirectTableChange {
    return self.isPoweredOn && _AirDirectMode && _enabled;
}

- (void)AirDirectUnsupported {
    self.unsupportedFooterView.textLabel.text = AirTurnUILocalizedString(@"AirTurn PED is not supported on this device", @"PED unsupported text");
    self.modeSwitchFooterView = nil;
}

- (void)stateChanged:(NSNotification *)n {
    AirTurnCentralState state = [AirTurnCentral sharedCentral].state;
    // check if enable cell not displayed and we are powered on
    if(state != AirTurnCentralStatePoweredOff && !self.enableCell.window) {
        [self.tableView reloadData];
    }
    if(self.previousCentralState < AirTurnCentralStateDisabled && state >= AirTurnCentralStateDisabled) {
        for(AirTurnPeripheral *p in [AirTurnCentral sharedCentral].discoveredAirTurns) {
            if(![self.discoveredDevices containsObject:p]) {
                [self.discoveredDevices addObject:p];
            }
        }
    }
    switch(state) {
        case AirTurnCentralStateDisconnected:
        case AirTurnCentralStateConnected:
            if(_supportAirDirect && _enabled && self.isViewLoaded && self.view.window) {
                // view is visible, airturn is enabled, btle is supported, so start scanning if not already
                self.scanning = YES;
            }
            [self animateTableChanges];
            break;
        case AirTurnCentralStatePoweredOff:
            [self.tableView reloadData];
            break;
        case AirTurnCentralStateDisabled:
            [self animateTableChanges];
            break;
        case AirTurnCentralStateResetting:
        case AirTurnCentralStateUnknown:
            // do nothing
            break;
        case AirTurnCentralStateUnauthorized:
        case AirTurnCentralStateUnsupported:
#if TARGET_OS_SIMULATOR
            [self addMockPeripheral];
#else
            // we have just arrived here from unknown state, so we need to switch to Keyboard if available, otherwise just display AirTurn unavailable
            _supportAirDirect = NO;
            [self AirDirectUnsupported];
            self.AirDirectMode = NO;
            [self animateTableChanges];
#endif
            break;
    }
}

- (NSUInteger)insertAirTurn:(AirTurnPeripheral *)p {
    if([self.discoveredDevices containsObject:p]) return NSNotFound;
    NSUInteger index = [self.discoveredDevices indexOfObject:p inSortedRange:NSMakeRange(0, self.discoveredDevices.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(AirTurnPeripheral * obj1, AirTurnPeripheral * obj2) {
        NSString *name = obj2.name;
        if(name == nil) return obj1.name == nil ? NSOrderedSame : NSOrderedDescending;
        return [obj1.name compare:(NSString * _Nonnull)name options:NSLiteralSearch];
    }];
    [self.discoveredDevices insertObject:p atIndex:index];
    return index;
}

- (void)_deviceDiscovered:(AirTurnPeripheral *)p {
    NSInteger section = [self realSectionForCodeSection:SECTION_DEVICES];
    NSUInteger index = [self.discoveredDevices indexOfObject:p];
    if(index != NSNotFound) { // already discovered, just reload table cell in case bonding state has changed
        if(self.tableView.numberOfSections > section) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
        }
        return;
    }
    index = [self insertAirTurn:p];
    if(index == NSNotFound) return;
    
    if(!self.shouldPerformAirDirectTableChange) return;
    
    [self.deviceHeaderSpinner startAnimating];
    
    
    if(self.tableView.numberOfSections > section) {
        // if only 1 device, just reload searching row
        if(self.discoveredDevices.count <= 1) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)deviceDiscovered:(NSNotification *)n {
    AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
    [self _deviceDiscovered:p];
}

- (void)deviceChangeNotification:(NSNotification *)n {
    if(!self.shouldPerformAirDirectTableChange) return;
    AirTurnPeripheral *p = n.object;
    [self reloadRowForPeripheral:p];
}

- (void)deviceUpdatedName:(NSNotification *)n {
    [self deviceChangeNotification:n];
}

- (void)deviceUpdatedBatteryLevel:(NSNotification *)n {
    [self deviceChangeNotification:n];
}

- (void)deviceUpdatedChargingState:(NSNotification *)n {
    [self deviceChangeNotification:n];
}

- (void)_deviceLost:(AirTurnPeripheral *)p {
    NSUInteger index = [self.discoveredDevices indexOfObject:p];
    if(index == NSNotFound) return;
    [self.discoveredDevices removeObject:p];
    if(!self.shouldPerformAirDirectTableChange) return;
    NSUInteger section = [self realSectionForCodeSection:SECTION_DEVICES];
    if(self.tableView.numberOfSections > section) {
        if(self.discoveredDevices.count == 0) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
            [self.deviceHeaderSpinner stopAnimating];
        } else {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)deviceLost:(NSNotification *)n {
    AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
    [self _deviceLost:p];
}

- (void)connectionStateChanged:(NSNotification *)n {
    if(_AirDirectMode) {
        AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
        switch(p.state) {
            case AirTurnConnectionStateReady: {
                if(self.checkForFirmwareUpdates && p.deviceType != AirTurnDeviceTypevPED) {
                
                    NSString * lastCheckedKey = [NSString stringWithFormat:@"%@.%@", LastFirmwareUpdateVersionUserDefaultKey, p.identifier];
                    NSString * lastChecked = [[NSUserDefaults standardUserDefaults] stringForKey:lastCheckedKey];
                    [p checkForFirmwareUpdate:^(EDSemver * newVersion) {
                        if(newVersion == nil || (lastChecked != nil && [[EDSemver semverWithString:lastChecked] isEqual:newVersion])) {
                            return;
                        }
                        // update available
                        [[NSUserDefaults standardUserDefaults] setObject:newVersion.description forKey:lastCheckedKey];
                        UIAlertController *ac = [UIAlertController alertControllerWithTitle:AirTurnUILocalizedString(@"Update available", @"Update available alert title") message:[NSString stringWithFormat:AirTurnUILocalizedString(@"A device update is available for the connected AirTurn \"%@\". You can update your AirTurn to get the latest features and fixes in the AirTurn App", @"Update available message"), p.name] preferredStyle:UIAlertControllerStyleAlert];
                        [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"Not now", @"Update available not now dismiss button") style:UIAlertActionStyleCancel handler:nil]];
                        UIAlertAction *goToAppAction = [UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"Go to App", @"Update available go to App dismiss button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppLinkURL]];
                        }];
                        [ac addAction:goToAppAction];
                        [ac setPreferredAction:goToAppAction];
                        
                        [self presentAlert:ac presentGlobally:YES animated:YES];
                        
                    }];                }
                if(p == self.requestedConnectPeripheral) {
                    self.requestedConnectPeripheral = nil;
                }
                if(![self.discoveredDevices containsObject:p]) {
                    [self _deviceDiscovered:p];
                    return;
                }
            } break;
            default: break;
        }
        [self reloadRowForPeripheral:p];
    }
}

- (void)presentConnectionProblemAlertForPeripheral:(AirTurnPeripheral *)peripheral {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:AirTurnUILocalizedString(@"Problem connecting", @"Problem connecting error title") message:[NSString stringWithFormat:AirTurnUILocalizedString(@"There was a problem connecting to %@. This usually happens if you reset your AirTurn to delete the pairing without resetting the pairing in iOS, or have just updated the firmware. To delete the pairing, go in to iOS settings > Bluetooth > %1$@ (tap (i)) > Forget This Device, toggle Bluetooth off and on, then try connecting again in this App by tapping the alert icon next to the AirTurn and then 'Reconnect'", @"Problem connecting error message"), peripheral.name] preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"Dismiss", @"Dismiss button title") style:UIAlertActionStyleCancel handler:nil]];
    [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"iOS Settings", @"iOS settings alert button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:(NSURL * _Nonnull)[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"Reconnect", @"Button to initiate reconnection") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[AirTurnCentral sharedCentral] connectToAirTurn:peripheral];
        
    }]];
    [self presentAlert:ac presentGlobally:NO animated:YES];
}

- (void)didDisconnect:(NSNotification *)n {
    AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
    if(p != nil) {
        if(p == self.requestedConnectPeripheral) {
            self.requestedConnectPeripheral = nil;
        }
        AirTurnUIPeripheralController *displayed = self.displayedPeripheralController;
        if(displayed.peripheral == p) {
            UIAlertController *displayedAlert = displayed.displayedAlert;
            
            if(!displayedAlert) { // if alert displayed, view controller is popped after alert dismiss
                [self.navigationController popToViewController:self animated:YES];
            }
        }
        if(p.lastConnectionFailed) {
            [self presentConnectionProblemAlertForPeripheral:p];
            // peripheral state change notification may occur before lastConnectionFailed is set, so reload row
            [self reloadRowForPeripheral:p];
        }
    }
}

- (void)failedToConnect:(NSNotification *)n {
    if(!self.shouldPerformAirDirectTableChange) return;
    NSError *error = n.userInfo[AirTurnErrorKey];
    AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
    
    if(p == self.requestedConnectPeripheral) {
        self.requestedConnectPeripheral = nil;
    }
    
    [self reloadRowForPeripheral:p];
    
    if(p.lastConnectionFailed) {
        [self presentConnectionProblemAlertForPeripheral:p];
    } else {
        [self handleError:error context:AirTurnErrorContextConnecting peripheral:p];
    }
}

- (void)updatePedalPressed {
    NSString *string = [AirTurnUIConnectionController keyDescriptionFromKeyCode:LastPedalPressed];
    if(string == nil) {
        self.KeyboardKeyInfoTableFooter.text = nil;
        return;
    }
    
    self.KeyboardKeyInfoTableFooter.text = [NSString stringWithFormat:AirTurnUILocalizedString(@"Last key pressed: %@", @"Device footer view for BT-105 indicating last key pressed"), string];
    [self.KeyboardKeyInfoTableFooter sizeToFit];
    self.tableView.tableFooterView = self.KeyboardKeyInfoTableFooter;
}

- (void)pedalPressed:(NSNotification *)n {
    [self updatePedalPressed];
}

- (void)connectionTimeout:(NSTimer *)timer {
    AirTurnPeripheral *p = timer.userInfo;
    [[AirTurnCentral sharedCentral] cancelAirTurnConnection:p];
    if(!self.shouldPerformAirDirectTableChange) {
        return;
    }
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:AirTurnUILocalizedString(@"AirTurn", @"Product name") message:AirTurnUILocalizedString(@"Connection to the AirTurn timed out.  Please check the device is on and in range.  Otherwise please try forgetting the device from iOS Bluetooth settings", @"Connection timed out message") preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"Dismiss", @"Dismiss button title") style:UIAlertActionStyleCancel handler:nil]];
    [self presentAlert:ac presentGlobally:NO animated:YES];
    [self reloadRowForPeripheral:p];
}

- (void)airTurnAdded:(NSNotification *)notification {
    AirTurnPeripheral *p = notification.userInfo[AirTurnPeripheralKey];
    if(!p) { return; }
    [self _deviceDiscovered:p];
}

- (void)airTurnRemoved:(NSNotification *)notification {
    AirTurnPeripheral *p = notification.userInfo[AirTurnPeripheralKey];
    if(!p || [[AirTurnCentral sharedCentral].discoveredAirTurns containsObject:p]) { return; }
    [self _deviceLost:p];
}

#pragma mark - Table view data source

/**
 	Gets the actual section number from the 'code' section number provided
 	
 	@param section the section number to translate
 	
 	@return the real section number to reload etc.
 */
- (NSInteger)realSectionForCodeSection:(NSInteger)section {
    return section + section - [self codeSectionForRealSection:section];
}

/**
 	Gets the 'code' section number, i.e. the section number used in switches and logic, from the actual section number requested
 	
 	@param section section number requested
 	
 	@return 'code' section number
 */
- (NSInteger)codeSectionForRealSection:(NSInteger)section { // increment section by 1 if these specific conditions
    if(self.isPoweredOn) {
        if(!_displayEnableToggle && (_supportAirDirect || (_supportKeyboard && [AirTurnKeyboardManager automaticKeyboardManagementAvailable]))) { // advance past enable toggle if we support AirDirect or we support Keyboard and have the force keyboard toggle (otherwise we display a simple 'enabled' message in section 0)
            section++;
        }
        if(section == 1 && !_AirDirectMode && ![AirTurnKeyboardManager automaticKeyboardManagementAvailable] && _supportAirDirect) { // Keyboard mode, no force keyboard toggle but we need switch mode
            return 2; // toggle switch
        }
    }
    return section;
}

- (void)reloadRowForPeripheral:(AirTurnPeripheral *)peripheral {
    NSUInteger r = [self.discoveredDevices indexOfObject:peripheral];
    NSUInteger section = [self realSectionForCodeSection:SECTION_DEVICES];
    if(r == NSNotFound || self.tableView.numberOfSections <= section) return;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:r inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if((!_supportKeyboard && !_supportAirDirect) || !self.isPoweredOn) {
        // unsupported or powered off cell
        return 1;
    }
    // Return the number of sections.
    NSInteger sections = 0;
    if(_displayEnableToggle) {
        sections++;
    }
    if(_enabled) {
        if(_AirDirectMode) {
            sections++; // searching/devices
        } else if([AirTurnKeyboardManager automaticKeyboardManagementAvailable]) {
            sections++; // keyboard management toggle
        }
        if(_supportAirDirect && _supportKeyboard) {
            sections++; // AirTurn model toggle
        }
    }
    if(sections == 0) {
        sections = 1; // show the unavailable row
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ([self codeSectionForRealSection:section]) {
        case 0: // enable cell or not available
            return 1;
        case 1: // devices list
            return _AirDirectMode && self.discoveredDevices.count ? self.discoveredDevices.count : 1;
        case 2: // switch mode cell
            return 2;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 2:
            return AirTurnUILocalizedString(@"AirTurn Connection Mode", @"AirTurn connection mode section heading");
        default:
            break;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch ([self codeSectionForRealSection:section]) {
        case 1:
            if(_enabled && _AirDirectMode) {
                self.scanning && self.discoveredDevices.count > 0 ? [self.deviceHeaderSpinner startAnimating] : [self.deviceHeaderSpinner stopAnimating];
                return self.deviceHeaderView;
            }
            break;
        default:
            break;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch ([self codeSectionForRealSection:section]) {
        case 0:
            if(!_supportAirDirect) {
                return self.unsupportedFooterView;
            }
            break;
        case 1:
            if(!_AirDirectMode && [AirTurnKeyboardManager automaticKeyboardManagementAvailable]) {
                return self.forceKeyboardFooterView;
            }
            break;
        case 2:
            return self.modeSwitchFooterView;
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // hack for iOS 10.3
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)[self tableView:tableView viewForFooterInSection:section];
    if(v == nil || ![v isKindOfClass:[UITableViewHeaderFooterView class]]) { return UITableViewAutomaticDimension; }
    CGSize s = [v.textLabel sizeThatFits:CGSizeMake(self.tableView.bounds.size.width-40, 0)];
    return s.height + 19;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self codeSectionForRealSection:indexPath.section] == 0 && indexPath.row == 0 && (!self.isPoweredOn || (!_supportAirDirect && !_supportKeyboard))) {
        return 60; // return big cell for powered off or unsupported
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static UIImageView *disclosureImageView = nil;
    if(!disclosureImageView) {
        UIImage *disclosureImage = nil;
        UITableViewCell *tempc = [UITableViewCell new];
        tempc.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [tempc layoutIfNeeded];
        for (UIView *v in tempc.subviews) {
            if([v isKindOfClass:[UIButton class]]) {
                for (UIView *v2 in v.subviews) {
                    if([v2 isKindOfClass:[UIImageView class]]) {
                        disclosureImage = [(UIImageView *)v2 image];
                        break;
                    }
                }
            }
            if(disclosureImage) break;
        }
        if(!disclosureImage) {
            disclosureImage = [UIImage new];
        }
        disclosureImageView = [[UIImageView alloc] initWithImage:disclosureImage];
    }
    switch([self codeSectionForRealSection:indexPath.section]) {
        case SECTION_ENABLE: {// enable switch
            BOOL poweredOn = self.isPoweredOn;
            BOOL supported = _supportAirDirect || _supportKeyboard;
            if(poweredOn && supported) {
                if(_displayEnableToggle) {
                    return self.enableCell;
                } else {
                    // we would have no cells to display since no AirDirect and no force keyboard toggle
                    UITableViewCell *c = [self.tableView dequeueReusableCellWithIdentifier:@"airturnEnabled"];
                    if(!c) {
                        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"airturnEnabled"];
                        c.textLabel.textColor = [UIColor darkGrayColor];
                        c.selectionStyle = UITableViewCellSelectionStyleNone;
                        c.textLabel.text = AirTurnUILocalizedString(@"AirTurn BT-105 support is enabled", @"AirTurn no toggle enabled message");
                    }
                    return c;
                }
            }
            
            NSString * reuseID = supported ? @"poweredOff" : @"notAvailable";
            // not available
            UITableViewCell *c = [self.tableView dequeueReusableCellWithIdentifier:reuseID];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
                c.textLabel.textColor = [UIColor darkGrayColor];
                c.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                c.textLabel.numberOfLines = 0;
                c.selectionStyle = UITableViewCellSelectionStyleNone;
                c.textLabel.text = supported ? AirTurnUILocalizedString(@"Bluetooth is powered off, enable in iOS Settings", @"Bluetooth powered off message") : AirTurnUILocalizedString(@"AirTurn is not available on your device", @"AirTurn is not available on your device message");
            }
            return c;
        }
        case SECTION_DEVICES: {// devices list
            if(!_AirDirectMode) {
                return self.automaticKeyboardManagementCell;
            }
            if(!self.discoveredDevices.count) {
                return self.scanningCell;
            }
            UITableViewCell *c;
            AirTurnPeripheral *p = self.discoveredDevices[indexPath.row];
            BOOL stored = [[AirTurnCentral sharedCentral].storedAirTurns containsObject:p];
            AirTurnConnectionState state = p.state;
            NSString *reuseID = [@"connectionListCell" stringByAppendingFormat:@"%d", (int)state];
            if(stored) {
                reuseID = [reuseID stringByAppendingString:@"s"];
            }
            c = [self.tableView dequeueReusableCellWithIdentifier:reuseID];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:state == AirTurnConnectionStateReady ? UITableViewCellStyleValue1 : UITableViewCellStyleDefault reuseIdentifier:reuseID];
                switch (state) {
                    case AirTurnConnectionStateUnknown:
                    case AirTurnConnectionStateDisconnected:
                    case AirTurnConnectionStateDisconnecting:
                    case AirTurnConnectionStateSystemConnected: // if system connected then we might not have requested connection
                        c.accessoryType = stored ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
                        c.selectionStyle = UITableViewCellSelectionStyleDefault;
                        break;
                    case AirTurnConnectionStateConnecting: // if connecting then we will have requested it, so show spinner
                    case AirTurnConnectionStateDiscovering: {
                        c.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        c.selectionStyle = [[AirTurnCentral sharedCentral].storedAirTurns containsObject:p] ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
                    } break;
                    case AirTurnConnectionStateReady:
                        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        c.selectionStyle = UITableViewCellSelectionStyleDefault;
                        c.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                        break;
                }
            }
            switch (state) {
                case AirTurnConnectionStateReady: {
                    NSMutableArray<UIView *> *views = [NSMutableArray arrayWithCapacity:3];
                    if(p.chargingState != AirTurnPeripheralChargingStateDisconnectedDischarging) {
                        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"battery-charging"]];
                        iv.tintColor = [UIColor blackColor];
                        [views addObject:iv];
                    } else if(p.batteryLevel <= AirTurnPeripheralLowBatteryLevel) {
                        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"battery-low"]];
                        iv.tintColor = [UIColor redColor];
                        [views addObject:iv];
                    }
                    [views addObject:disclosureImageView];
                    if(views.count == 1) {
                        c.accessoryView = nil;
                        // commented out due to overlapping bug in iOS
//                        c.detailTextLabel.text = AirTurnUILocalizedString(@"Connected", @"Text to display next to a connected device");
                    } else {
                        [c setAccessoryViews:views];
                        c.detailTextLabel.text = nil;
                    }
                } break;
                case AirTurnConnectionStateConnecting:
                case AirTurnConnectionStateSystemConnected:
                case AirTurnConnectionStateDiscovering:
                    if([c.accessoryView isKindOfClass:[UIActivityIndicatorView class]]) {
                        [(UIActivityIndicatorView *)c.accessoryView startAnimating];
                    }
                    break;
                case AirTurnConnectionStateDisconnected: {
                    NSMutableArray<UIView *> *views = [NSMutableArray arrayWithCapacity:2];
                    if(p.lastConnectionFailed) {
                        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                        [button addTarget:self action:@selector(deviceConnectionProblemButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                        [button setImage:[UIImage imageNamed:@"alert"] forState:UIControlStateNormal];
                        button.tintColor = [UIColor redColor];
                        [views addObject:button];
                    }
                    if(stored) {
                        [views addObject:disclosureImageView];
                    }
                    if((views.count == 1 && views[0] == disclosureImageView) || views.count == 0) {
                        c.accessoryView = nil; // fall back to accessory
                    } else {
                        [c setAccessoryViews:views];
                    }
                    c.textLabel.textColor = p.hasBonding ? [UIColor grayColor] : [UIColor blackColor];
                } break;
                default:
                    break;
            }
            c.textLabel.text = p.name;
            c.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            [c setNeedsLayout];
            [c layoutIfNeeded];
            return c;
        }
        case SECTION_SWITCH_MODE: { // switch mode button
            UITableViewCell *c = nil;
            switch (indexPath.row) {
                case 0:
                    c = [tableView dequeueReusableCellWithIdentifier:@"airdirect"];
                    if(!c) {
                        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"airdirect"];
                        c.textLabel.text = ModernConnectionModeName;
                    }
                    c.accessoryType = _AirDirectMode ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    return c;
                case 1:
                    c = [tableView dequeueReusableCellWithIdentifier:@"keyboard"];
                    if(!c) {
                        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"keyboard"];
                        c.textLabel.text = LegacyConnectionModeName;
                    }
                    c.accessoryType = _AirDirectMode ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    return c;
                default:
                    break;
            }
        } break;
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}


#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch([self codeSectionForRealSection:indexPath.section]) {
        case 1: {
            if(!self.discoveredDevices.count) return;
            AirTurnPeripheral *p = self.discoveredDevices[indexPath.row];
            switch (p.state) {
                case AirTurnConnectionStateReady:
                    [self presentAirTurnPeripheralControllerForPeripheral:p animated:YES];
                    break;
                case AirTurnConnectionStateDisconnecting:
                case AirTurnConnectionStateDisconnected:
                case AirTurnConnectionStateSystemConnected: // might be system connected and not requested by user
                    if([[AirTurnCentral sharedCentral].storedAirTurns containsObject:p]) {
                        [self presentAirTurnPeripheralControllerForPeripheral:p animated:YES];
                    } else if(self.maxNumberOfAirDirectAirTurns > 0 && [AirTurnCentral sharedCentral].storedAirTurns.count == self.maxNumberOfAirDirectAirTurns) {
                        UIAlertController *ac = [UIAlertController alertControllerWithTitle:AirTurnUILocalizedString(@"Max number of AirTurns", @"AirTurn max number of AirTurns") message:[NSString stringWithFormat:AirTurnUILocalizedString(@"You can only connect %d AirTurn(s) at once. To connect to this AirTurn, forget another AirTurn first", @"AirTurn max number of AirTurns message"), self.maxNumberOfAirDirectAirTurns] preferredStyle:UIAlertControllerStyleAlert];
                        [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"OK", @"OK button title") style:UIAlertActionStyleCancel handler:nil]];
                        [self presentAlert:ac presentGlobally:NO animated:YES];
                    } else if(p.hasBonding) {
                        UIAlertController *ac = [UIAlertController alertControllerWithTitle:AirTurnUILocalizedString(@"Already bonded", @"AirTurn already bonded title") message:AirTurnUILocalizedString(@"This AirTurn is already paired to another device. Reset the AirTurn by holding power for 6s until it flashes to indicate it has reset, then try again", @"AirTurn already bonded message") preferredStyle:UIAlertControllerStyleAlert];
                        [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"OK", @"OK button title") style:UIAlertActionStyleCancel handler:nil]];
                        [self presentAlert:ac presentGlobally:NO animated:YES fromPeripheral:p];
                    } else if(!self.displayedPairingWarning) {
                        self.displayedPairingWarning = YES;
                        UIAlertController *ac = [UIAlertController alertControllerWithTitle:AirTurnUILocalizedString(@"Pairing Required", @"AirTurn pre-connect pairing warning title") message:AirTurnUILocalizedString(@"AirTurn requires pairing to operate.  If prompted, please tap \"Pair\"", @"AirTurn pre-connect pairing warning message") preferredStyle:UIAlertControllerStyleAlert];
                        [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"OK", @"OK button title") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            self.requestedConnectPeripheral = p;
                            [[AirTurnCentral sharedCentral] connectToAirTurn:p];
                        }]];
                        [self presentAlert:ac presentGlobally:NO animated:YES];
                    } else {
                        [[AirTurnCentral sharedCentral] connectToAirTurn:p];
                    }
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    break;
                default:
                    if([[AirTurnCentral sharedCentral].storedAirTurns containsObject:p]) {
                        [self presentAirTurnPeripheralControllerForPeripheral:p animated:YES];
                    }
                    break;
            }
            return;
        }
        case 2:
            self.AirDirectMode = indexPath.row == 0;
            return;
    }
}

#pragma mark - Actions

- (void)infoButtonAction:(UIButton *)button {
    [[AirTurnInfoViewController sharedInfoViewController] display];
}

- (void)enableSwitchChanged:(UISwitch *)sender {
    self.enabled = sender.on;
}

- (void)switchModeFooterTapped {
    if(self.modeSwitchInfoWebView.URL == nil) {
        self.modeSwitchInfoWebView.hidden = YES;
        [self.modeSwitchInfoWebView loadRequest:[NSURLRequest requestWithURL:(NSURL * _Nonnull)[NSURL URLWithString:ModeSwitchInfoURL]]];
    }
    if(self.view.window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        self.modeSwitchInfoViewController.modalPresentationStyle = UIModalPresentationNone;
        self.modeSwitchInfoViewController.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:self.modeSwitchInfoViewController animated:YES];
        // use this vc insets as they will be the same
        self.modeSwitchInfoWebView.scrollView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0, self.bottomLayoutGuide.length, 0.0);
    } else {
        self.modeSwitchInfoViewController.modalPresentationStyle = UIModalPresentationPopover;
        self.modeSwitchInfoViewController.preferredContentSize = CGSizeMake(400, 400);
        self.modeSwitchInfoViewController.view.backgroundColor = [UIColor clearColor];
        [self presentViewController:self.modeSwitchInfoViewController animated:true completion:nil];
        UIPopoverPresentationController *pc = self.modeSwitchInfoViewController.popoverPresentationController;
        pc.permittedArrowDirections = UIPopoverArrowDirectionAny;
        pc.sourceView = self.modeSwitchFooterView;
        pc.sourceRect = self.modeSwitchFooterViewLabel.frame;
        self.modeSwitchInfoWebView.scrollView.contentInset = UIEdgeInsetsZero;
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if([message.name isEqualToString:ModeSwitchInfoLoadNotification]) {
        self.modeSwitchInfoWebView.hidden = NO;
        NSDictionary *d = message.body;
        if(d && [d isKindOfClass:NSDictionary.class]) {
            NSNumber *height = d[@"height"];
            if(height) {
                CGSize s = self.modeSwitchInfoViewController.preferredContentSize;
                s.height = (CGFloat)height.doubleValue;
                self.modeSwitchInfoViewController.preferredContentSize = s;
            }
        }
    } else if([message.name isEqualToString:ModeSwitchInfoTypeNotification]) {
        if(self.modeSwitchInfoViewController.popoverPresentationController) {
            [self.modeSwitchInfoViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popToViewController:self animated:YES];
        }
        if([message.body isEqual:ModeSwitchInfoTypeNotificationContentAirDirect]) {
            self.AirDirectMode = YES;
        } else if([message.body isEqual:ModeSwitchInfoTypeNotificationContentKeyboard]) {
            self.AirDirectMode = NO;
        }
    }
}

- (void)automaticKeyboardManagementSwitchChanged:(UISwitch *)sender {
    [AirTurnKeyboardManager sharedManager].automaticKeyboardManagementEnabled = sender.on;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:AutomaticKeyboardManagementUserDefaultKey];
}

- (void)deviceConnectionProblemButtonTapped:(UIButton *)sender {
    UIView *c = sender.superview;
    while(![c isKindOfClass:[UITableViewCell class]]) {
        c = c.superview;
        if(c == nil) {
            return;
        }
    }
    NSIndexPath *ip = [self.tableView indexPathForCell:(UITableViewCell *)c];
    AirTurnPeripheral *p = self.discoveredDevices[ip.row];
    [self presentConnectionProblemAlertForPeripheral:p];
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AirTurnUIPeripheralControllerInternalDelegate

- (void)periheralControllerDidForgetAirTurn:(AirTurnUIPeripheralController *)peripheralController {
    if(!peripheralController) { return; }
    [self reloadRowForPeripheral:peripheralController.peripheral];
}
@end
