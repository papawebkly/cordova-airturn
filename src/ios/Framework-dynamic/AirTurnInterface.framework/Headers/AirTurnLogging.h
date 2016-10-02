//
//  AirTurnLogging.h
//  AirTurnInterface
//
//  Created by Nick Brook on 19/06/2015.
//  Copyright © 2015 Nick Brook. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  AirTurn Log Flags
 */
typedef NS_OPTIONS(NSUInteger, AirTurnLogFlag){
    /*!
     *  Error log flag
     */
    AirTurnLogFlagError      =(1 << 0),
    /*!
     *  Warning log flag
     */
    AirTurnLogFlagWarning    =(1 << 1),
    /*!
     *  Info log flag
     */
    AirTurnLogFlagInfo       =(1 << 2),
    /*!
     *  Debug log flag
     */
    AirTurnLogFlagDebug      =(1 << 3),
    /*!
     *  Verbose log flag
     */
    AirTurnLogFlagVerbose    =(1 << 4),
};

/*!
 *  AirTurn Log level masks
 */
typedef NS_ENUM(NSUInteger, AirTurnLogLevel){
    /*!
     *  No logging
     */
    AirTurnLogLevelOff       = 0,
    /*!
     *  Error logging
     */
    AirTurnLogLevelError     =(AirTurnLogFlagError),
    /*!
     *  Warning and error logging
     */
    AirTurnLogLevelWarning   =(AirTurnLogLevelError   | AirTurnLogFlagWarning),
    /*!
     *  Info, warning and error logging
     */
    AirTurnLogLevelInfo      =(AirTurnLogLevelWarning | AirTurnLogFlagInfo),
    /*!
     *  Debug, info, warning and error logging
     */
    AirTurnLogLevelDebug     =(AirTurnLogLevelInfo    | AirTurnLogFlagDebug),
    /*!
     *  Verbose, debug, info, warning and error logging
     */
    AirTurnLogLevelVerbose   =(AirTurnLogLevelDebug   | AirTurnLogFlagVerbose),
    /*!
     *  All logging
     */
    AirTurnLogLevelAll       = NSUIntegerMax
};

/*!
 *  AirTurn Logging Class
 */
@interface AirTurnLogging : NSObject

/*!
 *  Set the framework logging level. Only logs this severe or more will be logged.
 *
 *  @param logLevel The desired log level
 */
+ (void)setFrameworkLogLevel:(AirTurnLogLevel)logLevel;

/*!
 *  If you use CocoaLumberjack in your project but don't want AirTurn to use it (for whatever reason) then you can disable it here. By default CocoaLumberjack is used if available.
 *
 *  @param useCocoaLumberjack YES to use CocoaLumberjack if available, No to disable.
 */
+ (void)setUseCocoaLumberjack:(BOOL)useCocoaLumberjack;

@end
