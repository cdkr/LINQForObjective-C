//
//  OCLinq.m
//  LINQForObjective-C
//
//  Created by Yao Long on 7/18/16.
//  Copyright © 2016 Yao Long. All rights reserved.
//

#import "OCLinq.h"
#import <objc/runtime.h>

@interface OCLinq ()

@property (nonatomic) NSEnumerator *enumerator;

- (NSArray *)allObjects;

@end

@implementation OCLinq

- (NSEnumerator *)objectEnumerator {
    return self.enumerator;
}

- (NSArray *)allObjects {
    return self.enumerator.allObjects;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.enumerator countByEnumeratingWithState:state objects:buffer count:len];
}

+ (instancetype)from:(id)source {
    NSEnumerator *e = nil;
    if ([source isKindOfClass:[NSEnumerator class]]) {
        e = source;
    } else if ([source isKindOfClass:[NSArray class]] ||
               [source isKindOfClass:[NSDictionary class]] ||
               [source isKindOfClass:[NSSet class]]) {
        e = [source performSelector:@selector(objectEnumerator)];
    } else {
        return nil;
    }
    return [self fromEnumerator:e];
}

+ (instancetype)fromEnumerator:(NSEnumerator *)enumerator {
    OCLinq *instance = [[self alloc] init];
    instance.enumerator = enumerator;
    return instance;
}

- (instancetype)where:(OCLQPredicate)predicate {
    NSMutableArray *result = [NSMutableArray array];
    for (id item in self) {
        if (predicate(item)) {
            [result addObject:item];
        }
    }
    return [self.class from:result];
}

- (instancetype)select:(OCLQTransform)transform {
    NSMutableArray *result = [NSMutableArray array];
    for (id item in self) {
        id obj = transform(item);
        if (obj != nil) {
            [result addObject:obj];
        }
    }
    return [self.class from:result];
}

- (instancetype)selectMany:(OCLQTransform)transform {
    NSMutableArray *result = [NSMutableArray array];
    for (id list in self) {
        for (id item in list) {
            id obj = transform(item);
            if (obj != nil) {
                [result addObject:obj];
            }
        }
    }
    return [self.class from:result];

}

- (instancetype)orderBy:(OCLQKeySelector)keySelector {
    return [self.class from:[self.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        id valueOne = keySelector(obj1);
        id valueTwo = keySelector(obj2);
        NSComparisonResult result = [valueOne compare:valueTwo];
        return result;
    }]];
}

- (instancetype)order {
    return [self orderBy:^id(id item){return item;}];
}

- (instancetype)distinct {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (id item in self) {
        if (![result containsObject:item]) {
            [result addObject:item];
        }
    }
    return [self.class from:result];
}

- (instancetype)aggregate:(OCLQAggregateBlock)aggregate {
    id result = nil;
    for (id item in self) {
        result = result == nil ? item : aggregate(item, result);
    }
    return result;
}

- (BOOL)any:(OCLQPredicate)predicate {
    for (id item in self) {
        if (predicate(item)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)all:(OCLQPredicate)predicate {
    for (id item in self) {
        if (!predicate(item)) {
            return NO;
        }
    }
    return YES;
}

- (id)average {
    return [self.allObjects valueForKeyPath:@"@avg.self"];
}

- (id)max {
    return [self.allObjects valueForKeyPath:@"@max.self"];
}

- (id)min {
    return [self.allObjects valueForKeyPath:@"@min.self"];
}

- (id)sum {
    return [self.allObjects valueForKeyPath:@"@sum.self"];
}

- (instancetype)skip:(NSUInteger)count {
    NSArray *all = self.allObjects;
    NSArray *array = nil;
    if (count < all.count) {
        NSRange range = {count, all.count - count};
        array = [all subarrayWithRange:range];
    } else {
        array = @[];
    }
    return [self.class from:array];
}

- (instancetype)skipWhile:(OCLQPredicate)predicate {
    NSUInteger count = 0;
    for (id item in self) {
        if (predicate(item)) {
            count++;
        } else {
            break;
        }
    }
    return [self skip:count];
}

- (instancetype)take:(NSUInteger)count {
    NSArray *all = self.allObjects;
    NSRange range = {0, count > all.count ? all.count : count};
    return [self.class from:[all subarrayWithRange:range]];
}

- (instancetype)takeWhile:(OCLQPredicate)predicate {
    NSUInteger count = 0;
    for (id item in self) {
        if (!predicate(item)) {
            count++;
        } else {
            break;
        }
    }
    return [self take:count];
}

- (id)firstOrDefault:(id)defaultObj {
    NSArray *all = self.allObjects;
    return all.count > 0 ? all.firstObject : defaultObj;
}

- (id)lastOrDefault:(id)defaultObj {
    NSArray *all = self.allObjects;
    return all.count > 0 ? all.lastObject : defaultObj;
}

- (instancetype)reverse {
    return [self.class from:self.allObjects.reverseObjectEnumerator];
}

- (instancetype)contact:(OCLinq *)linq {
    NSMutableArray *result = [NSMutableArray arrayWithArray:self.allObjects];
    [result addObjectsFromArray:linq.allObjects];
    return [self.class from:result];
}

- (NSDictionary *)groupBy:(OCLQKeySelector)keySelector {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (id item in self) {
        id key = keySelector(item);
        if (key != nil) {
            NSMutableArray *arrayForKey = result[key];
            if (arrayForKey == nil) {
                arrayForKey = [NSMutableArray array];
                result[key] = arrayForKey;
            }
            [arrayForKey addObject:item];
        }
    }
    return result.copy;
}

- (instancetype)join:(OCLinq *)linq keySelector1:(OCLQKeySelector)keySelctor1 keySelector2:(OCLQKeySelector)keySelctor2 {
    NSMutableArray *pairs = [NSMutableArray array];
    for (id item1 in self) {
        for (id item2 in linq) {
            id first = keySelctor1(item1);
            if ([first isEqual:keySelctor2(item2)]) {
                OCLQPair *outter = [[OCLQPair alloc] init];
                OCLQPair *inner = [[OCLQPair alloc] init];
                inner.first = item1;
                inner.second = item2;
                outter.first = first;
                outter.second = inner;
                [pairs addObject:outter];
            }
        }
    }
    return [self.class from:pairs];
}

- (NSArray *)toArray {
    return self.allObjects;
}

- (NSDictionary *)toDictionary:(OCLQKeySelector)keySelector {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (id item in self) {
        dict[keySelector(item)] = item;
    }
    return dict.copy;
}

- (NSSet *)toSet {
    return [NSSet setWithArray:self.allObjects];
}

@end


@implementation OCLQPair

@end
