#ifndef HHMacro_h
#define HHMacro_h

#define WEAK(object) __weak __typeof(object) weak##object = object;
#define STRONG(object) __strong __typeof(object) strong##object = object;

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define HHSIGNAL(funcname)\
[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {\
    id async_func = funcname;\
    [subscriber sendNext:async_func];\
    [subscriber sendCompleted];\
    return nil;\
}] subscribeOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh]] deliverOn:[RACScheduler mainThreadScheduler]]




#import <objc/runtime.h>

#define ADD_DYNAMIC_PROP(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME,MEMORY_MANAGEMENT_TYPE) \
@dynamic PROPERTY_NAME ; \
static char property##PROPERTY_NAME; \
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &property##PROPERTY_NAME , PROPERTY_NAME , MEMORY_MANAGEMENT_TYPE); \
}\
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE ) objc_getAssociatedObject(self, &(property##PROPERTY_NAME ) ); \
}

#define ADD_DYNAMIC_PROPERTY(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char property##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE ) objc_getAssociatedObject(self, &(property##PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &property##PROPERTY_NAME , PROPERTY_NAME , OBJC_ASSOCIATION_RETAIN); \
}


#define ADD_DYNAMIC_PRIMITIVE_PROPERTY(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char property##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
NSNumber *number = objc_getAssociatedObject(self, &property##PROPERTY_NAME); \
return [number integerValue]; \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
NSNumber *number = [NSNumber numberWithInteger: PROPERTY_NAME]; \
objc_setAssociatedObject(self, &property##PROPERTY_NAME , number , OBJC_ASSOCIATION_RETAIN); \
}

#endif