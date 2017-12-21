//
//  main.m
//  RunTimeClass
//
//  Created by 董亮 on 2017/12/21.
//  Copyright © 2017年 董亮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <objc/runtime.h>
#import <objc/message.h>


static void addMethodForMyClass(id self, SEL _cmd, NSString *test) {
    // 获取类中指定名称实例成员变量的信息
    Ivar ivar = class_getInstanceVariable([self class], "test");
    // 获取整个成员变量列表
    //   Ivar * class_copyIvarList ( Class cls, unsigned intint * outCount );
    // 获取类中指定名称实例成员变量的信息
    //   Ivar class_getInstanceVariable ( Class cls, const charchar *name );
    // 获取类成员变量的信息
    //   Ivar class_getClassVariable ( Class cls, const charchar *name );
    
    // 返回名为test的ivar变量的值
    id obj = object_getIvar(self, ivar);
    NSLog(@"%@",obj);
    NSLog(@"addMethodForMyClass:参数：%@",test);
    NSLog(@"ClassName：%@",NSStringFromClass([self class]));
}



int main(int argc, char * argv[]) {
    @autoreleasepool {
        // 使用objc_allocateClassPair创建一个类Class
        const char * className = "RuntimeClass";
        Class rClass = objc_getClass(className);
        if (!rClass)
        {
            Class superClass = [NSObject class];
            rClass = objc_allocateClassPair(superClass, className, 0);
        }
        
        
        //使用class_addIvar添加一个成员变量
        /*参数一、类名
        参数二、属性名称
        参数三、开辟字节长度
        参数四、对其方式
        参数五、参数类型*/
        BOOL isSuccess = class_addIvar(rClass, "test", sizeof(NSString *), 0, "@");
        
        // 三目运算符
        isSuccess?NSLog(@"添加变量成功"):NSLog(@"添加变量失败");
        
        
        
        //使用class_addMethod添加成员方法
        
       /* 参数一、类名
        参数二、SEL 添加的方法名字
        参数三、IMP指针 (IMP就是Implementation的缩写，它是指向一个方法实现的指针，每一个方法都有一个对应的IMP)
        参数四、其中types参数为"i@:@“，按顺序分别表示：具体类型可参照官方文档
        i 返回值类型int，若是v则表示void
        @ 参数id(self)
        : SEL(_cmd)
        @ id(str)
        V@:表示返回值是void 带有SEL参数 （An object (whether statically typed or typed id)）*/
        
        class_addMethod(rClass, @selector(addMethodForMyClass:), (IMP)addMethodForMyClass, "V@:");
        
        
        
        //注册到运行时环境
        objc_registerClassPair(rClass);
        
        //实例化类
        id rObject = [[rClass alloc] init];
        
        //赋值
        NSString *str = @"我是test";
        // 通过KVC的方式给myObj对象的test属性赋值
        [rObject setValue:str forKey:@"test"];
        
        //调用函数
        [rObject performSelector:@selector(addMethodForMyClass:) withObject:@"我是参数"];
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
