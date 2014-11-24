////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  DCTask.h
//
//  Created by Dalton Cherry on 5/2/14.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@class DCTask;

typedef void (^DCAsyncTaskSuccess)(id object);
typedef void (^DCAsyncTaskFailure)(NSError *error);
typedef void (^DCAsyncTask)(DCAsyncTaskSuccess success,DCAsyncTaskFailure failure);

@interface DCTask : NSObject

/**
 Start the task.
 */
-(void)start;

/**
 The first action to run. This is preformed on a background thread.
 This is just syntax sugar so you don't have a nil object in the first then.
 @return return the next task to run (then, thenMain, catch).
 */
-(DCTask*(^)(id))begin;

/**
 The next action to run. This is preformed on a background thread.
 @return return the next task to run (then, thenMain, catch).
 */
-(DCTask*(^)(id))then;

/**
 The next action to run. This is preformed on the main thread.
 @return return the next task to run (then, thenMain, catch).
 */
-(DCTask*(^)(id))thenMain;

/**
 The catch action. This is preformed on the main thread and is signaled if any of the methods error out.
 */
-(void(^)(id))catch;

/**
 Factory method to create async task with the begin block.
 @return return a newly init DCTask.
 */
+(DCTask*)new:(void (^)(void))begin;

/**
 This can be used to make inheritly async task (e.g. NSURLConnection) and work properly with a DCTask chain.
 @return return a newly init DCTask.
 */
+(DCTask*)newAsyncTask:(DCAsyncTask)asyncTask;

@end
