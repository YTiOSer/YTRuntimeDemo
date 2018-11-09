//
//  Car.m
//  YTRunTimeDemo
//
//  Created by yangtao on 2018/11/8.
//  Copyright © 2018年 YT. All rights reserved.
//

#import "Car.h"
#import "NSObject+Extension.h"


@implementation Car

//设置需要忽略的属性
- (NSArray *)ignoredNames{
    return @[@"head"];
}

//在系统方法中调用自定义方法
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        [self decode:coder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [self encode:coder];
}

@end
