//
//  OCLinq.h
//  LINQForObjective-C
//
//  Created by Yao Long on 7/18/16.
//  Copyright © 2016 Yao Long. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OCLQFrom(source) \
        [OCLinq from:source]

typedef BOOL (^OCLQPredicate)(id item);
typedef id (^OCLQTransform)(id item);
typedef id (^OCLQKeySelector)(id item);
typedef id (^OCLQAggregateBlock)(id item, id aggregate);

@interface OCLinq : NSObject<NSFastEnumeration>

- (NSEnumerator *)objectEnumerator;

// source must be a instance of NSEnumerator, NSArray, NSDictionary or NSSet
+ (instancetype)from:(id)source;

- (instancetype)where:(OCLQPredicate)predicate;
- (instancetype)select:(OCLQTransform)transform;
- (instancetype)selectMany:(OCLQTransform)transform;
- (instancetype)orderBy:(OCLQKeySelector)keySelector;
- (instancetype)order;
- (instancetype)distinct;

- (instancetype)aggregate:(OCLQAggregateBlock)aggregate;
- (BOOL)any:(OCLQPredicate)predicate;
- (BOOL)all:(OCLQPredicate)predicate;
- (id)average;
- (id)max;
- (id)min;
- (id)sum;

- (instancetype)skip:(NSUInteger)count;
- (instancetype)skipWhile:(OCLQPredicate)predicate;
- (instancetype)take:(NSUInteger)count;
- (instancetype)takeWhile:(OCLQPredicate)predicate;
- (id)firstOrDefault:(id)defaultObj;
- (id)lastOrDefault:(id)defaultObj;

- (instancetype)reverse;
- (instancetype)contact:(OCLinq *)linq;
- (NSDictionary *)groupBy:(OCLQKeySelector)keySelector;
- (instancetype)join:(OCLinq *)linq keySelector1:(OCLQKeySelector)keySelctor1 keySelector2:(OCLQKeySelector)keySelctor2;

- (NSArray *)toArray;
- (NSDictionary *)toDictionary:(OCLQKeySelector)keySelector;
- (NSSet *)toSet;

@end

@interface OCLQPair : NSObject

@property (nonatomic) id first;
@property (nonatomic) id second;

@end