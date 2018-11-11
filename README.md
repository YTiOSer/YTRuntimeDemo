# YTRuntimeDemo
![Runtime.jpeg](https://upload-images.jianshu.io/upload_images/8283020-d0cb687298f0a1ea.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>关于`Runtime`的学习资料网上有很多了，但是大部分看起来有些晦涩难懂，看过一遍后让人感觉有些走马观花, 还是理解不透`Runtime`.所以趁着这几天的空闲时间, 我对自己理解的`Runtime`总结了一下，专门写了一个`Demo`, 主要讲一些常用的方法功能，以实用为主，这样才能更好更快的掌握`Runtime`的特性。结合着`Demo`学习会让你更快掌握, 搞定后不论是在开发还是面试的时候, 我相信对您的作用会比较大  .    


###一.Runtime简介
我们应该都知道 `Objective-C` 是一门动态语言，它会将一些工作放在代码运行时才处理而并非编译时。也就是说，有很多类和成员变量在我们编译的时是不知道的，而在运行时，我们所编写的代码会转换成完整的确定的代码运行。

因此，只靠编译器是不够的，我们还需要一个运行时系统(`Runtime system`)来处理编译后的代码。

`Runtime`即我们通常叫的运行时，也就是程序在运行的时候做的事情。是 `Objective-C`底层的一套`C`语言的API,是 `iOS` 内部的核心之一，我们平时编写的  `Objective-C` 代码，底层都是基于它来实现的，`Objective-C`代码编译后，其实都是`Runtime`形式的`C`语言代码。

###二.Runtime的作用

#####1.有些`Objective-C`不好实现的功能, 就可以使用`Runtime`, 比如:
- 动态交换两个方法的实现(常用于交换系统方法);
- 动态添加对象的成员变量和成员方法;
- 获得某个类的所有成员变量及方法.

#####2.有时候项目中遇到很多具体的问题, 就需要使用`Runtime`来实现了,比如:
- `iOS`黑魔法 `Swizzle` 的使用, 多用于拦截系统自带的方法调用,比如拦截imageNamed:、viewDidLoad、alloc等；
- 实现分类`Category`中可以增加属性;
- 实现NSCoding的自动归档和自动解档；
- 实现字典和模型的自动转换.

###三.Runtime的使用

>上面讲的可能让大家感觉还是不好理解, 比较书面, 下面我结合着具体的`Demo`来详细上面说到的功能. 

#####1.`iOS`黑魔法 `Swizzle` 
要使用`Swizzle`, 首先需要引入头文件 `<objc/runtime.h>`.

交换两个方法的实现方法是:
```
void method_exchangeImplementations(Method m1 , Method m2)
```

- 交换自定义类的方法实现
创建一个`Man`类, 类中实现下面两个方法, 同时需要在.h中声明.
```
+ (void)eat {
NSLog(@"吃");
}

+ (void)drink {
NSLog(@"喝");
}
```

在使用这个`Man`类的时候, 调用方法:
```
[Man eat];
[Man drink];
```
打印出来的结果, 会先打印`吃`, 然后打印 `喝`.

接下来使用`Swizzle`, 交换两个方法的实现, 获取类方法使用`class_getClassMethod` ，获取对象方法使用`class_getInstanceMethod`.
```
// 获取两个类的类方法
Method m1 = class_getClassMethod([Man class], @selector(eat));
Method m2 = class_getClassMethod([Manclass], @selector(drink));
// 开始交换方法实现
method_exchangeImplementations(m1, m2);
// 交换后，还是先调用 eat,然后调用 drink
[Man eat];
[Man drink];
```
打印出来的结果是, 先打印 `喝`, 再打印`吃`, 能够很明显的看出调用的还是这两个方法, 但方法的实现已经交换.

- 系统方法的拦截交换

>比如遇到需求 iOS9 以上的版本需要使用另一套图片, 这时候需要在一个个使用的地方判断版本来加载不同的图片吗?  这样会不会太繁琐呢? 有好的解决方法吗?

这时候就可以使用`Swizzle`, 来拦截`UIImage`的 `imageName`这个加载图片的系统方法,  来交换成我们自己的方法.

(1) 创建一个`UIImage`的分类:（UIImage+Category）;
(2) 在分类中实现一个自定义方法，方法中写要在系统方法中加入的语句，比如版本判断修改图片名;
```
//自定义方法
+ (UIImage *)yt_ImageNamed:(NSString *)name {
double version = [[UIDevice currentDevice].systemVersion doubleValue];
if (version >= 9.0) {
name = [name stringByAppendingString:@"_ios9"];
}
return [UIImage yt_ImageNamed:name]; //方法交换后, 调用imageNamed方法, 让有加载图片的功能
}
```
>注: 在自定义方法最后需要调用系统的`imageNamed`方法, 来实现加载图片的功能, 因为交换了方法实现, 所以这里调用的是交换后的自定义方法, 其实调用的是系统的`imageNamed`方法, 这里需要想想理解一下.

(3) `Category`中重写 `UIImage` 的 `load` 方法，实现方法的交换（只要能让其执行一次方法交换语句，load再合适不过了）
拦截交换:
```
+ (void)load {
//获取两个类的类方法
Method m1 = class_getClassMethod([UIImage class], @selector(imageNamed:));
Method m2 = class_getClassMethod([UIImage class], @selector(yt_ImageNamed:));
//开始交换方法实现
method_exchangeImplementations(m1, m2); //注 在使用中, 如果iOS9以上版本使用另一版本的图片, 就可以交换系统的方法, 直接使用 imageNamed方法, 调用的是yt_ImageNamed的实现
}
```
这样就实现了拦截交换系统方法的功能, 在项目中遇到类似的问题可以灵活运用.

#####2.分类`Category`中创建属性 
>大家都知道, 一般情况下在 `iOS` 分类中是无法设置属性的，如果在分类的声明中写 `@property` 只能为其生成 `get` 和 `set ` 方法的声明，但无法生成成员变量，就是虽然点语法能调用出来，但程序执行后会crash.

针对分类中创建属性, `Runtime`可以巧妙的实现,使用一下方法:
```
void objc_setAssociatedObject(id object , const void *key ,id value ,objc_AssociationPolicy policy)
```
讲需要设置的属性值绑定到当前类即可, 具体步骤如下:
(1).创建一个分类`Category`，比如给任何一个对象都添加一个`name`属性，就是`NSObject`添加分类（`NSObject+Category`）;
(2).先在.h 中 `@property `声明出 `get` 和 `set`方法，方便点语法调用;
```
@interface NSObject (Category)

@property (nonatomic, copy) NSString *name; //声明属性, 系统生成set和get方法,方便点语法调用

@end
```
(3).在.m 中重写`name` 的 `set` 和 `get` 方法，内部利用 `Runtime` 给属性赋值和取值.
```
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
```

#####3.获取类的所有成员变量
>一个对象在归档和解档的 `encodeWithCoder` 和 `initWithCoder:` 方法中需要该对象所有的属性进行 `decodeObjectForKey: ` 和 `encodeObject:` ，一般情况下需要对每个属性都写归解档, 添加或删除属性对应也要修改, 十分的不方便, 但是通过 `Runtime` 我们声明中无论写多少个属性，都不需要再修改实现中的代码了。

(1)比如一个 `Person` 类,需要对它的成员变量进行归解档, 步骤如下:
- 通过`runtime` 获取当前所有成员变量名, 然后获取到各个变量值, 以变量名为 `key`进行归档:
```
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
``` 
- 通过 `runtime`获取到所有成员变量名, 以变量名为 `key` 解档取出值: 
```
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
```

以上就实现了利用 `runtime` 进行归解档, 比之前一个个变量进行方便了很多, 但是在实际的运用中, 如果遇到一个类需要归解档就这样写, 多个需要重复写, 这时候可以 在 `NSObject` 的分类中时间归解档, 这样各个类使用时候只需要简单的几句就可以实现, 步骤如下:
(1).为 `NSObject` 创建分类, 并在 .h 中声明归解档的方法, 便于子类的使用;
```
@interface NSObject (Extension)

- (NSArray *)ignoredNames;
- (void)encode:(NSCoder *)aCoder; //重写方法, 避免覆盖系统方法
- (void)decode:(NSCoder *)aDecoder;

@end
```
(2)归档:
```
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
```
(3).解档:
```
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
```

> 上面的代码声明的方法, 我换了一个方法名（不然会覆盖系统原来的方法！），同时加了一个忽略属性方法是否被实现的判断，便于在使用时候对不需要进行归解档的属性进行判断, 同时还加上了对父类属性的归解档循环。

这样再使用之后只需要简单的几行代码就可以实现归解档, 例如对 `Cat` 类进行归解档:
```
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
```

#####4.字典转模型
> 一般我们都是使用 `KVC` 进行字典转模型，但是它还是有一定的局限性，例如：模型属性和键值对对应不上会crash（虽然可以重写`setValue:forUndefinedKey:` 方法防止报错），模型属性是一个对象或者数组时不好处理等问题，所以无论是效率还是功能上，利用 `runtime` 进行字典转模型都是比较好的选择.

字典转模型我们需要考虑三种特殊情况：
1.字典的key和模型的属性匹配不上;
2.模型中嵌套模型（模型属性是另外一个模型对象）;
3.数组中装着模型（模型的属性是一个数组，数组中是一个个模型对象）.

针对上面的三种特殊情况，我们一个个详解下处理过程.
(1).先是字典的 `key` 和模型的属性不对应的情况。
不对应的情况有两种，一种是字典的键值大于模型属性数量，这时候我们不需要任何处理，因为 `runtime` 是先遍历模型所有属性，再去字典中根据属性名找对应值进行赋值，多余的键值对也当然不会去看了；另外一种是模型属性数量大于字典的键值对，这时候由于属性没有对应值会被赋值为`nil`，就会导致`crash`，我们只需加一个判断即可,代码如下:
```
- (void)setDict:(NSDictionary *)dict {

Class c = self.class;
while (c &&c != [NSObject class]) {

unsigned int outCount = 0;
Ivar *ivars = class_copyIvarList(c, &outCount);
for (int i = 0; i < outCount; i++) {
Ivar ivar = ivars[i];
NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];

// 成员变量名转为属性名（去掉下划线 _ ）
key = [key substringFromIndex:1];
// 取出字典的值
id value = dict[key];

// 如果模型属性数量大于字典键值对数理，模型属性会被赋值为nil而报错,这时候判断值是nil的话, 忽略这个模型的属性即可.
if (value == nil) continue;

// 将字典中的值设置到模型上
[self setValue:value forKeyPath:key];
}
free(ivars);
c = [c superclass];
}
}

```

(2).模型属性是另外一个模型对象的情况, 这时候我们就需要利用 `runtime` 的`ivar_getTypeEncoding` 方法获取模型对象类型，对该模型对象类型再进行字典转模型，也就是进行递归，需要注意的是我们要排除系统的对象类型，例如NSString，下面的方法中我添加了一个类方法方便递归。
```
#import "NSObject+JSONExtension.h"
#import <objc/runtime.h>

@implementation NSObject (JSONExtension)

- (void)setDict:(NSDictionary *)dict {

Class c = self.class;
while (c &&c != [NSObject class]) {

unsigned int outCount = 0;
Ivar *ivars = class_copyIvarList(c, &outCount);
for (int i = 0; i < outCount; i++) {
Ivar ivar = ivars[i];
NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];

// 成员变量名转为属性名（去掉下划线 _ ）
key = [key substringFromIndex:1];
// 取出字典的值
id value = dict[key];

// 如果模型属性数量大于字典键值对数理，模型属性会被赋值为nil而报错
if (value == nil) continue;

// 获得成员变量的类型
NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];

// 如果属性是对象类型
NSRange range = [type rangeOfString:@"@"];
if (range.location != NSNotFound) {
// 那么截取对象的名字（比如@"Dog"，截取为Dog）
type = [type substringWithRange:NSMakeRange(2, type.length - 3)];
// 排除系统的对象类型
if (![type hasPrefix:@"NS"]) {
// 将对象名转换为对象的类型，将新的对象字典转模型（递归）
Class class = NSClassFromString(type);
value = [class objectWithDict:value];
}
}

// 将字典中的值设置到模型上
[self setValue:value forKeyPath:key];
}
free(ivars);
c = [c superclass];
}
}

+ (instancetype )objectWithDict:(NSDictionary *)dict {
NSObject *obj = [[self alloc]init];
[obj setDict:dict];
return obj;
}

```

(3).第三种情况是模型的属性是一个数组，数组中是一个个模型对象,我们既然能获取到属性类型，那就可以拦截到模型的那个数组属性，进而对数组中每个数据遍历并字典转模型，但是我们不知道数组中的模型都是什么类型，我们可以声明一个方法，该方法目的不是让其调用，而是让其实现并返回数组中模型的类型, 这样就可以对数组中的数据进行字典转模型.
在分类中声明了 `arrayObjectClass` 方法, 子类调用返回数组中模型的类型即可.
```
@interface NSObject (JSONExtension)

- (void)setDict: (NSDictionary *)dict;
+ (instancetype)objectWithDict: (NSDictionary *)dict;

//告诉数组中都是什么类型的模型对象
- (NSString *)arrayObjectClass;

@end
```

然后进行字典转模型:
```
#import "NSObject+JSONExtension.h"
#import <objc/runtime.h>

@implementation NSObject (JSONExtension)

- (void)setDict:(NSDictionary *)dict{

Class c = self.class;
while (c && c != [NSObject class]) {
unsigned int outCount = 0;
Ivar *ivarArray = class_copyIvarList([self class], &outCount);

for (int i = 0; i < outCount; i++) {
Ivar ivar = ivarArray[i];
NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];

//成员变量名转为属性名(去掉下划线_)
key = [key substringFromIndex:1];
//取出字典的值
id value = dict[key];

//如果模型属性数量大于字典键值对数量,则key对应dict中没有值, 模型属性会被赋值为nil而报错
if (value == nil) {
continue;
}

//获得成员变量的类型
NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];

//如果属性是对象类型
NSRange range = [type rangeOfString:@""];
if (range.location != NSNotFound) {
//那么截取对象的名字(比如@"Dog", 截取为Dog)
type = [type substringWithRange:NSMakeRange(2, type.length - 3)];
//排除系统的对象类型
if (![type hasPrefix:@"NS"]) {
//将对象名转换为对象的类型, 将新的对象字典转模型(递归)
Class class = NSClassFromString(type);
value = [class objectWithDict:value];
}else if ([type isEqualToString:@"NSArray"]){
//如果是数组类型, 将数组中的每个模型进行字典转模型
NSArray *array = (NSArray *)value;
NSMutableArray *mArray = [NSMutableArray array];//先创建一个临时数组存放模型

//获取到每个模型的类型
id class;
if ([self respondsToSelector:@selector(arrayObjectClass)]) {
NSString *classStr = [self arrayObjectClass];
class = NSClassFromString(classStr);
}else{
NSLog(@"数组内模型是未知类型");
return;
}

//将数组中的所有模型进行字典转模型
for (int i = 0; i < array.count; i++) {
[mArray addObject:[class objectWithDict:value[i]]];
}

value = mArray;
}
}

//将字典中的值设置到模型上
[self setValue:value forKey:key];
}
}

}

+ (instancetype)objectWithDict:(NSDictionary *)dict{
NSObject *obj = [[self alloc] init];
[obj setDict:dict];
return obj;
}

@end
```

以上介绍了几点`Runtime`的特性, 并结合我们开发中可能遇到的情况就行讲解, 这样大家可以更好的理解, 建议大家对照着我的 `demo` 详细看下, 自己也试一试, 只有自己动手才能真正的理解.

如果看完感觉对您有些帮助的话,不妨 `star`下哈.
