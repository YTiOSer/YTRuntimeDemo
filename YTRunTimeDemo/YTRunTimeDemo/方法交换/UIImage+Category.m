//
//  UIImage+Category.m
//  YTRunTimeDemo
//
//  Created by yangtao on 2018/11/7.
//  Copyright © 2018年 YT. All rights reserved.
//

#import "UIImage+Category.h"
#import <objc/runtime.h> //需用到

@implementation UIImage (Category)

+ (void)load {
    //获取两个类的类方法
    Method m1 = class_getClassMethod([UIImage class], @selector(imageNamed:));
    Method m2 = class_getClassMethod([UIImage class], @selector(yt_ImageNamed:));
    //开始交换方法实现
    method_exchangeImplementations(m1, m2); //注 在使用中, 如果iOS9以上版本使用另一版本的图片, 就可以交换系统的方法, 直接使用 imageNamed方法, 调用的是yt_ImageNamed的实现
}

//自定义方法
+ (UIImage *)yt_ImageNamed:(NSString *)name {
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version >= 9.0) {
        name = [name stringByAppendingString:@"_ios9"];
    }
    return [UIImage yt_ImageNamed:name]; //方法交换后, 调用imageNamed方法, 让有加载图片的功能
}

@end
