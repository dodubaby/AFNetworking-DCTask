////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  DCTask.m
//
//  Created by Dalton Cherry on 5/2/14.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import "DCTask.h"

/*
 This is a literal copy of the block structure so we can dig out the method signature.
 I borrowed this structure from promiseKit (see the README).
 This is pretty slick, but has some possible issues with...
 If the internal structure of a block changes (unlikely, but possible) this would no longer work.
 Then again if that happened, we would have to change the code either way, so I guess it is not a big deal,
 but I feel it is worth writing down.
 */
struct DCBlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;	// NULL
    	unsigned long int size;     // sizeof(struct Block_literal_1)
        // optional helper functions
    	void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
    	void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

//The possible flags of a block structure (or the ones we are interested in).
typedef NS_OPTIONS(NSUInteger, DCBlockDescriptionFlags) {
    PMKBlockDescriptionFlagsHasCopyDispose = (1 << 25),
    PMKBlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
    PMKBlockDescriptionFlagsIsGlobal = (1 << 28),
    PMKBlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    PMKBlockDescriptionFlagsHasSignature = (1 << 30)
};

//this method pulls the method signature from the block,
//which we can use to infer the return type, or if there is something to return.
static NSMethodSignature *NSMethodSignatureForBlock(id block) {
    if (!block)
        return nil;
    
    struct DCBlockLiteral *blockRef = (__bridge struct DCBlockLiteral*)block;
    DCBlockDescriptionFlags flags = (DCBlockDescriptionFlags)blockRef->flags;
    
    if (flags & PMKBlockDescriptionFlagsHasSignature) {
        void *signatureLocation = blockRef->descriptor;
        signatureLocation += sizeof(unsigned long int);
        signatureLocation += sizeof(unsigned long int);
        
        if (flags & PMKBlockDescriptionFlagsHasCopyDispose) {
            signatureLocation += sizeof(void(*)(void *dst, void *src));
            signatureLocation += sizeof(void (*)(void *src));
        }
        
        const char *signature = (*(const char **)signatureLocation);
        return [NSMethodSignature signatureWithObjCTypes:signature];
    }
    return nil;
}


@interface DCTask ()

//This basically a singly linked list
@property(nonatomic,strong)DCTask *next;

//store the work to do
@property(nonatomic,strong)DCTask*(^work)(id);
@property(nonatomic,strong)DCAsyncTask asyncTask;
@property(nonatomic,assign)BOOL isMain;
@property(nonatomic,strong)void(^errorHandler)(id);

@end

@implementation DCTask

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)start
{
    [self runTask:self param:nil];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)runTask:(DCTask*)task param:(id)param
{
    if(!task)
        return;
    [task willStart];
    if(task.asyncTask)
    {
        task.asyncTask(^(id val){
            dispatch_async(dispatch_get_main_queue(),^{
                [self finishedTask:task result:val];
            });
        },^(NSError *error){
            [self processError:task val:error];
        });
    }
    else if(task.work)
    {
        if(task.isMain)
        {
            id val = [self preformBlock:task.work param:param];
            [self finishedTask:task result:val];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                id val = [self preformBlock:task.work param:param];
                dispatch_async(dispatch_get_main_queue(),^{
                    [self finishedTask:task result:val];
                });
            });
        }
    }
    else {
        [self finishedTask:task result:param];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)preformBlock:(DCTask*(^)(id))block param:(id)param
{
    NSMethodSignature *sig = NSMethodSignatureForBlock(block);
    if(sig)
    {
        //const NSUInteger nargs = sig.numberOfArguments;
        const char rtype = sig.methodReturnType[0];
        //NSLog(@"rtype: %c",rtype);
        id response = nil;
        if(rtype == 'v') {
            ((void(^)(id))block)(param);
        } else {
            response = block(param);
        }
        return response;
    }
    return block(param);
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)willStart
{
    //used for subclasses
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)processError:(DCTask*)currentTask val:(id)value
{
    if([value isKindOfClass:[NSError class]])
    {
        if(!self.errorHandler)
            self.errorHandler = currentTask.errorHandler;
        if(!self.errorHandler)
        {
            DCTask *task = self;
            while(!self.errorHandler)
            {
                self.errorHandler = task.next.errorHandler;
                task = task.next;
            }
        }
        
        if(self.errorHandler)
            self.errorHandler(value);
        return YES;
    }
    return NO;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)finishedTask:(DCTask*)task result:(id)result
{
    if([self processError:task val:result])
        return;
    //a task was returned, so let's add it into the chain
    if([result isKindOfClass:[DCTask class]])
    {
        DCTask *rTask = result;
        rTask.next = task.next;
        task.next = rTask;
    }
    [self runTask:task.next param:result];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(DCTask*(^)(id))begin
{
    //__weak id weakSelf = self;
    return ^(DCTask*(^begin)(id)){
        DCTask *task = [DCTask new];
        self.next = task;
        task.work = begin;
        return task;
    };
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(DCTask*(^)(id))then
{
    return ^(DCTask*(^work)(id)){
        DCTask *task = [DCTask new];
        self.next = task;
        task.work = work;
        return task;
    };
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(DCTask*(^)(id))thenMain
{
    return ^(DCTask*(^work)(id)){
        DCTask *task = [DCTask new];
        self.next = task;
        task.isMain = YES;
        task.work = work;
        return task;
    };
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void(^)(id))catch
{
    return ^(void(^error)(NSError*)){
        self.errorHandler = error;
    };
}
////////////////////////////////////////////////////////////////////////////////////////////////////
+(DCTask*)new:(void (^)(void))beginBlock
{
    DCTask *task = [DCTask new];
    task.begin(^{
        beginBlock();
    });
    return task;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
+(DCTask*)newAsyncTask:(DCAsyncTask)asyncTask
{
    DCTask *task = [DCTask new];
    task.asyncTask = asyncTask;
    return task;
}
////////////////////////////////////////////////////////////////////////////////////////////////////

@end

