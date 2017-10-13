//
//  ATPortConfig.h
//  ATShared
//
//  Created by Nick Brook on 12/04/2016.
//  Copyright © 2016 AirTurn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATPortTypes.h"

extern const NSUInteger ATPortConfigItemDataLength;

@interface ATPortConfigItem : NSObject

@property(nonatomic, readonly, nonnull) NSData *data;

@property(nonatomic, readonly) ATPortConfigItemModifier modifier;
@property(nonatomic, readonly) ATPortConfigItemType type;
@property(nonatomic, readonly) ATPortConfigItemCode code;

@property(nonatomic, readonly) BOOL isEmpty;

@property(nonatomic, readonly) BOOL hasValue;

+ (nullable instancetype)emptyItem;

+ (nullable instancetype)portConfigItemWithData:(nullable NSData *)data;

+ (nonnull instancetype)portConfigItemWithModifier:(ATPortConfigItemModifier)modifier type:(ATPortConfigItemType)type code:(ATPortConfigItemCode)code;

- (BOOL)isEqualToPortConfigItem:(nullable ATPortConfigItem *)item;

@end

extern const NSUInteger ATPortConfigDataLength;

extern const NSUInteger ATPortConfigMaximumNumberOfItems;

@interface ATPortConfig : NSObject

@property(nonatomic, readonly, nonnull) NSData *data;

@property(nonatomic, readonly) BOOL isEmpty;

@property(nonatomic, readonly) ATPortConfigSequenceType type;

@property(nonatomic, readonly) ATPortConfigItemModifier combinationModifier;

@property(nonatomic, readonly, nonnull) NSArray<ATPortConfigItem *> * items;

@property(nonatomic, readonly) NSUInteger numberOfItems;

+ (nullable instancetype)portConfigWithData:(nullable NSData *)data;

+ (nullable instancetype)combinationPortConfigWithModifier:(ATPortConfigItemModifier)modifier items:(nonnull NSArray<ATPortConfigItem *> *)items;

+ (nullable instancetype)sequencePortConfigWithItems:(nonnull NSArray<ATPortConfigItem *> *)items;

- (BOOL)isEqualToPortConfig:(nullable ATPortConfig *)config;

@end
