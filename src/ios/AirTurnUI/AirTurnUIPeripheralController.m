//
//  AirTurnUIPeripheralController.m
//  AirTurnExample
//
//  Created by Nick Brook on 04/03/2014.
//
//

#import "AirTurnUIPeripheralController.h"
#import <AirTurnInterface/AirTurnCentral.h>

#define BlueCellColor [UIColor colorWithRed:0 green:122.0f/255.0f blue:1 alpha:1]
#define TableCellPadding 16

#define SECTION_FORGET 0
#define SECTION_PROGRAMMING 1
#define SECTION_ADVANCED 2
#define SECTION_BUTTONS 3

typedef NS_OPTIONS(NSUInteger, AirTurnPeripheralWriteProgress) {
    AirTurnPeripheralWriteProgressDelayBeforeRepeat = 1 << 0,
    AirTurnPeripheralWriteProgressRepeatRate = 1 << 1,
    AirTurnPeripheralWriteProgressIdlePowerOff = 1 << 2,
    AirTurnPeripheralWriteProgressConnectionConfiguration = 1 << 3,
    AirTurnPeripheralWriteProgressDeviceName = 1 << 4
};

const AirTurnPeripheralFeaturesAvailable advancedFeatures = AirTurnPeripheralFeaturesAvailableOSKeyRepeatConfiguration | AirTurnPeripheralFeaturesAvailableConnectionSpeedConfiguration;

@class AirTurnUIAdvancedSettingsController;

@protocol AirTurnUIAdvancedSettingsControllerDelegate <NSObject>

@required

- (void)advancedSettingsControllerDidUpdateDeviceName:(AirTurnUIAdvancedSettingsController *)controller;

- (void)advancedSettingsControllerDidUpdateKeyRepeatMode:(AirTurnUIAdvancedSettingsController *)controller;

- (void)advancedSettingsControllerDidUpdateFastResponseEnabled:(AirTurnUIAdvancedSettingsController *)controller;

@end

@interface AirTurnUIAdvancedSettingsController : UITableViewController <UITextFieldDelegate>

@property(nonatomic, weak) id <AirTurnUIAdvancedSettingsControllerDelegate> delegate;

@property(nonatomic, strong) NSString *deviceName;
@property(nonatomic, strong) NSString *defaultDeviceName;

@property(nonatomic, strong) UITableViewCell *deviceNameCell;
@property(nonatomic, strong) UITextField *deviceNameTextField;

@property(nonatomic, assign) BOOL keyRepeatEnabled;
@property(nonatomic, assign) BOOL isOSKeyRepeat;

@property(nonatomic, assign) BOOL fastResponseEnabled;

@end

@implementation AirTurnUIAdvancedSettingsController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.deviceNameTextField = [[UITextField alloc] init];
        self.deviceNameTextField.borderStyle = UITextBorderStyleNone;
        self.deviceNameTextField.clearButtonMode = UITextFieldViewModeAlways;
        self.deviceNameTextField.delegate = self;
        self.deviceNameTextField.returnKeyType = UIReturnKeyDone;
        self.deviceNameTextField.keyboardType = UIKeyboardTypeASCIICapable;
        self.deviceNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
        self.deviceNameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [self.deviceNameCell.contentView addSubview:self.deviceNameTextField];
        [self.deviceNameCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[tf]-15-|" options:0 metrics:nil views:@{@"tf":self.deviceNameTextField}]];
        [self.deviceNameCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.deviceNameCell.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.deviceNameTextField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        self.deviceNameCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDefaultDeviceName:(NSString *)defaultDeviceName {
    self.deviceNameTextField.placeholder = defaultDeviceName;
}

- (void)setDeviceName:(NSString *)deviceName {
    self.deviceNameTextField.text = deviceName;
}

- (NSString *)deviceName {
    return self.deviceNameTextField.text;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return string.length - range.length + textField.text.length <= AirTurnPeripheralMaxDeviceNameLength;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.delegate advancedSettingsControllerDidUpdateDeviceName:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.deviceNameTextField resignFirstResponder];
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _keyRepeatEnabled ? 3 : 2;
}

- (NSUInteger)codeSectionForRealSection:(NSUInteger)section {
    if(!_keyRepeatEnabled && section >= 1) {
        return section + 1;
    }
    return section;
}

- (NSUInteger)realSectionForCodeSection:(NSUInteger)section {
    return section + section - [self codeSectionForRealSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch ([self codeSectionForRealSection:section]) {
        case 0: return AirTurnUILocalizedString(@"Device name", @"Device name section heading");
        case 1: return AirTurnUILocalizedString(@"Key repeat mode", @"Key repeat mode section heading");
        case 2: return AirTurnUILocalizedString(@"Connection speed", @"Connection speed section heading");
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch ([self codeSectionForRealSection:section]) {
        case 1: return AirTurnUILocalizedString(@"By default, PED uses your configured key repeat settings in modes 2-5. Alternatively, you can use the key repeat settings configured on the Operating System. This will disable key repeat for mode 1", @"Key repeat mode description");
        case 2: return AirTurnUILocalizedString(@"By default, PED reduces its connection speed to conserve battery power. Alternatively you can increase the connection speed so pedal presses are more responsive", @"Connection speed description");
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [self codeSectionForRealSection:indexPath.section];
    UITableViewCell *c = nil;
    switch (section) {
        case 0:
            return self.deviceNameCell;
        case 1:
            c = [tableView dequeueReusableCellWithIdentifier:@"keyRepeat"];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"keyRepeat"];
            }
            switch (indexPath.row) {
                case 0:
                    c.textLabel.text = NSLocalizedString(@"PED key repeat", @"PED key repeat setting cell");
                    c.accessoryType = _isOSKeyRepeat ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    break;
                case 1:
                    c.textLabel.text = NSLocalizedString(@"OS key repeat", @"OS key repeat setting cell");
                    c.accessoryType = _isOSKeyRepeat ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
            }
            break;
        case 2:
            c = [tableView dequeueReusableCellWithIdentifier:@"connectionSpeed"];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"connectionSpeed"];
            }
            switch (indexPath.row) {
                case 0:
                    c.textLabel.text = NSLocalizedString(@"Low power mode", @"Low power setting cell");
                    c.accessoryType = _fastResponseEnabled ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    break;
                case 1:
                    c.textLabel.text = NSLocalizedString(@"Fast response", @"Fast response setting cell");
                    c.accessoryType = _fastResponseEnabled ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
            }
            break;
    }
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = [self codeSectionForRealSection:indexPath.section];
    switch (section) {
        case 1:
            self.isOSKeyRepeat = indexPath.row == 1;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.delegate advancedSettingsControllerDidUpdateKeyRepeatMode:self];
            break;
        case 2:
            self.fastResponseEnabled = indexPath.row == 1;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.delegate advancedSettingsControllerDidUpdateFastResponseEnabled:self];
            break;
    }
}

@end

@interface AirTurnUIPeripheralController () <AirTurnUIAdvancedSettingsControllerDelegate
>

@property(nonatomic, strong) AirTurnPeripheral *peripheral;

@property(nonatomic, assign) BOOL keyRepeatEnabled;

@property(nonatomic, strong) AirTurnUIAdvancedSettingsController *advancedSettingsController;

@property(nonatomic, assign) BOOL deviceValues;
@property(nonatomic, assign) BOOL defaultValues;
@property(nonatomic, assign) AirTurnPeripheralWriteProgress writeProgress;

@property(nonatomic, readonly) BOOL showAdvanced;

@property(nonatomic, strong) NSArray *idlePowerOffValueMapping;

@property(nonatomic, strong) UITableViewCell * keyRepeatToggleCell;
@property(nonatomic, strong) UITableViewCell * delayBRCell;
@property(nonatomic, strong) UITableViewCell * repeatRateCell;
@property(nonatomic, strong) UITableViewCell * idlePowerOffCell;

@property(nonatomic, strong) UISlider *delayBRSlider;
@property(nonatomic, strong) UISlider *repeatRateSlider;
@property(nonatomic, strong) UISlider *idlePowerOffSlider;

@property(nonatomic, strong) UILabel *delayBRLabel;
@property(nonatomic, strong) UILabel *repeatRateLabel;
@property(nonatomic, strong) UILabel *idlePowerOffLabel;

@property(nonatomic, strong) UILabel *delayBRValue;
@property(nonatomic, strong) UILabel *repeatRateValue;
@property(nonatomic, strong) UILabel *idlePowerOffValue;

@property(nonatomic, strong) NSNumberFormatter *valueFormatter;

@property(nonatomic, readonly) BOOL isProgramming;

@end

@implementation AirTurnUIPeripheralController

- (id)initWithPeripheral:(AirTurnPeripheral *)peripheral {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.peripheral = peripheral;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(peripheralEncounteredError:) name:AirTurnEncounteredErrorNotification object:peripheral];
        [nc addObserver:self selector:@selector(peripheralWriteComplete:) name:AirTurnWriteCompleteNotification object:peripheral];
        [nc addObserver:self selector:@selector(peripheralDidUpdateName:) name:AirTurnDidUpdateNameNotification object:peripheral];
        
        self.navigationItem.title = peripheral.name;
        
        self.advancedSettingsController = [[AirTurnUIAdvancedSettingsController alloc] initWithStyle:UITableViewStyleGrouped];
        self.advancedSettingsController.delegate = self;
        self.advancedSettingsController.navigationItem.title = AirTurnUILocalizedString(@"Advanced", @"Advanced settings nav title");
        self.advancedSettingsController.defaultDeviceName = self.peripheral.defaultName;
        
        self.keyRepeatToggleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        self.keyRepeatToggleCell.textLabel.text = AirTurnUILocalizedString(@"Auto-repeat", @"String to toggle the key repeat");
        
        // key repeat is enabled if delay br and repeat rate are both non-zero.  Set opposite value to ensure setter runs first time.
        _keyRepeatEnabled = !self.peripheral.keyRepeatEnabled;
        
        self.valueFormatter = [[NSNumberFormatter alloc] init];
        self.valueFormatter.usesSignificantDigits = YES;
        self.valueFormatter.minimumSignificantDigits = 2;
        self.valueFormatter.maximumSignificantDigits = 2;
        
        NSDictionary *insets = @{@"insetLeft":@(15), @"insetRight":@(15), @"insetTop":@(10), @"insetBottom":@(10)};
        
        {
            self.delayBRCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.delayBRCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            self.delayBRLabel = [[UILabel alloc] init];
            self.delayBRLabel.text = AirTurnUILocalizedString(@"Delay before repeat", nil);
            self.delayBRLabel.font = self.delayBRCell.textLabel.font;
            self.delayBRLabel.textAlignment = NSTextAlignmentLeft;
            [self.delayBRLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            self.delayBRValue = [[UILabel alloc] init];
            self.delayBRValue.font = self.delayBRCell.detailTextLabel.font;
            self.delayBRValue.textColor = [UIColor grayColor];
            self.delayBRValue.textAlignment = NSTextAlignmentRight;
            [self.delayBRValue setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            self.delayBRSlider = [[UISlider alloc] initWithFrame:CGRectZero];
            self.delayBRSlider.minimumValue = 30;
            self.delayBRSlider.maximumValue =  191;
            [self.delayBRSlider addTarget:self action:@selector(delayBRSliderChanged:) forControlEvents:UIControlEventValueChanged];
            [self.delayBRSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [self.delayBRCell.contentView addSubview:self.delayBRLabel];
            [self.delayBRCell.contentView addSubview:self.delayBRValue];
            [self.delayBRCell.contentView addSubview:self.delayBRSlider];
            
            NSDictionary *d =@{@"tl":self.delayBRLabel, @"dl":self.delayBRValue, @"sl":self.delayBRSlider};
            [self.delayBRCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insetLeft)-[tl]->=0-[dl]-(insetRight)-|" options:NSLayoutFormatAlignAllBaseline metrics:insets views:d]];
            [self.delayBRCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(insetTop)-[tl]->=0-[sl]-(insetBottom)-|" options:0 metrics:insets views:d]];
            [self.delayBRCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insetLeft)-[sl]-(insetRight)-|" options:0 metrics:insets views:d]];
        }
        {
            self.repeatRateCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.repeatRateCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            self.repeatRateLabel = [[UILabel alloc] init];
            self.repeatRateLabel.text = AirTurnUILocalizedString(@"Repeat rate", nil);
            self.repeatRateLabel.font = self.repeatRateCell.textLabel.font;
            self.repeatRateLabel.textAlignment = NSTextAlignmentLeft;
            [self.repeatRateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            self.repeatRateValue = [[UILabel alloc] init];
            self.repeatRateValue.font = self.repeatRateCell.detailTextLabel.font;
            self.repeatRateValue.textColor = [UIColor grayColor];
            self.repeatRateValue.textAlignment = NSTextAlignmentRight;
            [self.repeatRateValue setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            self.repeatRateSlider = [[UISlider alloc] initWithFrame:CGRectZero];
            self.repeatRateSlider.minimumValue = 4;
            self.repeatRateSlider.maximumValue = 40;
            [self.repeatRateSlider addTarget:self action:@selector(repeatRateSliderChanged:) forControlEvents:UIControlEventValueChanged];
            [self.repeatRateSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [self.repeatRateCell.contentView addSubview:self.repeatRateLabel];
            [self.repeatRateCell.contentView addSubview:self.repeatRateValue];
            [self.repeatRateCell.contentView addSubview:self.repeatRateSlider];
            
            NSDictionary *d =@{@"tl":self.repeatRateLabel, @"dl":self.repeatRateValue, @"sl":self.repeatRateSlider};
            [self.repeatRateCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insetLeft)-[tl]->=0-[dl]-(insetRight)-|" options:NSLayoutFormatAlignAllBaseline metrics:insets views:d]];
            [self.repeatRateCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(insetTop)-[tl]->=0-[sl]-(insetBottom)-|" options:0 metrics:insets views:d]];
            [self.repeatRateCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insetLeft)-[sl]-(insetRight)-|" options:0 metrics:insets views:d]];
        }
        {
            self.idlePowerOffValueMapping = @[@300, @900, @3600, @7200, @18000, @0];
            self.idlePowerOffCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.idlePowerOffCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            self.idlePowerOffLabel = [[UILabel alloc] init];
            self.idlePowerOffLabel.text = AirTurnUILocalizedString(@"Power off when idle", nil);
            self.idlePowerOffLabel.font = self.idlePowerOffCell.textLabel.font;
            self.idlePowerOffLabel.textAlignment = NSTextAlignmentLeft;
            [self.idlePowerOffLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            self.idlePowerOffValue = [[UILabel alloc] init];
            self.idlePowerOffValue.font = self.idlePowerOffCell.detailTextLabel.font;
            self.idlePowerOffValue.textColor = [UIColor grayColor];
            self.idlePowerOffValue.textAlignment = NSTextAlignmentRight;
            [self.idlePowerOffValue setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            self.idlePowerOffSlider = [[UISlider alloc] initWithFrame:CGRectZero];
            self.idlePowerOffSlider.minimumValue = 0;
            self.idlePowerOffSlider.maximumValue = 5;
            [self.idlePowerOffSlider addTarget:self action:@selector(idlePowerOffSliderChanged:) forControlEvents:UIControlEventValueChanged];
            [self.idlePowerOffSlider addTarget:self action:@selector(idlePowerOffSliderTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
            [self.idlePowerOffSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [self.idlePowerOffCell.contentView addSubview:self.idlePowerOffLabel];
            [self.idlePowerOffCell.contentView addSubview:self.idlePowerOffValue];
            [self.idlePowerOffCell.contentView addSubview:self.idlePowerOffSlider];
            
            NSDictionary *d =@{@"tl":self.idlePowerOffLabel, @"dl":self.idlePowerOffValue, @"sl":self.idlePowerOffSlider};
            [self.idlePowerOffCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insetLeft)-[tl]->=0-[dl]-(insetRight)-|" options:NSLayoutFormatAlignAllBaseline metrics:insets views:d]];
            [self.idlePowerOffCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(insetTop)-[tl]->=0-[sl]-(insetBottom)-|" options:0 metrics:insets views:d]];
            [self.idlePowerOffCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insetLeft)-[sl]-(insetRight)-|" options:0 metrics:insets views:d]];
        }
        [self resetToDeviceValues];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    @throw([NSException exceptionWithName:@"AirTurnInvalidInit" reason:@"Please use -initWithPeripheral:" userInfo:nil]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    @throw([NSException exceptionWithName:@"AirTurnInvalidInit" reason:@"Please don't use this class in interface builder" userInfo:nil]);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentSize"]) {
        CGSize size = [self preferredContentSize];
        size.height = self.tableView.contentSize.height;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)showAdvanced {
    return (self.peripheral.featuresAvailable & advancedFeatures) == advancedFeatures;
}

- (void)allSlidersChanged {
    [self delayBRSliderChanged:self.delayBRSlider];
    [self repeatRateSliderChanged:self.repeatRateSlider];
    [self idlePowerOffSliderChanged:self.idlePowerOffSlider];
}

- (void)resetToDeviceValues {
    // before keyRepeatEnabled as setter uses these values
    self.advancedSettingsController.keyRepeatEnabled = self.peripheral.keyRepeatEnabled;
    self.advancedSettingsController.isOSKeyRepeat = self.peripheral.OSKeyRepeat;
    
    self.keyRepeatEnabled = self.peripheral.keyRepeatEnabled;
    self.delayBRSlider.value = self.keyRepeatEnabled ? self.peripheral.delayBeforeRepeatMultiplier : AirTurnPeripheralDefaultDelayBeforeRepeat;
    self.repeatRateSlider.value = self.keyRepeatEnabled ? self.peripheral.repeatRateDivisor : AirTurnPeripheralDefaultKeyRepeatRate;
    self.idlePowerOffSlider.value = [self getClosestPowerOffIndexToValue:self.peripheral.idlePowerOff];
    self.advancedSettingsController.deviceName = self.peripheral.name;
    self.advancedSettingsController.fastResponseEnabled = self.peripheral.connectionConfiguration == AirTurnPeripheralConnectionConfigurationLowLatency;
   
    [self allSlidersChanged];
    [self valueChanged];
}

- (void)resetToDefaultValues {
    self.keyRepeatEnabled = AirTurnPeripheralDefaultKeyRepeatEnabled;
    self.delayBRSlider.value = AirTurnPeripheralDefaultDelayBeforeRepeat;
    self.repeatRateSlider.value = AirTurnPeripheralDefaultKeyRepeatRate;
    self.idlePowerOffSlider.value = [self getClosestPowerOffIndexToValue:AirTurnPeripheralDefaultIdlePowerOff];
    self.advancedSettingsController.deviceName = self.peripheral.defaultName;
    self.advancedSettingsController.keyRepeatEnabled = AirTurnPeripheralDefaultKeyRepeatEnabled;
    self.advancedSettingsController.isOSKeyRepeat = AirTurnPeripheralDefaultOSKeyRepeatEnabled;
    self.advancedSettingsController.fastResponseEnabled = AirTurnPeripheralDefaultConnectionConfiguration == AirTurnPeripheralConnectionConfigurationLowLatency;
    [self allSlidersChanged];
    [self valueChanged];
}

- (BOOL)isKeyRepeatDeviceValue {
    if(self.keyRepeatEnabled) {
        if(self.advancedSettingsController.isOSKeyRepeat) {
            return self.peripheral.delayBeforeRepeatMultiplier == 0 && self.peripheral.repeatRateDivisor == 1;
        } else {
            return self.peripheral.delayBeforeRepeatMultiplier == self.delayBRSlider.value && self.peripheral.repeatRateDivisor == self.repeatRateSlider.value;
        }
    }
    return self.peripheral.delayBeforeRepeatMultiplier == 0 && self.peripheral.repeatRateDivisor == 0;
}

- (BOOL)isIdlePowerOffDeviceValue {
    return self.idlePowerOffSlider.value == [self getClosestPowerOffIndexToValue:self.peripheral.idlePowerOff];
}

- (BOOL)isConnectionControlDeviceValue {
    if (self.advancedSettingsController.fastResponseEnabled) {
        return self.peripheral.connectionConfiguration == AirTurnPeripheralConnectionConfigurationLowLatency;
    }
    return self.peripheral.connectionConfiguration == AirTurnPeripheralConnectionConfigurationLowPower;
}

- (BOOL)isDeviceNameDeviceValue {
    return [self.advancedSettingsController.deviceName isEqual:self.peripheral.name];
}

- (BOOL)isDeviceValues {
    return [self isKeyRepeatDeviceValue] && [self isIdlePowerOffDeviceValue] && (![self showAdvanced] || ([self isConnectionControlDeviceValue] && [self isDeviceNameDeviceValue]));
}

- (BOOL)isDefaultValues {
    return
        self.keyRepeatEnabled == AirTurnPeripheralDefaultKeyRepeatEnabled &&
        self.advancedSettingsController.isOSKeyRepeat == AirTurnPeripheralDefaultOSKeyRepeatEnabled &&
        ((!self.keyRepeatEnabled && !self.advancedSettingsController.isOSKeyRepeat) || // if key repeat sliders not enabled, we don't care if the other values match
         (self.delayBRSlider.value == AirTurnPeripheralDefaultDelayBeforeRepeat &&
          self.repeatRateSlider.value == AirTurnPeripheralDefaultKeyRepeatRate)) &&
        self.idlePowerOffSlider.value == [self getClosestPowerOffIndexToValue:AirTurnPeripheralDefaultIdlePowerOff] &&
        !self.advancedSettingsController.fastResponseEnabled &&
        (self.peripheral.defaultName == nil || [self.advancedSettingsController.deviceName isEqualToString:(NSString * _Nonnull)self.peripheral.defaultName]);
}

- (void)valueChanged {
    _deviceValues = [self isDeviceValues];
    _defaultValues = [self isDefaultValues];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self realSectionForCodeSection:SECTION_BUTTONS]] withRowAnimation:UITableViewRowAnimationNone];
}

- (AirTurnPeripheralWriteProgress)requiredWriteTasks {
    AirTurnPeripheralWriteProgress tasks = 0;
    if(![self isKeyRepeatDeviceValue]) {
        tasks |= AirTurnPeripheralWriteProgressDelayBeforeRepeat | AirTurnPeripheralWriteProgressRepeatRate;
    }
    if(![self isIdlePowerOffDeviceValue]) {
        tasks |= AirTurnPeripheralWriteProgressIdlePowerOff;
    }
    if(![self isConnectionControlDeviceValue]) {
        tasks |= AirTurnPeripheralWriteProgressConnectionConfiguration;
    }
    if(![self isDeviceNameDeviceValue]) {
        tasks |= AirTurnPeripheralWriteProgressDeviceName;
    }
    return tasks;
}

- (BOOL)isProgramming {
    return _writeProgress > 0;
}

- (void)programmingStart {
    _writeProgress = [self requiredWriteTasks];
    if(_writeProgress & AirTurnPeripheralWriteProgressDelayBeforeRepeat) {
        [self.peripheral writeDelayBeforeRepeat:self.keyRepeatEnabled && !self.advancedSettingsController.isOSKeyRepeat ? (uint8_t)self.delayBRSlider.value : 0];
    }
    if(_writeProgress & AirTurnPeripheralWriteProgressRepeatRate) {
        [self.peripheral writeRepeatRate:self.keyRepeatEnabled && !self.advancedSettingsController.isOSKeyRepeat ? (uint8_t)self.repeatRateSlider.value : (self.advancedSettingsController.isOSKeyRepeat ? 1 : 0)];
    }
    if(_writeProgress & AirTurnPeripheralWriteProgressIdlePowerOff) {
        uint16_t newPowerOffValue = [self.idlePowerOffValueMapping[(NSUInteger)self.idlePowerOffSlider.value] shortValue];
        [self.peripheral writeIdlePowerOff:newPowerOffValue];
    }
    if(_writeProgress & AirTurnPeripheralWriteProgressConnectionConfiguration) {
        [self.peripheral writeConnectionConfiguration:self.advancedSettingsController.fastResponseEnabled ? AirTurnPeripheralConnectionConfigurationLowLatency : AirTurnPeripheralConnectionConfigurationLowPower];
    }
    if(_writeProgress & AirTurnPeripheralWriteProgressDeviceName) {
        [self.peripheral storeDeviceName:self.advancedSettingsController.deviceName];
        _writeProgress ^= AirTurnPeripheralWriteProgressDeviceName;
    }
    if(_writeProgress == 0) {
        [self programmingComplete];
    } else {
        [self.tableView reloadData];
    }
}

- (void)programmingComplete {
    _deviceValues = YES;
    [self.tableView reloadData];
}

#pragma mark Accessors

- (void)setKeyRepeatEnabled:(BOOL)keyRepeatEnabled {
    if(_keyRepeatEnabled == keyRepeatEnabled) return;
    _keyRepeatEnabled = keyRepeatEnabled;
    if(!self.advancedSettingsController.isOSKeyRepeat) {
        NSUInteger section = [self realSectionForCodeSection:SECTION_PROGRAMMING];
        NSArray *indexes = @[[NSIndexPath indexPathForRow:1 inSection:section], [NSIndexPath indexPathForRow:2 inSection:section]];
        if(keyRepeatEnabled) {
            [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    self.keyRepeatToggleCell.accessoryType = keyRepeatEnabled ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.advancedSettingsController.keyRepeatEnabled = keyRepeatEnabled;
    [self valueChanged];
}

- (BOOL)isUpdatingOrProgramming {
    return self.isProgramming;
}

#pragma mark Actions

- (void)delayBRSliderChanged:(UISlider *)sender {
    sender.value = roundf(sender.value);
    double val = AirTurnPeripheralMaxDelayBeforeRepeatSeconds * sender.value / UINT8_MAX;
    self.delayBRValue.text = [[self.valueFormatter stringFromNumber:@(val)] stringByAppendingString:@"s"];
    if(_deviceValues || _defaultValues)
        [self valueChanged];
}

- (void)repeatRateSliderChanged:(UISlider *)sender {
    sender.value = roundf(sender.value);
    double val = sender.value / AirTurnPeripheralMaxRepeatRateSeconds;
    self.repeatRateValue.text = [[self.valueFormatter stringFromNumber:@(val)] stringByAppendingString:@"/s"];
    if(_deviceValues || _defaultValues)
        [self valueChanged];
}

- (void)idlePowerOffSliderChanged:(UISlider *)sender {
    NSString *valueLabel;
    
    switch((int)roundf(sender.value)) {
        case 0: valueLabel = AirTurnUILocalizedString(@"5 minutes", @"Time interval before automatic power off - 5 min"); break;
        case 1: valueLabel = AirTurnUILocalizedString(@"15 minutes", @"Time interval before automatic power off - 15 min"); break;
        case 2: valueLabel = AirTurnUILocalizedString(@"1 hour", @"Time interval before automatic power off - 1 hour"); break;
        case 3: valueLabel = AirTurnUILocalizedString(@"2 hours", @"Time interval before automatic power off - 2 hours"); break;
        case 4: valueLabel = AirTurnUILocalizedString(@"5 hours", @"Time interval before automatic power off - 5 hours"); break;
        case 5: valueLabel = AirTurnUILocalizedString(@"Never", @"Time interval before automatic power off - never"); break;
    }
    self.idlePowerOffValue.text = valueLabel;
    if(_deviceValues || _defaultValues)
        [self valueChanged];
}

- (void)idlePowerOffSliderTouchUp:(UISlider *)sender {
    int newVal = (int)roundf(sender.value);
    [sender setValue:(float)newVal animated:YES];
}

- (NSUInteger)getClosestPowerOffIndexToValue:(uint16_t)powerOff {
    NSUInteger index = [self.idlePowerOffValueMapping indexOfObject:@(powerOff)];
    if(index != NSNotFound)  return index;
    if(powerOff < [self.idlePowerOffValueMapping[0] integerValue]) {
        return 0;
    } else {
        for(NSUInteger i = 1; i <= 3; i++) {
            int next = [self.idlePowerOffValueMapping[i+1] intValue];
            int current = [self.idlePowerOffValueMapping[i] intValue];
            if(powerOff > next) continue;
            // it's in this range, find out if it's over half way through
            return ((powerOff - current)/(next - current)) < 0.5 ? i : i+1;
        }
        return 4; // over 5 hours
    }
}

#pragma mark - Table view data source

- (NSUInteger)codeSectionForRealSection:(NSUInteger)section {
    if(self.peripheral.connectionState == AirTurnConnectionStateConnected && ![self showAdvanced] && section >= SECTION_ADVANCED) {
        return section + 1;
    }
    return section;
}

- (NSUInteger)realSectionForCodeSection:(NSUInteger)section {
    return section + section - [self codeSectionForRealSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.peripheral.connectionState == AirTurnConnectionStateConnected) {
        if([self showAdvanced]) {
            return SECTION_BUTTONS + 1;
        }
        return SECTION_BUTTONS;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch([self codeSectionForRealSection:section]) {
        case SECTION_FORGET:
            return AirTurnUILocalizedString(@"Forgetting an AirTurn stops the App automatically connecting", @"Forget footer text");
        case SECTION_BUTTONS:
            return [NSString stringWithFormat:@"F: %@  H: %@", self.peripheral.firmwareVersion, self.peripheral.hardwareVersion];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if([view isKindOfClass:[UITableViewHeaderFooterView class]] && [self codeSectionForRealSection:section] == SECTION_BUTTONS){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch ([self codeSectionForRealSection:section]) {
        case SECTION_FORGET:
            return 30;
        case SECTION_BUTTONS:
            return 50;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch([self codeSectionForRealSection:section]) {
        case SECTION_PROGRAMMING:
            return AirTurnUILocalizedString(@"Settings", @"Programming section header");
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch([self codeSectionForRealSection:section]) {
        case SECTION_FORGET:
            return 1;
        case SECTION_PROGRAMMING:
            return self.keyRepeatEnabled && !self.advancedSettingsController.isOSKeyRepeat ? 4 : 2;
        case SECTION_ADVANCED:
            return 1;
        case SECTION_BUTTONS:
            return 3;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch([self codeSectionForRealSection:indexPath.section]) {
        case SECTION_PROGRAMMING:
            if(indexPath.row > 0) {
                return 88;
            }
            break;
    }
    return self.tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *c;
    NSString *reuseID;
    switch([self codeSectionForRealSection:indexPath.section]) {
        case SECTION_FORGET: // forget cell
            reuseID = @"forget";
            c = [self.tableView dequeueReusableCellWithIdentifier:reuseID];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
                c.textLabel.text = AirTurnUILocalizedString(@"Forget AirTurn", nil);
            }
            if([self isUpdatingOrProgramming]) {
                c.textLabel.textColor = [UIColor grayColor];
                c.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                c.textLabel.textColor = BlueCellColor;
                c.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            return c;
        case SECTION_PROGRAMMING: {
            BOOL enabled = [self isUpdatingOrProgramming];
            NSInteger computedRow = indexPath.row;
            if((!self.keyRepeatEnabled || self.advancedSettingsController.isOSKeyRepeat) && computedRow > 0) {
                computedRow = 3;
            }
            switch (computedRow) {
                case 0: // enable key repeat
                    if(enabled) {
                        self.keyRepeatToggleCell.tintColor = [UIColor lightGrayColor];
                        self.keyRepeatToggleCell.textLabel.enabled = NO;
                    } else {
                        self.keyRepeatToggleCell.tintColor = nil;
                        self.keyRepeatToggleCell.textLabel.enabled = YES;
                    }
                    return self.keyRepeatToggleCell;
                case 1: // delay br slider
                    self.delayBRSlider.enabled = self.delayBRLabel.enabled = !enabled;
                    self.delayBRSlider.tintColor = enabled ? [UIColor lightGrayColor] : nil;
                    return self.delayBRCell;
                case 2: // key repeat slider
                    self.repeatRateSlider.enabled = self.repeatRateLabel.enabled = !enabled;
                    self.repeatRateSlider.tintColor = enabled ? [UIColor lightGrayColor] : nil;
                    return self.repeatRateCell;
                case 3: // idle power off slider
                    self.idlePowerOffSlider.enabled = self.idlePowerOffLabel.enabled = !enabled;
                    self.idlePowerOffSlider.tintColor = enabled ? [UIColor lightGrayColor] : nil;
                    return self.idlePowerOffCell;
            }
        } break;
        case SECTION_ADVANCED:
            reuseID = @"advanced";
            c = [tableView dequeueReusableCellWithIdentifier:reuseID];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
                c.textLabel.text = AirTurnUILocalizedString(@"Advanced", @"Advanced table view cell");
                c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            if([self isUpdatingOrProgramming]) {
                c.textLabel.textColor = [UIColor grayColor];
                c.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                c.textLabel.textColor = [UIColor blackColor];
                c.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            break;
        case SECTION_BUTTONS:
            switch (indexPath.row) {
                case 0: {// write data cell
                    reuseID = @"writeData";
                    c = [self.tableView dequeueReusableCellWithIdentifier:reuseID];
                    if(!c) {
                        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
                        c.textLabel.text = AirTurnUILocalizedString(@"Save to AirTurn", nil);
                        c.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    }
                    UIActivityIndicatorView *ai = (UIActivityIndicatorView *)c.accessoryView;
                    if(self.isProgramming) {
                        [ai startAnimating];
                    } else {
                        [ai stopAnimating];
                    }
                    break;
                }
                case 1: // reset cell
                    reuseID = @"reset";
                    c = [self.tableView dequeueReusableCellWithIdentifier:reuseID];
                    if(!c) {
                        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
                        c.textLabel.text = AirTurnUILocalizedString(@"Reset changes", nil);
                    }
                    break;
                case 2: // Reset to default
                    reuseID = @"resetDefault";
                    c = [self.tableView dequeueReusableCellWithIdentifier:reuseID];
                    if(!c) {
                        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
                        c.textLabel.text = AirTurnUILocalizedString(@"Reset to default", nil);
                    }
                    break;
            }
            if((indexPath.row == 2 && [self isDefaultValues]) || (indexPath.row < 2 && _deviceValues) || [self isUpdatingOrProgramming]) {
                c.selectionStyle = UITableViewCellSelectionStyleNone;
                c.textLabel.textColor = [UIColor grayColor];
            } else {
                c.selectionStyle = UITableViewCellSelectionStyleDefault;
                c.textLabel.textColor = BlueCellColor;
            }
            
            return c;
    }
    
    return c;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(![self isUpdatingOrProgramming]) {
        switch([self codeSectionForRealSection:indexPath.section]) {
            case SECTION_FORGET: // forget
                [[AirTurnCentral sharedCentral] forgetAirTurn:self.peripheral];
                if(self.navigationController.topViewController == self) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                break;
            case SECTION_PROGRAMMING:
                switch(indexPath.row) {
                    case 0: // toggle key repeat
                        self.keyRepeatEnabled = !self.keyRepeatEnabled;
                        break;
                }
                break;
            case SECTION_ADVANCED:
                [self.navigationController pushViewController:self.advancedSettingsController animated:YES];
                break;
            case SECTION_BUTTONS:
                switch (indexPath.row) {
                    case 0: // write to device
                        if(!_deviceValues) {
                            [self programmingStart];
                        }
                        break;
                    case 1: // reset
                        if(!_deviceValues) {
                            [self resetToDeviceValues];
                        }
                        break;
                    case 2: // reset to default
                        if(![self isDefaultValues]) {
                            [self resetToDefaultValues];
                        }
                        break;
                }
                break;
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Peripheral delegate

- (void)peripheralEncounteredError:(NSNotification *)notification {
    NSError *error = notification.userInfo[AirTurnErrorKey];
    NSString *alertMessage = nil;
           if([error.domain isEqualToString:AirTurnErrorDomain]) {
        switch(error.code) {
            case AirTurnErrorUnhandled:
            case AirTurnErrorUnexpectedUnresolvable:
            case AirTurnErrorUnresolvablePeripheralError:
                alertMessage = AirTurnUILocalizedString(@"An unknown error occurred.  Please contact the developer if this continues.", @"Unknown error message");
                break;
            case AirTurnErrorConnectionTimedOut:
                alertMessage = AirTurnUILocalizedString(@"The connection to the AirTurn timed out", @"Connection Timed Out error message");
                break;
            case AirTurnErrorPeripheralNotPaired:
                alertMessage = AirTurnUILocalizedString(@"AirTurn requires pairing to connect.  Please tap \"Pair\" when requested", @"Pairing error message");
                break;
            case AirTurnErrorNotConnected:
            case AirTurnErrorPeripheralDisconnected:
                if(self.navigationController.topViewController == self) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                return;
            case AirTurnErrorOperationCancelled:
                break;
            case AirTurnErrorAttributeWriteFailedTryLater:
                alertMessage = self.isProgramming ? AirTurnUILocalizedString(@"Saving to AirTurn failed, please try again", @"Write failed error message") : AirTurnUILocalizedString(@"Updating AirTurn failed, please try again", @"Write failed error message");
                _writeProgress = 0;
                break;
        }
    } else {
        // unhandled error
        NSLog(@"Unhandled error: %@", error);
    }
    
    if(alertMessage)
        [[[UIAlertView alloc] initWithTitle:AirTurnUILocalizedString(@"AirTurn Error", @"AirTurn Error alert title") message:alertMessage delegate:nil cancelButtonTitle:AirTurnUILocalizedString(@"Ok", nil) otherButtonTitles:nil] show];
    [self.tableView reloadData];
}

- (void)markWriteProgressComplete:(AirTurnPeripheralWriteProgress)progress {
    _writeProgress &= (progress ^ 0xFFFF);
    if(_writeProgress == 0) {
        [self programmingComplete];
    }
}

- (void)peripheralWriteComplete:(NSNotification *)notification {
    AirTurnPeripheralWriteType type = [notification.userInfo[AirTurnWriteTypeKey] intValue];
    switch (type) {
        case AirTurnPeripheralWriteTypeDelayBeforeRepeat:
            [self markWriteProgressComplete:AirTurnPeripheralWriteProgressDelayBeforeRepeat];
            break;
        case AirTurnPeripheralWriteTypeRepeatRate:
            [self markWriteProgressComplete:AirTurnPeripheralWriteProgressRepeatRate];
            break;
        case AirTurnPeripheralWriteTypeIdlePowerOff:
            [self markWriteProgressComplete:AirTurnPeripheralWriteProgressIdlePowerOff];
            break;
        case AirTurnPeripheralWriteTypeConnectionConfiguration:
            [self markWriteProgressComplete:AirTurnPeripheralWriteProgressConnectionConfiguration];
            break;
        default:
            break;
    }
}

- (void)peripheralDidUpdateName:(NSNotification *)n {
    self.navigationItem.title = self.peripheral.name;
    self.advancedSettingsController.deviceName = self.peripheral.name;
}

#pragma mark Advanced Settings Delegate

- (void)advancedSettingsControllerDidUpdateDeviceName:(AirTurnUIAdvancedSettingsController *)controller {
    [self valueChanged];
}

- (void)advancedSettingsControllerDidUpdateFastResponseEnabled:(AirTurnUIAdvancedSettingsController *)controller {
    [self valueChanged];
}

- (void)advancedSettingsControllerDidUpdateKeyRepeatMode:(AirTurnUIAdvancedSettingsController *)controller {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self realSectionForCodeSection:SECTION_PROGRAMMING]] withRowAnimation:UITableViewRowAnimationNone];
    [self valueChanged];
}

@end
