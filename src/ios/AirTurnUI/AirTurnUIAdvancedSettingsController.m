//
//  AirTurnUIPeripheralAdvancedController.m
//  AirTurn
//
//  Created by Nick Brook on 21/11/2017.
//

#import "AirTurnUIAdvancedSettingsController.h"
#import "AirTurnUIPeripheralController.h" // for localised string macro

typedef NS_ENUM(NSUInteger, Section) {
    SectionDeviceName,
    SectionKeyRepeat,
    SectionConnectionSpeed,
    SectionPairingMethod,
	SectionDebounceTime,
};

const AirTurnPeripheralFeaturesAvailable advancedFeatures = AirTurnPeripheralFeaturesAvailableOSKeyRepeatConfiguration | AirTurnPeripheralFeaturesAvailableConnectionSpeedConfiguration;

AirTurnPeripheralDebounceTime DebounceTimeSliderMapping[] = {0, 10, 20, 30, 40, 50, 75, 100, 150, 200};
NSUInteger DebounceTimeSliderNumStops = sizeof(DebounceTimeSliderMapping) / sizeof(DebounceTimeSliderMapping[0]);

@interface AirTurnUIAdvancedSettingsController()

@property(nonatomic, strong) UITableViewCell *deviceNameCell;
@property(nonatomic, strong) UITextField *deviceNameTextField;

@property(nonatomic, assign) AirTurnPeripheralPairingMethod lastSetPairingMethod;

@end

@implementation AirTurnUIAdvancedSettingsController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = AirTurnUILocalizedString(@"Advanced", @"Advanced settings nav title");
        
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

- (void)setPairingMethod:(AirTurnPeripheralPairingMethod)pairingMethod {
    _pairingMethod = pairingMethod;
    _lastSetPairingMethod = pairingMethod;
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

- (BOOL)isVisible {
    return [self isViewLoaded] && self.view.window;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger ret = 2;
    if(_keyRepeatEnabled) {
        ret += 1;
    }
    if(_pairingMethodEnabled) {
        ret += 1;
    }
	if(_debounceTimeEnabled) {
		ret += 1;
	}
    return ret;
}

- (NSUInteger)codeSectionForRealSection:(NSUInteger)section {
    if(!_keyRepeatEnabled && section >= SectionKeyRepeat) {
        section += 1;
    }
    if(!_pairingMethodEnabled && section >= SectionPairingMethod) {
        section += 1;
    }
	if(!_debounceTimeEnabled && section >= SectionDebounceTime) {
		section += 1;
	}
    return section;
}

- (NSUInteger)realSectionForCodeSection:(NSUInteger)section {
    return section + section - [self codeSectionForRealSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch ([self codeSectionForRealSection:section]) {
        case SectionDeviceName: return AirTurnUILocalizedString(@"Device name", @"Device name section heading");
        case SectionKeyRepeat: return AirTurnUILocalizedString(@"Key repeat mode", @"Key repeat mode section heading");
        case SectionConnectionSpeed: return AirTurnUILocalizedString(@"Connection speed", @"Connection speed section heading");
        case SectionPairingMethod: return AirTurnUILocalizedString(@"Pairing Method", @"Pairing method section heading");
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch ([self codeSectionForRealSection:section]) {
        case SectionKeyRepeat: return AirTurnUILocalizedString(@"By default, AirTurn uses your configured key repeat settings in modes 2+. Alternatively you can use the key repeat settings configured on the Operating System (which will also disable key repeat for mode 1).", @"Key repeat mode description");
        case SectionConnectionSpeed: return AirTurnUILocalizedString(@"By default, AirTurn reduces its connection speed to conserve battery power. Alternatively you can increase the connection speed so pedal presses are more responsive", @"Connection speed description");
        case SectionPairingMethod: {
            NSString *currentMode;
            if(_lastSetPairingMethod == AirTurnPeripheralPairingMethodClosed) {
                currentMode = [NSString stringWithFormat:AirTurnUILocalizedString(@"Currently in Closed method with one pairing to this %@", @"current pairing method closed footer text"), UIDevice.currentDevice.model];
            } else {
                if(_pairingState == AirTurnPeripheralPairingStateNotPaired) {
                    if(_numberOfPairedDevices) {
                        if(_numberOfPairedDevices == 1) {
                            currentMode = [NSString stringWithFormat:AirTurnUILocalizedString(@"Currently in Open method, not paired to this %@, with one other pairing", @"current pairing method open not paired singular pairing footer text"), UIDevice.currentDevice.model];
                        } else { // several other pairings
                            currentMode = [NSString stringWithFormat:AirTurnUILocalizedString(@"Currently in Open method, not paired to this %@, with %d other pairings", @"current pairing method open not paired multiple pairings footer text"), UIDevice.currentDevice.model, _numberOfPairedDevices-1];
                        }
                    } else { // no other paired devices
                        currentMode = AirTurnUILocalizedString(@"Currently in Open method, not paired to any devices", @"current pairing method open not paired no pairings footer text");
                    }
                } else { // paired
                    if(_numberOfPairedDevices > 1) {
                        if(_numberOfPairedDevices == 2) {
                            currentMode = [NSString stringWithFormat:AirTurnUILocalizedString(@"Currently in Open method, paired to this %@, with one other pairing", @"current pairing method open paired singular pairing footer text"), UIDevice.currentDevice.model];
                        } else { // several other pairings
                            currentMode = [NSString stringWithFormat:AirTurnUILocalizedString(@"Currently in Open method, paired to this %@, with %d other pairings", @"current pairing method open paired multiple pairings footer text"), UIDevice.currentDevice.model, _numberOfPairedDevices-1];
                        }
                    } else { // no other paired devices
                        currentMode = [NSString stringWithFormat:AirTurnUILocalizedString(@"Currently in Open method, paired only to this %@", @"current pairing method open not paired no pairings footer text"), UIDevice.currentDevice.model];
                    }
                }
            }
            return [NSString stringWithFormat:AirTurnUILocalizedString(@"%@.\nIn Open method, pairing is only required in modes 2+ and the AirTurn can pair to up to 8 devices.\nIn Closed method, pairing is required in all modes, and pairing can only be made with one device.", @"Pairing methods description"), currentMode];
        } break;
		case SectionDebounceTime:
			return AirTurnUILocalizedString(@"Defines the time during which only one input event can occur. If you are experiencing multiple outputs being sent, try increasing this value. If your AirTurn is not responsive enough, try decreasing this value.", @"Description of debounce time property");
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	section = [self codeSectionForRealSection:section];
	switch (section) {
		case SectionDeviceName:
		case SectionDebounceTime:
			return 1;
		default:
			return 2;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [self codeSectionForRealSection:indexPath.section];
    UITableViewCell *c = nil;
    switch (section) {
        case SectionDeviceName:
            return self.deviceNameCell;
        case SectionKeyRepeat:
            c = [tableView dequeueReusableCellWithIdentifier:@"keyRepeat"];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"keyRepeat"];
            }
            switch (indexPath.row) {
                case 0:
                    c.textLabel.text = AirTurnUILocalizedString(@"AirTurn key repeat", @"AirTurn key repeat setting cell");
                    c.accessoryType = _isOSKeyRepeat ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    break;
                case 1:
                    c.textLabel.text = AirTurnUILocalizedString(@"OS key repeat", @"OS key repeat setting cell");
                    c.accessoryType = _isOSKeyRepeat ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
            }
            break;
        case SectionConnectionSpeed:
            c = [tableView dequeueReusableCellWithIdentifier:@"connectionSpeed"];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"connectionSpeed"];
            }
            switch (indexPath.row) {
                case 0:
                    c.textLabel.text = AirTurnUILocalizedString(@"Low power mode", @"Low power setting cell");
                    c.accessoryType = _fastResponseEnabled ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    break;
                case 1:
                    c.textLabel.text = AirTurnUILocalizedString(@"Fast response", @"Fast response setting cell");
                    c.accessoryType = _fastResponseEnabled ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
            }
            break;
        case SectionPairingMethod:
            switch (indexPath.row) {
                case 0:
                    c = [tableView dequeueReusableCellWithIdentifier:@"pairingMethodOpen"];
                    if(!c) {
                        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pairingMethodOpen"];
                        c.textLabel.text = AirTurnUILocalizedString(@"Open method", @"Open method setting cell");
                    }
                    c.accessoryType = _pairingMethod == AirTurnPeripheralPairingMethodClosed ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    break;
                case 1:
                    c = [tableView dequeueReusableCellWithIdentifier:@"pairingMethodClosed"];
                    if(!c) {
                        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pairingMethodClosed"];
                        c.textLabel.text = AirTurnUILocalizedString(@"Closed method", @"Closed method setting cell");
                    }
                    c.accessoryType = _pairingMethod == AirTurnPeripheralPairingMethodClosed ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
            }
            break;
		case SectionDebounceTime: {
			c = [tableView dequeueReusableCellWithIdentifier:@"debounceTime"];
			if(!c) {
				c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"debounceTime"];
				c.selectionStyle = UITableViewCellSelectionStyleNone;
				UILabel *titleLabel = [UILabel new];
				titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
				titleLabel.text = AirTurnUILocalizedString(@"Debounce time", @"Debounce time title");
				UILabel *valueLabel = [UILabel new];
				valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
				valueLabel.tag = 1;
				UISlider *slider = [UISlider new];
				slider.translatesAutoresizingMaskIntoConstraints = NO;
				slider.minimumValue = 0;
				
				slider.maximumValue = DebounceTimeSliderNumStops - 1;
				slider.tag = 2;
				[slider addTarget:self action:@selector(debounceTimeSliderChanged:) forControlEvents:UIControlEventValueChanged];
				
				[c.contentView addSubview:titleLabel];
				[c.contentView addSubview:valueLabel];
				[c.contentView addSubview:slider];
				[NSLayoutConstraint activateConstraints:@[
														  [c.contentView.layoutMarginsGuide.leftAnchor constraintEqualToAnchor:titleLabel.leftAnchor],
														  [c.contentView.layoutMarginsGuide.leftAnchor constraintEqualToAnchor:slider.leftAnchor],
														  [c.contentView.layoutMarginsGuide.rightAnchor constraintEqualToAnchor:valueLabel.rightAnchor],
														  [c.contentView.layoutMarginsGuide.rightAnchor constraintEqualToAnchor:slider.rightAnchor],
														  
														  [c.contentView.layoutMarginsGuide.topAnchor constraintEqualToAnchor:titleLabel.topAnchor],
														  [c.contentView.layoutMarginsGuide.topAnchor constraintEqualToAnchor:valueLabel.topAnchor],
														  [c.contentView.layoutMarginsGuide.bottomAnchor constraintEqualToAnchor:slider.bottomAnchor],
														  
														  [titleLabel.rightAnchor constraintLessThanOrEqualToAnchor:valueLabel.leftAnchor],
														  [slider.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8]
														  ]];
			}
			
			UILabel *valueLabel = [c.contentView viewWithTag:1];
			UISlider *slider = [c.contentView viewWithTag:2];
			NSUInteger i = 0;
			for (; i < DebounceTimeSliderNumStops; i++) {
				if(_debounceTime < DebounceTimeSliderMapping[i]) {
					slider.value = (i + i - 1) / 2;
					break;
				} else if(_debounceTime == DebounceTimeSliderMapping[i]) {
					slider.value = i;
					break;
				}
			}
			if(i == DebounceTimeSliderNumStops) {
				slider.value = i - 1;
			}
			valueLabel.text = [NSString stringWithFormat:@"%dms", _debounceTime];
			
		} break;
        default:
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            break;
    }
	if(c == nil) {
		c = [UITableViewCell new];
	}
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = [self codeSectionForRealSection:indexPath.section];
    switch (section) {
        case SectionKeyRepeat:
            self.isOSKeyRepeat = indexPath.row == 1;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.delegate advancedSettingsControllerDidUpdateKeyRepeatMode:self];
            break;
        case SectionConnectionSpeed:
            self.fastResponseEnabled = indexPath.row == 1;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.delegate advancedSettingsControllerDidUpdateFastResponseEnabled:self];
            break;
        case SectionPairingMethod: {
            void(^handler)(void) = ^(void) {
                // important not to go through setter
                self->_pairingMethod = indexPath.row == 0 ? AirTurnPeripheralPairingMethodOpen : AirTurnPeripheralPairingMethodClosed;
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.delegate advancedSettingsControllerDidUpdatePairingMethod:self];
            };
            uint8_t numPairingsToOtherDevices = _numberOfPairedDevices;
            if(_pairingState == AirTurnPeripheralPairingStatePaired && numPairingsToOtherDevices > 0) {
                numPairingsToOtherDevices--;
            }
            if(_lastSetPairingMethod == AirTurnPeripheralPairingMethodOpen && indexPath.row == 1 && numPairingsToOtherDevices > 0) {
                NSString * willPairWarning = _pairingState == AirTurnPeripheralPairingStatePaired ? @"" : AirTurnUILocalizedString(@"You will also be prompted to pair after saving this setting. ", @"Will pair warning if not paired and switching to closed");
                NSString *message = numPairingsToOtherDevices == 1 ?
					[NSString stringWithFormat:AirTurnUILocalizedString(@"Switching to Closed method will delete one other pairing the AirTurn has stored. %@Are you sure you want to do this?", @"Closed method alert message singular"), willPairWarning] :
					[NSString stringWithFormat:AirTurnUILocalizedString(@"Switching to Closed method will delete %d other pairings the AirTurn has with other devices. %@Are you sure you want to do this?", @"Closed method alert message plural"), numPairingsToOtherDevices, willPairWarning];
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:AirTurnUILocalizedString(@"Closed method", @"Closed method alert title") message:message preferredStyle:UIAlertControllerStyleAlert];
                [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"Cancel", @"Cancel alert button") style:UIAlertActionStyleCancel handler:nil]];
                [ac addAction:[UIAlertAction actionWithTitle:AirTurnUILocalizedString(@"Continue", @"Continue alert button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    handler();
                }]];
                [self presentViewController:ac animated:YES completion:nil];
            } else {
                handler();
            }
        } break;
    }
}

- (void)debounceTimeSliderChanged:(UISlider *)slider {
	float rounded = roundf(slider.value);
	if(rounded != slider.value) {
		slider.value = rounded;
	}
	if(_debounceTime != DebounceTimeSliderMapping[(int)rounded]) {
		_debounceTime = DebounceTimeSliderMapping[(int)rounded];
		UILabel *valueLabel = [slider.superview viewWithTag:1];
		valueLabel.text = _debounceTime == 0 ? AirTurnUILocalizedString(@"No debounce", @"No debounce value label") : [NSString stringWithFormat:@"%dms", _debounceTime];
		[self.delegate advancedSettingsControllerDidUpdateDebounceTime:self];
	}
}

@end

