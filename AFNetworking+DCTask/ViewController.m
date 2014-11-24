//
//  ViewController.m
//  AFNetworking+DCTask
//
//  Created by bright on 14/11/21.
//  Copyright (c) 2014年 mtf. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking+DCTask.h"

@interface ViewController ()
{
    UITextView *textView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 40, self.view.frame.size.width-20, 300)];
    [self.view addSubview:textView];
    textView.editable = NO;
    
    NSArray *titles = @[@"AFHTTPRequestOperation",@"AFHTTPRequestOperationManager",@"AFHTTPSessionManager"];
    
    [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(self.view.frame.size.width/10, self.view.frame.size.height - 50*(titles.count-idx)-30, self.view.frame.size.width*4/5, 44);
        button.backgroundColor = [UIColor blueColor];
        [self.view addSubview:button];
        [button setTitle:(NSString *)obj forState:UIControlStateNormal];
        [button addTarget:self action:NSSelectorFromString((NSString*)obj) forControlEvents:UIControlEventTouchUpInside];
        
    }];
}

-(void)AFHTTPRequestOperation{
    
    textView.text = nil;
    
    DCTask *task = [AFHTTPRequestOperation dc_request:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.weather.com.cn/data/sk/101010100.html"]]];
    task.thenMain(^(DCTaskHTTPOperationResponse *response){
        NSError *error = nil;
        NSDictionary *weather = [NSJSONSerialization JSONObjectWithData:response.responseObject
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
        if (error) {
            NSLog(@"error: %@",error);
        }else{
            NSLog(@"%@%@",NSStringFromSelector(_cmd),weather);
            textView.text = [NSString stringWithFormat:@"%@\n%@",NSStringFromSelector(_cmd) ,[weather description]];
        }
    }).catch(^(NSError *error){
        NSLog(@"got an error: %@",error);
    });
    [task start];
}

-(void)AFHTTPRequestOperationManager{
    
    textView.text = nil;
    
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
            NSLog(@"%@%@",NSStringFromSelector(_cmd),weather);
            textView.text = [NSString stringWithFormat:@"%@\n%@",NSStringFromSelector(_cmd) ,[weather description]];
        }
    }).catch(^(NSError *error){
        NSLog(@"got an error: %@",error);
    });
    [task start];
}

-(void)AFHTTPSessionManager{
    
    textView.text = nil;
    
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
            NSLog(@"%@%@",NSStringFromSelector(_cmd),weather);
            textView.text = [NSString stringWithFormat:@"%@\n%@",NSStringFromSelector(_cmd) ,[weather description]];
        }
    }).catch(^(NSError *error){
        NSLog(@"got an error: %@",error);
    });
    [task start];
}

@end
