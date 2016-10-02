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

NSString * EnabledUserDefaultKey = @"AirTurnEnabled";
NSString * AutomaticKeyboardManagementUserDefaultKey = @"AirTurnAutomaticKeyboardManagement";
NSString * InitialModeDefaultKey = @"AirTurnBTLEMode";
NSString * AirTurnUIShouldRestoreUserInfoKey = @"AirTurnUIRestoreState";

@interface AirTurnUIConnectionController () <UIAlertViewDelegate>

@property(nonatomic, assign) BOOL scanning;

@property (nonatomic, strong) UITableViewCell *enableCell;
@property (nonatomic, strong) UISwitch *enableSwitch;

@property (nonatomic, strong) UITableViewCell *automaticKeyboardManagementCell;
@property (nonatomic, strong) UISwitch *automaticKeyboardManagementSwitch;

@property (nonatomic, strong) UITableViewCell *scanningCell;
@property (nonatomic, strong) UITableViewCell *otherDevice;

@property (nonatomic, strong) UITableViewHeaderFooterView *deviceHeaderView;
@property (nonatomic, strong) UIActivityIndicatorView *deviceHeaderSpinner;

@property(nonatomic, strong) UITableViewHeaderFooterView *deviceFooterView;
@property(nonatomic, strong) UITableViewHeaderFooterView *unsupportedFooterView;
@property(nonatomic, strong) UITableViewHeaderFooterView *forceKeyboardFooterView;

@property(nonatomic, strong) UIBarButtonItem *infoButton;
@property(nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) UIAlertView *connectionErrorAlert;

@property (nonatomic, weak) AirTurnPeripheral *connectOnAlertDismiss;

@property(nonatomic, strong) NSMutableArray *discoveredDevices;

@property(nonatomic, strong) NSMapTable *requestedConnectTimeoutMap;

@property(nonatomic, assign) BOOL supportHID;
@property(nonatomic, assign) BOOL supportBTLE;

@property(nonatomic, readonly) BOOL isPoweredOn;

- (IBAction)dismiss:(id)sender;

@end

@implementation AirTurnUIConnectionController

+ (NSString *)keyDescriptionFromKeyCode:(AirTurnKeyCode)keyCode {
    switch(keyCode) {
        case AirTurnKeyCodeUnknown: return AirTurnUILocalizedString(@"Unknown", @"Unknown HID key pressed");
        case AirTurnKeyCodeA: return AirTurnUILocalizedString(@"A", @"A HID key pressed");
        case AirTurnKeyCodeB: return AirTurnUILocalizedString(@"B", @"B HID key pressed");
        case AirTurnKeyCodeC: return AirTurnUILocalizedString(@"C", @"C HID key pressed");
        case AirTurnKeyCodeD: return AirTurnUILocalizedString(@"D", @"D HID key pressed");
        case AirTurnKeyCodeE: return AirTurnUILocalizedString(@"E", @"E HID key pressed");
        case AirTurnKeyCodeF: return AirTurnUILocalizedString(@"F", @"F HID key pressed");
        case AirTurnKeyCodeG: return AirTurnUILocalizedString(@"G", @"G HID key pressed");
        case AirTurnKeyCodeH: return AirTurnUILocalizedString(@"H", @"H HID key pressed");
        case AirTurnKeyCodeI: return AirTurnUILocalizedString(@"I", @"I HID key pressed");
        case AirTurnKeyCodeJ: return AirTurnUILocalizedString(@"J", @"J HID key pressed");
        case AirTurnKeyCodeK: return AirTurnUILocalizedString(@"K", @"K HID key pressed");
        case AirTurnKeyCodeL: return AirTurnUILocalizedString(@"L", @"L HID key pressed");
        case AirTurnKeyCodeM: return AirTurnUILocalizedString(@"M", @"M HID key pressed");
        case AirTurnKeyCodeN: return AirTurnUILocalizedString(@"N", @"N HID key pressed");
        case AirTurnKeyCodeO: return AirTurnUILocalizedString(@"O", @"O HID key pressed");
        case AirTurnKeyCodeP: return AirTurnUILocalizedString(@"P", @"P HID key pressed");
        case AirTurnKeyCodeQ: return AirTurnUILocalizedString(@"Q", @"Q HID key pressed");
        case AirTurnKeyCodeR: return AirTurnUILocalizedString(@"R", @"R HID key pressed");
        case AirTurnKeyCodeS: return AirTurnUILocalizedString(@"S", @"S HID key pressed");
        case AirTurnKeyCodeT: return AirTurnUILocalizedString(@"T", @"T HID key pressed");
        case AirTurnKeyCodeU: return AirTurnUILocalizedString(@"U", @"U HID key pressed");
        case AirTurnKeyCodeV: return AirTurnUILocalizedString(@"V", @"V HID key pressed");
        case AirTurnKeyCodeW: return AirTurnUILocalizedString(@"W", @"W HID key pressed");
        case AirTurnKeyCodeX: return AirTurnUILocalizedString(@"X", @"X HID key pressed");
        case AirTurnKeyCodeY: return AirTurnUILocalizedString(@"Y", @"Y HID key pressed");
        case AirTurnKeyCodeZ: return AirTurnUILocalizedString(@"Z", @"Z HID key pressed");
        case AirTurnKeyCode1: return AirTurnUILocalizedString(@"1", @"1 HID key pressed");
        case AirTurnKeyCode2: return AirTurnUILocalizedString(@"2", @"2 HID key pressed");
        case AirTurnKeyCode3: return AirTurnUILocalizedString(@"3", @"3 HID key pressed");
        case AirTurnKeyCode4: return AirTurnUILocalizedString(@"4", @"4 HID key pressed");
        case AirTurnKeyCode5: return AirTurnUILocalizedString(@"5", @"5 HID key pressed");
        case AirTurnKeyCode6: return AirTurnUILocalizedString(@"6", @"6 HID key pressed");
        case AirTurnKeyCode7: return AirTurnUILocalizedString(@"7", @"7 HID key pressed");
        case AirTurnKeyCode8: return AirTurnUILocalizedString(@"8", @"8 HID key pressed");
        case AirTurnKeyCode9: return AirTurnUILocalizedString(@"9", @"9 HID key pressed");
        case AirTurnKeyCode0: return AirTurnUILocalizedString(@"0", @"0 HID key pressed");
        case AirTurnKeyCodeBackslash: return AirTurnUILocalizedString(@"Backslash", @"Backslash HID key pressed");
        case AirTurnKeyCodeComma: return AirTurnUILocalizedString(@"Comma", @"Comma HID key pressed");
        case AirTurnKeyCodeEqual: return AirTurnUILocalizedString(@"Equal", @"Equal HID key pressed");
        case AirTurnKeyCodeGrave: return AirTurnUILocalizedString(@"Grave", @"Grave HID key pressed");
        case AirTurnKeyCodeKeypadMultiply: return AirTurnUILocalizedString(@"KP Multiply", @"KP Multiply HID key pressed");
        case AirTurnKeyCodeKeypadPlus: return AirTurnUILocalizedString(@"KP Plus", @"KP Plus HID key pressed");
        case AirTurnKeyCodeLeftBracket: return AirTurnUILocalizedString(@"Left Bracket", @"Left Bracket HID key pressed");
        case AirTurnKeyCodeRightBracket: return AirTurnUILocalizedString(@"Right Bracket", @"Right Bracket HID key pressed");
        case AirTurnKeyCodeMinus: return AirTurnUILocalizedString(@"Minus", @"Minus HID key pressed");
        case AirTurnKeyCodePeriod: return AirTurnUILocalizedString(@"Period", @"Period HID key pressed");
        case AirTurnKeyCodeQuote: return AirTurnUILocalizedString(@"Quote", @"Quote HID key pressed");
        case AirTurnKeyCodeSemicolon: return AirTurnUILocalizedString(@"Semicolon", @"Semicolon HID key pressed");
        case AirTurnKeyCodeSlash: return AirTurnUILocalizedString(@"Slash", @"Slash HID key pressed");
        case AirTurnKeyCodeForwardDelete: return AirTurnUILocalizedString(@"Forward Delete", @"Forward Delete HID key pressed");
        case AirTurnKeyCodeDelete: return AirTurnUILocalizedString(@"Delete", @"Delete HID key pressed");
        case AirTurnKeyCodeUpArrow: return AirTurnUILocalizedString(@"Up Arrow", @"Up Arrow HID key pressed");
        case AirTurnKeyCodeRightArrow: return AirTurnUILocalizedString(@"Right Arrow", @"Right Arrow HID key pressed");
        case AirTurnKeyCodeDownArrow: return AirTurnUILocalizedString(@"Down Arrow", @"Down Arrow HID key pressed");
        case AirTurnKeyCodeLeftArrow: return AirTurnUILocalizedString(@"Left Arrow", @"Left Arrow HID key pressed");
        case AirTurnKeyCodePageUp: return AirTurnUILocalizedString(@"Page Up", @"Page Up HID key pressed");
        case AirTurnKeyCodePageDown: return AirTurnUILocalizedString(@"Page Down", @"Page down HID key pressed");
        case AirTurnKeyCodeReturn: return AirTurnUILocalizedString(@"Return", @"Return HID key pressed");
        case AirTurnKeyCodeSpace: return AirTurnUILocalizedString(@"Space", @"Space HID key pressed");
        case AirTurnKeyCodeTab: return AirTurnUILocalizedString(@"Tab", @"Tab HID key pressed");
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
    }
}

+ (void)windowDidBecomeKey {
#if DEBUG
    NSLog(@"Starting AirTurnUI...");
#endif
    if([[NSUserDefaults standardUserDefaults] boolForKey:InitialModeDefaultKey]) { // BTLE
        [AirTurnCentral sharedCentral].enabled = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } else if([AirTurnKeyboardManager automaticKeyboardManagementAvailable]) {
        if([AirTurnKeyboardManager sharedManager]) {
            [self keyboardManagerReady];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardManagerReady) name:AirTurnKeyboardManagerReadyNotification object:nil];
        }
    } else {
        [AirTurnViewManager sharedViewManager].enabled = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

+ (void)keyboardManagerReady {
    [AirTurnViewManager sharedViewManager].enabled = YES;
    [AirTurnKeyboardManager sharedManager].automaticKeyboardManagementEnabled = [self keyboardManagementShouldEnable];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)keyboardManagementShouldEnable {
    return [AirTurnKeyboardManager automaticKeyboardManagementAvailable] && ([[NSUserDefaults standardUserDefaults] objectForKey:AutomaticKeyboardManagementUserDefaultKey] == nil || [[NSUserDefaults standardUserDefaults] boolForKey:AutomaticKeyboardManagementUserDefaultKey]);
}

- (id)initSupportingHIDAirTurn:(BOOL)hid BTLEAirTurn:(BOOL)btle {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        _displayEnableToggle = YES;
        _supportHID = hid;
        _supportBTLE = btle;
        _maxNumberOfBTLEAirTurns = 1;
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _displayEnableToggle = YES;
        _supportBTLE = YES;
        _supportHID = YES;
        _maxNumberOfBTLEAirTurns = 1;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _displayEnableToggle = YES;
        _supportBTLE = YES;
        _supportHID = YES;
        _maxNumberOfBTLEAirTurns = 1;
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
    
    if(!_supportHID && !_supportBTLE) {
        @throw([NSException exceptionWithName:@"AirTurnInvalidInit" reason:@"Please initialise the class setting HID and/or BTLE support true" userInfo:nil]);
    }
    
    BOOL wantedToSupportBTLE = _supportBTLE;
    
    if(floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0 || [AirTurnCentral sharedCentral].state == AirTurnCentralStateUnsupported || [AirTurnCentral sharedCentral].state == AirTurnCentralStateUnauthorized) {
        _supportBTLE = NO;
    }
    
    self.navigationItem.title = @"AirTurn";
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setRightBarButtonItem:self.infoButton animated:NO];

    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:self.doneButton animated:NO];
    
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
    
    UIActivityIndicatorView *scanningSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [scanningSpinner startAnimating];
    
    self.scanningCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.scanningCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.scanningCell.textLabel.textColor = [UIColor lightGrayColor];
    self.scanningCell.accessoryView = scanningSpinner;

    if(_supportBTLE && _supportHID) {
        self.otherDevice = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    self.discoveredDevices = [NSMutableArray arrayWithCapacity:1];
    self.requestedConnectTimeoutMap = [NSMapTable strongToStrongObjectsMapTable];
    
    if(floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_6_0) {
        // setup device list header view
        UITableViewHeaderFooterView *v = [[UITableViewHeaderFooterView alloc] init];
        self.deviceHeaderView = v;
        UILabel *l = [[UILabel alloc] init];
        l.font = [UIFont systemFontOfSize:15];
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
        [v addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[l]-[av]" options:NSLayoutFormatDirectionLeftToRight | NSLayoutFormatAlignAllCenterY metrics:nil views:d]];
        [v.contentView addConstraint:[NSLayoutConstraint constraintWithItem:av attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:v.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        self.deviceFooterView = [UITableViewHeaderFooterView new];
        self.deviceFooterView.textLabel.font = [UIFont systemFontOfSize:18];
        self.deviceFooterView.textLabel.textColor = [UIColor grayColor];
        
        self.unsupportedFooterView = [UITableViewHeaderFooterView new];
        if(!wantedToSupportBTLE) {
            self.unsupportedFooterView.textLabel.text = AirTurnUILocalizedString(@"AirTurn PED is only supported in modes 2-5 in this App", @"AirTurn PED unsupported text");
        }
        
        self.forceKeyboardFooterView = [UITableViewHeaderFooterView new];
        self.forceKeyboardFooterView.textLabel.text = AirTurnUILocalizedString(@"If on, the virtual keyboard will be forced on screen when a text box is active and a BT-105 or external keyboard is connected", @"Automatic keyboard managment toggle description");
    }
    
    if(!_supportBTLE && wantedToSupportBTLE) {
        [self BTLEUnsupported];
    }
    
    _BTLEMode = [[NSUserDefaults standardUserDefaults] boolForKey:InitialModeDefaultKey];
    if(_BTLEMode) {
       if(!_supportBTLE) {
           _BTLEMode = NO;
       }
    } else {
        if(!_supportHID) {
            _BTLEMode = YES;
        }
    }
    
    if(_supportBTLE) {
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
    
    if([UIApplication sharedApplication].keyWindow.subviews.count)
        // trigger setter actions
        self.BTLEMode = _BTLEMode;
    else
        [nc addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
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
    [nc addObserver:self selector:@selector(connectingToAirTurn:) name:AirTurnConnectingNotification object:nil];
    [nc addObserver:self selector:@selector(connectionStateChanged:) name:AirTurnConnectionStateChangedNotification object:nil];
    [nc addObserver:self selector:@selector(didDisconnect:) name:AirTurnDidDisconnectNotification object:nil];
    [nc addObserver:self selector:@selector(deviceUpdatedName:) name:AirTurnDidUpdateNameNotification object:nil];
    [nc addObserver:self selector:@selector(failedToConnect:) name:AirTurnDidFailToConnectNotification object:nil];
    [nc addObserver:self selector:@selector(pedalPressed:) name:AirTurnPedalPressNotification object:nil];
    [nc addObserver:self selector:@selector(airTurnAdded:) name:AirTurnAddedNotification object:nil];
    [nc addObserver:self selector:@selector(airTurnRemoved:) name:AirTurnRemovedNotification object:nil];
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

- (void)setPreferredContentSize:(CGSize)preferredContentSize {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if([UIViewController instancesRespondToSelector:@selector(setPreferredContentSize:)])
#endif
    {
        [super setPreferredContentSize:preferredContentSize];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.contentSizeForViewInPopover = preferredContentSize;
#pragma clang diagnostic pop
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
- (CGSize)preferredContentSize {
    return [UIViewController instancesRespondToSelector:@selector(preferredContentSize)] ? [super preferredContentSize] : self.contentSizeForViewInPopover;
}
#endif

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    if(_BTLEMode && [AirTurnCentral initialized]) {
        AirTurnCentralState state = [AirTurnCentral sharedCentral].state;
        if(state == AirTurnCentralStateConnected || state == AirTurnCentralStateDisconnected) {
            self.scanning = YES;
        }
    }
    [self.tableView reloadData];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    if(_BTLEMode && [AirTurnCentral initialized]) {
        self.scanning = NO;
    }
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestConnect:(AirTurnPeripheral *)AirTurn {
    [self.requestedConnectTimeoutMap setObject:[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(connectionTimeout:) userInfo:AirTurn repeats:NO] forKey:AirTurn];
    [[AirTurnCentral sharedCentral] connectToAirTurn:AirTurn];
}

- (void)cancelConnectRequest:(AirTurnPeripheral *)AirTurn {
    [[self.requestedConnectTimeoutMap objectForKey:AirTurn] invalidate];
    [self.requestedConnectTimeoutMap removeObjectForKey:AirTurn];
    if(AirTurn.connectionState == AirTurnConnectionStateConnecting && ![[AirTurnCentral sharedCentral].storedAirTurns containsObject:AirTurn]) {
        [[AirTurnCentral sharedCentral] cancelAirTurnConnection:AirTurn];
    }
}

- (BOOL)scanning {
    if(_BTLEMode) {
        if([AirTurnCentral initialized] && [AirTurnCentral sharedCentral].scanning)
            return YES;
    } else {
        if([AirTurnViewManager initialized] && [AirTurnViewManager sharedViewManager].enabled && ![AirTurnViewManager sharedViewManager].connected)
            return YES;
    }
    return NO;
}

- (void)setScanning:(BOOL)scanning {
    if(!_BTLEMode) return;
    [AirTurnCentral sharedCentral].scanning = scanning;
    scanning && self.discoveredDevices.count > 0 ? [self.deviceHeaderSpinner startAnimating] : [self.deviceHeaderSpinner stopAnimating];
}

- (void)setBTLEMode:(BOOL)BTLEMode {
    if((BTLEMode && !_supportBTLE) || (!BTLEMode && !_supportHID)) return;
    _BTLEMode = BTLEMode;
    [[NSUserDefaults standardUserDefaults] setBool:_BTLEMode forKey:InitialModeDefaultKey];
    NSString * PED = AirTurnUILocalizedString(@"PED", @"PED Product name");
    NSString * BT105 = AirTurnUILocalizedString(@"BT-105", @"BT-105 product name");
    NSString * product = _BTLEMode ? PED : BT105;
    NSString * otherProduct = _BTLEMode ? BT105 : PED;
    if(self.otherDevice)
        self.otherDevice.textLabel.text = [NSString stringWithFormat:AirTurnUILocalizedString(@"My device is a %@", @"Switch device type"), otherProduct];
    self.scanningCell.textLabel.text = [NSString stringWithFormat:AirTurnUILocalizedString(@"Scanning for %@...", @"Text to display in the placeholder for the list of devices when none have been found"), product];
    // stop scanning
    if(!_BTLEMode && [AirTurnCentral initialized])
        self.scanning = NO;
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
    BOOL HIDEnabled = _enabled && _supportHID && !_BTLEMode;
    if(HIDEnabled || [AirTurnViewManager initialized]) {
        [AirTurnViewManager sharedViewManager].enabled = HIDEnabled;
        self.automaticKeyboardManagementSwitch.on = [AirTurnUIConnectionController keyboardManagementShouldEnable];
        [AirTurnKeyboardManager sharedManager].automaticKeyboardManagementEnabled = HIDEnabled && self.automaticKeyboardManagementSwitch.on;
    }
    BOOL BTLEEnabled = _enabled && _supportBTLE && _BTLEMode;
    if(BTLEEnabled || [AirTurnCentral initialized]) {
        [AirTurnCentral sharedCentral].enabled = BTLEEnabled;
    }
}

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
    if(!_supportBTLE) return YES;
    AirTurnCentralState state = [AirTurnCentral sharedCentral].state;
    return state == AirTurnCentralStateDisconnected || state == AirTurnCentralStateConnected || state == AirTurnCentralStateDisabled;
}

- (AirTurnUIPeripheralController *)currentlyDisplayedPeripheral {
    for(UIViewController *c in self.navigationController.viewControllers) {
        if([c isKindOfClass:[AirTurnUIPeripheralController class]]) {
            return (AirTurnUIPeripheralController *)c;
        }
    }
    return nil;
}

- (BOOL)isPeripheralViewDisplayed {
    return [self currentlyDisplayedPeripheral] != nil;
}

- (void)displayConnectedAirTurnViewForAirTurn:(AirTurnPeripheral *)AirTurn animated:(BOOL)animated {
    if(self.isPeripheralViewDisplayed || !AirTurn) return;
    [self.navigationController pushViewController:[[AirTurnUIPeripheralController alloc] initWithPeripheral:AirTurn] animated:animated];
}

#pragma mark - Notifications

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // trigger setter actions
    self.BTLEMode = _BTLEMode;
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

- (void)BTLEUnsupported {
    self.unsupportedFooterView.textLabel.text = AirTurnUILocalizedString(@"AirTurn PED is not supported on this device", @"PED unsupported text");
}

- (void)stateChanged:(NSNotification *)n {
    AirTurnCentralState state = [AirTurnCentral sharedCentral].state;
    // check if enable cell not displayed and we are powered on
    if(state != AirTurnCentralStatePoweredOff && !self.enableCell.window)
        [self.tableView reloadData];
    switch(state) {
        case AirTurnCentralStateDisconnected:
        case AirTurnCentralStateConnected:
            if(_supportBTLE && _enabled && self.isViewLoaded && self.view.window) {
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
            // we have just arrived here from unknown state, so we need to switch to HID if available, otherwise just display AirTurn unavailable
            _supportBTLE = NO;
            [self BTLEUnsupported];
            self.BTLEMode = NO;
            [self animateTableChanges];
            break;
    }
}

- (NSUInteger)insertAirTurn:(AirTurnPeripheral *)p {
    if([self.discoveredDevices containsObject:p]) return NSNotFound;
    NSUInteger index = [self.discoveredDevices indexOfObject:p inSortedRange:NSMakeRange(0, self.discoveredDevices.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(AirTurnPeripheral * obj1, AirTurnPeripheral * obj2) {
        NSString *name = obj2.name;
        if(name == nil) return obj1.name == nil ? NSOrderedSame : NSOrderedDescending;
        return [obj1.name compare:(NSString *
                                   _Nonnull)name options:NSLiteralSearch];
    }];
    [self.discoveredDevices insertObject:p atIndex:index];
    return index;
}

- (void)_deviceDiscovered:(AirTurnPeripheral *)p {
    NSUInteger index = [self insertAirTurn:p];
    if(index == NSNotFound) return;
    
    if(!self.isPoweredOn || !_BTLEMode) return;
    
    [self.deviceHeaderSpinner startAnimating];
    
    // if only 1 device, just reload searching row
    if(self.discoveredDevices.count <= 1)
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:[self realSectionForCodeSection:1]]] withRowAnimation:UITableViewRowAnimationNone];
    else
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:[self realSectionForCodeSection:1]]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deviceDiscovered:(NSNotification *)n {
    AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
    [self _deviceDiscovered:p];
}

- (void)deviceUpdatedName:(NSNotification *)n {
    if(!self.isPoweredOn || !_BTLEMode) return;
    AirTurnPeripheral *p = n.object;
    NSUInteger index = [self.discoveredDevices indexOfObject:p];
    if(index == NSNotFound) return;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:[self realSectionForCodeSection:1]]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)_deviceLost:(AirTurnPeripheral *)p {
    NSUInteger index = [self.discoveredDevices indexOfObject:p];
    if(index == NSNotFound) return;
    [self.discoveredDevices removeObject:p];
    if(!self.isPoweredOn || !_BTLEMode) return;
    if(self.discoveredDevices.count == 0) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:[self realSectionForCodeSection:1]]] withRowAnimation:UITableViewRowAnimationNone];
        [self.deviceHeaderSpinner stopAnimating];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:[self realSectionForCodeSection:1]]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)deviceLost:(NSNotification *)n {
    AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
    [self _deviceLost:p];
}

- (void)connectionStateChanged:(NSNotification *)n {
    if(_BTLEMode) {
        AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
        switch([n.userInfo[AirTurnConnectionStateKey] intValue]) {
            case AirTurnConnectionStateConnected:
                [self cancelConnectRequest:p];
                
                if(![self.discoveredDevices containsObject:p]) {
                    [self _deviceDiscovered:p];
                    return;
                }
                break;
            default: break;
        }
    }
    [self.tableView reloadData];
}

- (void)didDisconnect:(NSNotification *)n {
    AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
    if(p != nil) {
        if(self.currentlyDisplayedPeripheral.peripheral == p) {
            // pop off peripheral controller on disconnect
            [self.navigationController popToViewController:self animated:YES];
        }
        NSTimer *t = [self.requestedConnectTimeoutMap objectForKey:p];
        if(t != nil) {
            [self failedToConnect:n];
            return;
        }
    }
    [self.tableView reloadData];
}

- (void)connectingToAirTurn:(NSNotification *)n {
    AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
    if([self.discoveredDevices containsObject:p]) {
        [self.tableView reloadData];
    }
}

- (void)failedToConnect:(NSNotification *)n {
    if(!self.isPoweredOn || !_BTLEMode) return;
    NSString * errorMessage;
    NSError *error = n.userInfo[AirTurnErrorKey];
    AirTurnPeripheral *p = n.userInfo[AirTurnPeripheralKey];
    
    NSUInteger r = [self.discoveredDevices indexOfObject:p];
    if(r == NSNotFound) return;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:r inSection:[self realSectionForCodeSection:1]]] withRowAnimation:UITableViewRowAnimationNone];
    
    // do not show alert if we didn't request a connection to this device
    if([self.requestedConnectTimeoutMap objectForKey:p] == nil) return;
    [self cancelConnectRequest:p];
    
    // do not show alert if already on
    if(self.connectionErrorAlert) return;
    
    switch(error.code) {
        case AirTurnErrorPeripheralNotPaired:
            errorMessage = AirTurnUILocalizedString(@"AirTurn requires pairing to connect.  Please try connecting again and tap \"Pair\" when requested.  You may need to wait a few minutes before trying again, or simply turn off your BlueTooth and back on.", @"Pairing error message");
            break;
        default: {
            NSString *device = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? AirTurnUILocalizedString(@"iPad", @"iPad device type") : AirTurnUILocalizedString(@"iPhone", @"iPhone device type");
            errorMessage = AirTurnUILocalizedString(@"A problem occurred connecting to the AirTurn pedal, please try again.  If the problem persists open iOS settings > Bluetooth > tap the icon next to AirTurn and tap \"Forget this device\", then reboot your %@", @"Error message on  connection problem");
            errorMessage = [NSString stringWithFormat:errorMessage, device];
        } break;
    }
    
    self.connectionErrorAlert = [[UIAlertView alloc] initWithTitle:AirTurnUILocalizedString(@"AirTurn", @"Product name") message:errorMessage delegate:self cancelButtonTitle:AirTurnUILocalizedString(@"Ok", nil) otherButtonTitles:nil];
    [self.connectionErrorAlert show];
}

- (void)pedalPressed:(NSNotification *)n {
    NSNumber *num = n.userInfo[AirTurnKeyCodeKey];
    if(!num) return;
    AirTurnKeyCode key = num.integerValue;
    NSString *string = [AirTurnUIConnectionController keyDescriptionFromKeyCode:key];
    
    self.deviceFooterView.textLabel.text = [NSString stringWithFormat:AirTurnUILocalizedString(@"Last key pressed: %@", @"Device footer view for BT-105 indicating last key pressed"), string];
    [self.deviceFooterView.textLabel sizeToFit];
    
    // trigger footer reload
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(!self.isPoweredOn || !_BTLEMode) return;
    if(alertView == self.connectionErrorAlert || self.connectOnAlertDismiss) {
        self.connectionErrorAlert = nil;
        if(self.connectOnAlertDismiss) {
            [self requestConnect:self.connectOnAlertDismiss];
            NSInteger row = [self.discoveredDevices indexOfObject:self.connectOnAlertDismiss];
            if(row != NSNotFound)
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:[self realSectionForCodeSection:1]]] withRowAnimation:UITableViewRowAnimationNone];
            self.connectOnAlertDismiss = nil;
        }
    }
}

- (void)connectionTimeout:(NSTimer *)timer {
    AirTurnPeripheral *p = timer.userInfo;
    [self cancelConnectRequest:p];
    if(!self.isPoweredOn || !_BTLEMode) {
        return;
    }
    self.connectionErrorAlert = [[UIAlertView alloc] initWithTitle:AirTurnUILocalizedString(@"AirTurn", @"Product name") message:AirTurnUILocalizedString(@"Connection to the AirTurn timed out.  Please check the device is on and in range.  Otherwise please try forgetting the device from iOS Bluetooth settings", @"Connection timed out message") delegate:self cancelButtonTitle:AirTurnUILocalizedString(@"Ok", nil) otherButtonTitles:nil];
    [self.connectionErrorAlert show];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.discoveredDevices indexOfObject:p] inSection:[self realSectionForCodeSection:1]]] withRowAnimation:UITableViewRowAnimationNone];
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

/*!
 *  Gets the actual section number from the 'code' section number provided
 *
 *  @param section the section number to translate
 *
 *  @return the real section number to reload etc.
 */
- (NSInteger)realSectionForCodeSection:(NSInteger)section {
    return section + section - [self codeSectionForRealSection:section];
}

/*!
 *  Gets the 'code' section number, i.e. the section number used in switches and logic, from the actual section number requested
 *
 *  @param section section number requested
 *
 *  @return 'code' section number
 */
- (NSInteger)codeSectionForRealSection:(NSInteger)section { // increment section by 1 if these specific conditions
    if(self.isPoweredOn) {
        if(!_displayEnableToggle && (_supportBTLE || (_supportHID && [AirTurnKeyboardManager automaticKeyboardManagementAvailable]))) { // advance past enable toggle if we support BTLE or we support HID and have the force keyboard toggle (otherwise we display a simple 'enabled' message in section 0)
            section++;
        }
        if(section == 1 && !_BTLEMode && ![AirTurnKeyboardManager automaticKeyboardManagementAvailable] && _supportBTLE) { // HID mode, no force keyboard toggle but we need switch mode
            return 2; // toggle switch
        }
    }
    return section;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if((!_supportHID && !_supportBTLE) || !self.isPoweredOn)
        // unsupported or powered off cell
        return 1;
    // Return the number of sections.
    NSInteger sections = 0;
    if(_displayEnableToggle) {
        sections++;
    }
    if(_enabled) {
        if(_BTLEMode) {
            sections++; // searching/devices
        }
        if([AirTurnKeyboardManager automaticKeyboardManagementAvailable]) {
            sections++; // keyboard management toggle
        }
        if(_supportBTLE && _supportHID) {
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
            return _BTLEMode && self.discoveredDevices.count ? self.discoveredDevices.count : 1;
        case 2: // switch mode cell
            return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([self codeSectionForRealSection:section] == 1 && _enabled && _BTLEMode) {
        return self.deviceHeaderSpinner.intrinsicContentSize.height + 10;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([self codeSectionForRealSection:section] == 1 && _enabled && _BTLEMode) {
        self.scanning && self.discoveredDevices.count > 0 ? [self.deviceHeaderSpinner startAnimating] : [self.deviceHeaderSpinner stopAnimating];
        return self.deviceHeaderView;
    }
    return nil;
}

- (CGFloat)heightOfHeaderFooterView:(UITableViewHeaderFooterView *)view {
    return (CGFloat)(ceil((double)[view.textLabel.text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 2*self.tableView.separatorInset.left, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:view.textLabel.font} context:nil].size.height) + 20.0f);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch([self codeSectionForRealSection:section]) {
        case 0:
            if(!_supportBTLE) {
                return [self heightOfHeaderFooterView:self.unsupportedFooterView];
            }
            break;
        case 1:
            if(!_BTLEMode && [AirTurnKeyboardManager automaticKeyboardManagementAvailable]) {
                return [self heightOfHeaderFooterView:self.forceKeyboardFooterView];
            }
            break;
        case 2:
            if(!self.BTLEMode && self.deviceFooterView.textLabel.text.length) {
                return [self heightOfHeaderFooterView:self.deviceFooterView];
            }
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch ([self codeSectionForRealSection:section]) {
        case 0:
            if(!_supportBTLE) {
                return self.unsupportedFooterView;
            }
            break;
        case 1:
            if(!_BTLEMode && [AirTurnKeyboardManager automaticKeyboardManagementAvailable]) {
                return self.forceKeyboardFooterView;
            }
            break;
        case 2:
            if(!self.BTLEMode && self.deviceFooterView.textLabel.text.length) {
                return self.deviceFooterView;
            }
            break;
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self codeSectionForRealSection:indexPath.section] == 0 && indexPath.row == 0 && (!self.isPoweredOn || (!_supportBTLE && !_supportHID))) {
        return 60; // return big cell for powered off or unsupported
    }
    return 44;
}

- (void)addView:(UIView *)view andButtonToCell:(UITableViewCell *)cell {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [b addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat maxHeight = MAX(b.frame.size.height, view.frame.size.height);
    CGRect frame = view.frame;
    frame.origin.y = (maxHeight - view.frame.size.height)/2;
    view.frame = frame;
    frame = b.frame;
    frame.origin.x = view.frame.size.width + 10;
    frame.origin.y = (maxHeight - b.frame.size.height)/2;
    b.frame = frame;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(b.frame), maxHeight)];
    [v addSubview:view];
    [v addSubview:b];
    cell.accessoryView = v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch([self codeSectionForRealSection:indexPath.section]) {
        case 0: {// enable switch
            BOOL poweredOn = self.isPoweredOn;
            BOOL supported = _supportBTLE || _supportHID;
            if(poweredOn && supported) {
                if(_displayEnableToggle) {
                    return self.enableCell;
                } else {
                    // we would have no cells to display since no BTLE and no force keyboard toggle
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
        case 1: {// devices list
            if(!_BTLEMode) {
                return self.automaticKeyboardManagementCell;
            }
            if(!self.discoveredDevices.count) {
                return self.scanningCell;
            }
            UITableViewCell *c;
            AirTurnPeripheral *p = self.discoveredDevices[indexPath.row];
            BOOL stored = [[AirTurnCentral sharedCentral].storedAirTurns containsObject:p];
            AirTurnConnectionState state = p.connectionState;
            NSString *reuseID = [@"connectionListCell" stringByAppendingFormat:@"%d", (int)state];
            if(stored) {
                reuseID = [reuseID stringByAppendingString:@"s"];
            }
            c = [self.tableView dequeueReusableCellWithIdentifier:reuseID];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:state == AirTurnConnectionStateConnected ? UITableViewCellStyleValue1 : UITableViewCellStyleDefault reuseIdentifier:reuseID];
                switch (state) {
                    case AirTurnConnectionStateConnected:
                        if(p.batteryLevel <= AirTurnPeripheralLowBatteryLevel) {
                            [self addView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"battery-low"]] andButtonToCell:c];
                        } else {
                            c.accessoryType = UITableViewCellAccessoryDetailButton;
                            c.detailTextLabel.text = AirTurnUILocalizedString(@"Connected", @"Text to display next to a connected device");
                        }
                        c.selectionStyle = UITableViewCellSelectionStyleNone;
                        break;
                    case AirTurnConnectionStateConnecting:
                    case AirTurnConnectionStateDisconnected:
                        if(stored) {
                            UIActivityIndicatorView * a = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [a startAnimating];
                            [self addView:a andButtonToCell:c];
                            c.selectionStyle = UITableViewCellSelectionStyleNone;
                        } else if(state == AirTurnConnectionStateConnecting) {
                            UIActivityIndicatorView * a = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [a startAnimating];
                            c.accessoryView = a;
                            c.selectionStyle = UITableViewCellSelectionStyleNone;
                        }
                        break;
                    case AirTurnConnectionStateUnknown:
                        break;
                }
            } else {
                if(state == AirTurnConnectionStateConnecting) {
                    UIActivityIndicatorView *v = nil;
                    if([c.accessoryView isKindOfClass:[UIActivityIndicatorView class]]) {
                        v = (UIActivityIndicatorView *)c.accessoryView;
                    } else if(c.accessoryView.subviews.count && [c.accessoryView.subviews[0] isKindOfClass:[UIActivityIndicatorView class]]) {
                        v = c.accessoryView.subviews[0];
                    }
                    [v startAnimating];
                }
            }
            c.textLabel.text = p.name;
            return c;
        }
        case 2: // switch mode button
            return self.otherDevice;

    }
    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch([self codeSectionForRealSection:indexPath.section]) {
        case 1: {
            if(!self.discoveredDevices.count) return;
            AirTurnPeripheral *p = self.discoveredDevices[indexPath.row];
            if([self.requestedConnectTimeoutMap objectForKey:p] == nil) {
                if([[AirTurnCentral sharedCentral].storedAirTurns containsObject:p]) {
                    [self requestConnect:p];
                } else if(self.maxNumberOfBTLEAirTurns == 0 || [AirTurnCentral sharedCentral].storedAirTurns.count < self.maxNumberOfBTLEAirTurns) {
                    self.connectOnAlertDismiss = p;
                    [[[UIAlertView alloc] initWithTitle:AirTurnUILocalizedString(@"Pairing Required", @"AirTurn pre-connect pairing warning title") message:AirTurnUILocalizedString(@"AirTurn requires pairing to operate.  If prompted, please tap \"Pair\"", @"AirTurn pre-connect pairing warning message") delegate:self cancelButtonTitle:AirTurnUILocalizedString(@"Ok", nil) otherButtonTitles:nil] show];
                } else {
                    [[[UIAlertView alloc] initWithTitle:AirTurnUILocalizedString(@"Max number of AirTurns", @"AirTurn max number of AirTurns") message:[NSString stringWithFormat:AirTurnUILocalizedString(@"You can only connect %d AirTurn(s) at once. To connect to this AirTurn, forget another AirTurn first", @"AirTurn max number of AirTurns message"), self.maxNumberOfBTLEAirTurns] delegate:self cancelButtonTitle:AirTurnUILocalizedString(@"Ok", nil) otherButtonTitles:nil] show];
                }
            }
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
        case 2:
            self.BTLEMode = !self.BTLEMode;
            return;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if([self codeSectionForRealSection:indexPath.section] != 1) return;
    AirTurnPeripheral *p = self.discoveredDevices[indexPath.row];
    [self.navigationController pushViewController:[[AirTurnUIPeripheralController alloc] initWithPeripheral:p] animated:YES];
}

#pragma mark - Actions

- (void)infoButtonAction:(UIButton *)button {
    [[AirTurnInfoViewController sharedInfoViewController] display];
}

- (void)doneButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)enableSwitchChanged:(UISwitch *)sender {
    self.enabled = sender.on;
}

- (void)automaticKeyboardManagementSwitchChanged:(UISwitch *)sender {
    [AirTurnKeyboardManager sharedManager].automaticKeyboardManagementEnabled = sender.on;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:AutomaticKeyboardManagementUserDefaultKey];
}

- (void)accessoryButtonTapped:(UIButton *)sender {
    UIView *c = sender.superview;
    while(![c isKindOfClass:[UITableViewCell class]]) {
        c = c.superview;
        if(c == nil) {
            return;
        }
    }
    NSIndexPath *ip = [self.tableView indexPathForCell:(UITableViewCell *)c];
    [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:ip];
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
