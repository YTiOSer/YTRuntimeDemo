//
//  Person.m
//  YTRunTimeDemo
//
//  Created by yangtao on 2018/11/8.
//  Copyright © 2018年 YT. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

@implementation Person

//设置不需要归解档的属性
- (NSArray *)ignoredNames{
    return @[@"_a", @"_b", @"_c"];
}

//归档
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    //获取所有成员变量
    unsigned int outCount = 0;
    /*
     参数:
     1.哪个类
     2.接收值的地址, 用于存放属性的个数
     3.返回值: 存放所有获取到的属性, 可调出名字和类型
     */
    Ivar *ivarArray = class_copyIvarList([self class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivarArray[i];
        //将每个成员变量名转换为NSString对象类型
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        //忽略不需要归档的属性
        if ([[self ignoredNames] containsObject:key]) {
            continue; //跳过本次循环
        }
        
        //通过成员变量名, 取出成员变量的值
        id value = [self valueForKey:key];
        //再把值归档
        [coder encodeObject:value forKey:key];
        //这两部就相当于 [coder encodeObject: @(self.name) forKey:@"_name"];
    }
    free(ivarArray);
}

//解档
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        //获取所有成员变量
        unsigned int outCount = 0;
        
        Ivar *ivarArray = class_copyIvarList([self class], &outCount);
        
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivarArray[i];
            //获取每个成员变量名并转换为NSString对象类型
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            
            //忽略不需要解档的属性
            if ([[self ignoredNames] containsObject:key]) {
                continue;
            }
            
            //根据变量名解档取值, 无论是什么类型
            id value = [coder decodeObjectForKey:key];
            //取出的值再设置给属性
            [self setValue:value forKey:key];
            //这两步相当于以前的 self.name = [coder decodeObjectForKey:@"_name"];
        }
        free(ivarArray); //释放内存
    }
    return self;
}

@end
