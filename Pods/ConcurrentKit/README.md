ConcurrentKit
=============

Concurrency made easy with promise/future like syntax for OS X and iOS. This library greatly simplifies the work need to make async task in objc.
This library eliminates the rightward drift problem created when chaining multiple block based async task together.

It is important to note, while this borrows from promises their syntax, it is not designed as an A+ compliant promise library.
I was inspired to create this library after seeing [mxcl](https://github.com/mxcl) promiseKit library.
If you want a compliant promise library, check it out [here](https://github.com/mxcl/PromiseKit).

The best way to explain what the library does is through examples.
## Examples ##

```objc
    DCTask *task = [DCTask new];
    task.begin(^{ //syntax sugar for then
        NSLog(@"let's begin a background thread");
        sleep(10); //a example of a long running task
        return @10; //something we got from the long running task
    }).thenMain(^(NSNumber *num){
        NSLog(@"first: %@",num); //this would be a 10
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }).then(^{
		//return the web tsk.
        return [DCHTTPTask GET:@"http://www.vluxe.io"];
    }).thenMain(^(DCHTTPResponse *response){
        NSString *str = [[NSString alloc] initWithData:response.responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"web request finished: %@",str);
        //do something on the main thread.
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }).catch(^(NSError *error){
        NSLog(@"got an error: %@",error);
        self.navigationItem.rightBarButtonItem.enabled = NO;
    });
    [task start];
```

This greatly simplifies switching between threads and eliminates rightward drift. This chain can go on as long as needed.

## Useful Notes

a `return` is not required. The library automatically handles if a return type is provided. It is important to note it only support returning objects and not scalar types(char,int,BOOL,etc). The object returned from one handler is the parameter for the next handler. If nothing is return, the object passed into the next handler will be nil. 

Returning a DCTask or a subclass of it, will add it to the chain of tasks (as seen in the example of above).

## Useful Libraries

[HTTPKit](https://github.com/daltoniam/HTTPKit)
HTTPKit is a NSURLSession wrapper built off concurrentKit. 

## Install ##

The recommended approach for installing ConcurrentKit is via the CocoaPods package manager.

```
pod 'ConcurrentKit'
```

## Requirements ##

ConcurrentKit requires at least iOS 5 or OS X 10.8.


## License ##

ConcurrentKit is license under the Apache License.

## Contact ##

### Dalton Cherry ###
* https://github.com/daltoniam
* http://twitter.com/daltoniam
* http://daltoniam.com
