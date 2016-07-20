//
//  main.m
//  LINQForObjective-C
//
//  Created by Yao Long on 7/18/16.
//  Copyright © 2016 Yao Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCLinq.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSArray *nums = @[@10, @9, @8, @7, @1, @2, @3, @4, @5, @6];
        NSArray *nums2 = @[@11, @12, @13];
        
        id a = [[OCLQFrom(nums) where:^BOOL(NSNumber *x) {
            return x.integerValue % 2 == 0;
        }] select:^id(NSNumber *x) {
            return @(x.integerValue * 3);
        }].max;
        
        // 30
        NSLog(@"%@", a);
        
        id s = [[OCLQFrom(nums).order.reverse
                 select:^id(NSNumber *x) {
                     return x.stringValue;
                 }] aggregate:^id(NSString *x, id aggregate) {
                     return [NSString stringWithFormat:@"%@_%@", aggregate, x];
                 }];
        
        // 10_9_8_7_6_5_4_3_2_1
        NSLog(@"%@", s);
        
        for (id item in [OCLQFrom(nums).order contact:OCLQFrom(nums2)]) {
            // 1 2 3 ... 13
            NSLog(@"%@", item);
        }
        
        id b = [OCLQFrom(nums) groupBy:^id(NSNumber *item) {
            NSInteger i = item.integerValue;
            return i % 2 == 0 ? @"even": @"odd";
        }];
        
        // {"even": [10, 8, 2, 4, 6], "odd": [9, 7, 1, 3, 5]}
        NSLog(@"%@", b);
        
        
    }
    return 0;
}
