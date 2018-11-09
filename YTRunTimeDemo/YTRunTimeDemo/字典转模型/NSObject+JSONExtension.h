//
//  NSObject+JSONExtension.h
//  YTRunTimeDemo
//
//  Created by yangtao on 2018/11/8.
//  Copyright © 2018年 YT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSONExtension)

- (void)setDict: (NSDictionary *)dict;
+ (instancetype)objectWithDict: (NSDictionary *)dict;

//告诉数组中都是什么类型的模型对象
- (NSString *)arrayObjectClass;

@end

