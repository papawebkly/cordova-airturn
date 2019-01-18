//
//  AirTurnDefines.h
//  AirTurnInterface
//
//  Created by Nick Brook on 11/03/2014.
//  Copyright (c) 2014 Nick Brook. All rights reserved.
//

#import <Availability.h>

#define AIRTURN_CLASS_AVAILABLE(_iphoneIntro) __attribute__((visibility("default"))) __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_##_iphoneIntro)

#ifndef AIRTURN_EXTERN
#ifdef __cplusplus
#define AIRTURN_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define AIRTURN_EXTERN extern __attribute__((visibility ("default")))
#endif
#endif

#define AIRTURN_EXTERN_CLASS __attribute__((visibility("default")))
