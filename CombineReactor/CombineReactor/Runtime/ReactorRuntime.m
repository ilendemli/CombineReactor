#import <objc/runtime.h>
#import "ReactorRuntime.h"

@implementation NSObject (Reactor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInitializeOfClassNamed:@"UIViewController"];
        #if !TARGET_OS_MACCATALYST
        [self swizzleInitializeOfClassNamed:@"NSViewController"];
        #endif
    });
}

+ (void)swizzleInitializeOfClassNamed:(NSString *)className {
    Class class = NSClassFromString(className);
    if (class) {
        Method originalMethod = class_getClassMethod(class, @selector(initialize));
        Method replacementMethod = class_getClassMethod(self, @selector(_reactor_initialize));
        
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}

+ (void)_reactor_initialize {
    [self _reactor_initialize];
    
    BOOL isUIViewController = [self isSubclassOfClassNamed:@"UIViewController"];
    BOOL isNSViewController = [self isSubclassOfClassNamed:@"NSViewController"];
    
    if (isUIViewController || isNSViewController) {
        [self swizzleViewDidLoad];
    }
}

+ (void)swizzleViewDidLoad {
    Class class = self;
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL oldSelector = @selector(viewDidLoad);
    SEL performBindingSelector = @selector(_reactor_performBinding);
    #pragma clang diagnostic pop
    
    Method oldMethod = class_getInstanceMethod(class, oldSelector);
    const char *types = method_getTypeEncoding(oldMethod);
    void (*oldMethodImp)(id, SEL) = (void (*)(id, SEL))method_getImplementation(oldMethod);
    
    IMP newMethodImp = imp_implementationWithBlock(^(__unsafe_unretained id self) {
        oldMethodImp(self, oldSelector);
        
        if ([self respondsToSelector:performBindingSelector]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:performBindingSelector];
            #pragma clang diagnostic pop
        }
    });
    class_replaceMethod(class, oldSelector, newMethodImp, types);
}

+ (BOOL)isSubclassOfClassNamed:(NSString *)className {
    Class superclass = NSClassFromString(className);
    if (superclass) {
        return [self isSubclassOfClass:superclass];
    }
    return NO;
}

@end
