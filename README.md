AFNetworking-DCTask
===================

AFNetworking+DCTask

Examples
===================
### AFHTTPRequestOperation
```
    DCTask *task = [AFHTTPRequestOperation dc_request:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.weather.com.cn/data/sk/101010100.html"]]];
    task.thenMain(^(DCTaskHTTPOperationResponse *response){
        NSError *error = nil;
        NSDictionary *weather = [NSJSONSerialization JSONObjectWithData:response.responseObject
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
        if (error) {
            NSLog(@"error: %@",error);
        }else{
            NSLog(@"weather%@",weather);
        }
    }).catch(^(NSError *error){
        NSLog(@"got an error: %@",error);
    });
    [task start];
```

### AFHTTPRequestOperationManager
```
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    DCTask *task = [manager dc_GET:@"http://www.weather.com.cn/data/sk/101010100.html" parameters:nil];
    task.thenMain(^(DCTaskHTTPOperationResponse *response){
        NSError *error = nil;
        NSDictionary *weather = [NSJSONSerialization JSONObjectWithData:response.responseObject
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
        if (error) {
            NSLog(@"error: %@",error);
        }else{
            NSLog(@"weather%@",weather);
        }
    }).catch(^(NSError *error){
        NSLog(@"got an error: %@",error);
    });
    [task start];
```

### AFHTTPSessionManager
```
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    DCTask *task = [sessionManager dc_GET:@"http://www.weather.com.cn/data/sk/101010100.html" parameters:nil];
    task.thenMain(^(DCTaskHTTPSessionResponse *response){
        NSError *error = nil;
        NSDictionary *weather = [NSJSONSerialization JSONObjectWithData:response.responseObject
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
        if (error) {
            NSLog(@"error: %@",error);
        }else{
            NSLog(@"weather%@",weather);
        }
    }).catch(^(NSError *error){
        NSLog(@"got an error: %@",error);
    });
    [task start];
```
