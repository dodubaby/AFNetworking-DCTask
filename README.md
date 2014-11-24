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
```

### AFHTTPSessionManager
```
```
