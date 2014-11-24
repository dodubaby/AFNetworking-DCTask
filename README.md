AFNetworking-DCTask
===================

AFNetworking+DCTask

Examples
===================
### AFHTTPRequestOperation
```
    DCTask *task = [AFHTTPRequestOperation dc_request:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://qapi.qunar.com/api/weather/current?city=%E5%8C%97%E4%BA%AC"]]];
    
    task.thenMain(^(DCTaskHTTPOperationResponse *response){
        
        NSString *str = [[NSString alloc] initWithData:response.responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"111 task.result == %@",str);
        
        
    }).catch(^(NSError *error){
        NSLog(@"got an error: %@",error);
    });
    [task start];
```
