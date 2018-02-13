//
//  Airturn.m
//  Cordova Airturn Plugin
//
//  Created by  mobilestart55555
//  Modified Henk Kelder
//

#define AirTurnPlayPauseiPod (1 && !TARGET_IPHONE_SIMULATOR)

#import <Cordova/CDVAvailability.h>
#import "AirTurn.h"
#import "CocoaLumberjack.h"
#import "AirTurnUIConnectionController.h"

#if AirTurnPlayPauseiPod
@import MediaPlayer;
#endif

static inline void throwWithName( NSError *error, NSString* name )
{
    if (error) {
        @throw [NSException exceptionWithName:name
                                       reason:error.debugDescription
                                     userInfo:@{ @"NSError" : error }];
    }
}

@interface AirTurn()

@property (retain) NSString* callbackId;

@end

@implementation AirTurn

- (void)dealloc
{

    for ( id observer in self.observerMap) {

        [[NSNotificationCenter defaultCenter] removeObserver:observer];

    }

    [_observerMap removeAllObjects];

    _observerMap = nil;

}

/*
 *  pluginInitialize
 */
- (void)pluginInitialize
{
}

- (void)onAppTerminate
{
    for ( id observer in self.observerMap) {

        [[NSNotificationCenter defaultCenter] removeObserver:observer];

    }

    [_observerMap removeAllObjects];

    _observerMap = nil;
}

-(NSMutableDictionary *)observerMap
{
    if (!_observerMap) {
        _observerMap = [[NSMutableDictionary alloc] initWithCapacity:100];
    }

    return _observerMap;
}

- (void)fireEvent:(NSString *)eventName data:(NSDictionary*)data
{
    if (!self.commandDelegate ) {
        return;
    }

    if (eventName == nil || [eventName length] == 0) {

        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"eventName is null or empty"
                                     userInfo:nil];

    }

    NSString *jsonDataString = @"{}";

    if( data  ) {

        NSError *error;
        NSDictionary *tmpData = data;
        if([eventName isEqualToString:@"AirTurnConnectionStateNotification"])
        {
            //AirTurnPeripheral *p = [data objectForKey:@"AirTurnPeripheralKey"];

            AirTurnPeripheral *p = data[AirTurnPeripheralKey];
            switch([data[AirTurnConnectionStateKey] intValue]) {
                case AirTurnConnectionStateReady:

                    [[NSUserDefaults standardUserDefaults] setObject:p.name forKey:@"PeripheralName"];
                    [[NSUserDefaults standardUserDefaults] setObject:p.identifier forKey:@"DeviceUniqueIdentifier"];
                    [[NSUserDefaults standardUserDefaults] setObject:p.firmwareVersion forKey:@"FirmwareVersion"];
                    [[NSUserDefaults standardUserDefaults] setObject:p.hardwareVersion forKey:@"HardwareVersion"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    break;
                default: break;
            }
            tmpData = @{
                        @"AirTurnConnectionStateKey":[data objectForKey:@"AirTurnConnectionStateKey"]
                        };
        }
        else if([eventName isEqualToString:@"AirTurnPedalPressNotification"])
        {
            tmpData = @{
                        @"AirTurnPortNumberKey":[data objectForKey:@"AirTurnPortNumberKey"]
                        };
        }

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpData
                                                           options:(NSJSONWritingOptions)0
                                                             error:&error];

        if (! jsonData) {

            throwWithName(error, @"JSON Serialization exception");
            return;

        }

        jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    }

    NSString *func = [NSString stringWithFormat:@"window.airturn.fireEvent('%@', %@);", eventName, jsonDataString];

    [self.commandDelegate evalJs:func];

}

- (void)getInfo:(CDVInvokedUrlCommand*)command
{
    NSString *name =  [[NSUserDefaults standardUserDefaults] stringForKey:@"PeripheralName"];
    NSString *identifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceUniqueIdentifier"];
    NSString *firmwareVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"FirmwareVersion"];
    NSString *hardwareVersion =[[NSUserDefaults standardUserDefaults] stringForKey:@"HardwareVersion"];

    if(name == nil)
    {
        name = @"Unknown";
    }
    if(identifier == nil)
    {
        identifier = @"Unknown";
    }
    if(firmwareVersion == nil)
    {
        firmwareVersion = @"Unknown";
    }
    if(hardwareVersion == nil)
    {
        hardwareVersion = @"Unknown";
    }

    NSDictionary *dic = @{
                          @"PeripheralName": name,
                          @"DeviceUniqueIdentifier": identifier,
                          @"FirmwareVersion": firmwareVersion,
                          @"HardwareVersion": hardwareVersion
                          };

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)initAirTurn:(CDVInvokedUrlCommand*)command
{
    NSLog(@"pluginInitialize");
#if DEBUG
    [AirTurnLogging setFrameworkLogLevel:AirTurnLogLevelDebug];
#else
    [AirTurnLogging setFrameworkLogLevel:AirTurnLogLevelInfo];
#endif
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [AirTurnManager sharedManager];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)makeActive:(CDVInvokedUrlCommand*)command
{
    AirTurnViewManager* vManager = [[AirTurnManager sharedManager] viewManager];
    BOOL first = [vManager isFirstResponder];
    if (!first)
    {
        [vManager becomeFirstResponder];
        NSLog(@"AirTurn makeActive: calling becomeFirstResponder");
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)isConnected:(CDVInvokedUrlCommand*)command
{
    BOOL connected = FALSE;
    connected = [AirTurnManager sharedManager].isConnected;

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:connected];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)addEventListener:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;

    __block NSString* eventName = command.arguments[0];

    if (eventName == nil || [eventName length] == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"eventName is null or empty"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    id observer = self.observerMap[eventName];

    if (!observer) {
        __typeof(self) __weak weakSelf = self;

        observer = [[NSNotificationCenter defaultCenter] addObserverForName:eventName
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *note) {

             __typeof(self) __strong strongSelf = weakSelf;

             [strongSelf fireEvent:eventName data:note.userInfo];
             }];
        [self.observerMap setObject:observer forKey:eventName];
    }

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

- (void)removeEventListener:(CDVInvokedUrlCommand*)command
{

    CDVPluginResult* pluginResult;

    __block NSString* eventName = command.arguments[0];

    if (eventName == nil || [eventName length] == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"eventName is null or empty"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    id observer = self.observerMap[ eventName ];

    if (observer) {

        [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                        name:eventName
                                                      object:self];
    }

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

# pragma mark - Popover Presentation Controller Delegate

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {

    // called when a Popover is dismissed
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {

    // return YES if the Popover should be dismissed
    // return NO if the Popover should not be dismissed
    return YES;
}

- (void)dismiss {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationFullScreen;
}

- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
    if([controller.presentedViewController isKindOfClass:[UINavigationController class]]) {
        // add a "Done" button to the parent navigation controller
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"AirTurn UI dismiss button in nav controller") style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
        UINavigationController *nc = (UINavigationController *)controller.presentedViewController;
        nc.topViewController.navigationItem.leftBarButtonItem = bbi;
    }
    return controller.presentedViewController;
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing  _Nonnull *)view {

    // called when the Popover changes position
}

- (void)setting:(CDVInvokedUrlCommand*)command
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navSetting = [mainStoryBoard instantiateViewControllerWithIdentifier:@"SettingNav"];
    navSetting.modalPresentationStyle = UIModalPresentationPopover;
	//navSetting.modalPresentationStyle = UIModalPresentationFullScreen;

    // add a "Done" button to the parent navigation controller
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"AirTurn UI dismiss button in nav controller") style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    UINavigationController *nc = (UINavigationController *)navSetting; //.presentedViewController;
    nc.topViewController.navigationItem.leftBarButtonItem = bbi;

    [self.viewController presentViewController:navSetting animated:YES completion:nil];

    UIPopoverPresentationController *popController = [navSetting popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popController.sourceView = self.webView;
    popController.sourceRect = CGRectMake(200, 200, 250, 300);
    popController.delegate = self;
}

- (void)killApp:(CDVInvokedUrlCommand*)command
{
    kill(getpid(), SIGKILL);
}

@end
