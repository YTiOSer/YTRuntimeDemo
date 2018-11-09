//
//  NSObject+Extension.h
//  YTRunTimeDemo
//
//  Created by yangtao on 2018/11/8.
//  Copyright © 2018年 YT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extension)

- (NSArray *)ignoredNames;
- (void)encode:(NSCoder *)aCoder; //重写方法, 避免覆盖系统方法
- (void)decode:(NSCoder *)aDecoder;

@end

