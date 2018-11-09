//
//  NSObject+Category.m
//  YTRunTimeDemo
//
//  Created by yangtao on 2018/11/7.
//  Copyright © 2018年 YT. All rights reserved.
//

#import "NSObject+Category.h"
#import <objc/runtime.h>

//.m中重写set和get方法, 内部利用runtime给属性赋值和取值
@implementation NSObject (Category)

char nameKey; //用于取值的key

//set
- (void)setName:(NSString *)name{
    //将name值和对象关联起来, 将name值存储到当前对象中
    /*参数:
        object: 给哪个对象设置属性;
        key: 一个属性对应一个key, 存储后需要通过这个key取出值, key可为double,int等任意类型, 建议用char可节省字节;
        value: 给属性设置的值;
        policy: 存储策略 (assign, copy, retain);
     */
    objc_setAssociatedObject(self, &nameKey, name, OBJC_ASSOCIATION_COPY);
}

//get
- (NSString *)name{
    return objc_getAssociatedObject(self, &nameKey);
}

@end
