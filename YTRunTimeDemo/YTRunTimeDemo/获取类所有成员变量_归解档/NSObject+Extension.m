//
//  NSObject+Extension.m
//  YTRunTimeDemo
//
//  Created by yangtao on 2018/11/8.
//  Copyright © 2018年 YT. All rights reserved.
//

#import "NSObject+Extension.h"
#import <objc/runtime.h>

@implementation NSObject (Extension)

- (void)encode:(NSCoder *)aCoder{
    
    //一层层父类往上查找, 对父类的属性执行归解档方法
    Class c = self.class;
    while (c && c != [NSObject class]) {
        
        unsigned int outCount = 0;
        Ivar *ivarArray = class_copyIvarList([self class], &outCount);
        
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivarArray[i];
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            
            //如果有实现该方法再去调用
            if ([self respondsToSelector:@selector(ignoredNames)]) {
                if ([[self ignoredNames] containsObject:key]) {
                    continue;
                }
            }
            
            id value = [self valueForKey:key];
            [aCoder encodeObject:value forKey:key]; //归档
        }
        free(ivarArray);
        c = [c superclass]; //向上查找父类
    }
    
}

- (void)decode:(NSCoder *)aDecoder{
    
    Class c = self.class;
    while (c && c != [NSObject class]) {
        
        unsigned int outCount = 0;
        Ivar *ivarAaary = class_copyIvarList([self class], &outCount);
        
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivarAaary[i];
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            
            if ([self respondsToSelector:@selector(ignoredNames)]) {
                if ([[self ignoredNames] containsObject:key]) {
                    continue;
                }
            }
            
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key]; //解档并赋值
        }
        free(ivarAaary);
        c = [c superclass];
    }
    
}

@end
