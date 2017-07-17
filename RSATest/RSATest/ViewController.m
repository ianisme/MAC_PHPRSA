//
//  ViewController.m
//  RSATest
//
//  Created by ian on 2017/7/17.
//  Copyright © 2017年 RengFou.Inc. All rights reserved.
//

#import "ViewController.h"
#import "NetworkService.h"

@interface ViewController()

@property (weak) IBOutlet NSTextField *inputTextField;

@property (weak) IBOutlet NSTextField *outputTextField;

@property (weak) IBOutlet NSButton *requestButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)requestButtonAction:(id)sender {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    [params setValue:self.inputTextField.stringValue forKey:@"testData"];
    [[NetworkService shareInstance] appRSAPost:@"/test.php" parameters:params handler:^(BOOL successful, id response) {
        if (successful) {
            NSDictionary *resultDic = (NSDictionary *)response;
            NSNumber *code = (NSNumber *)resultDic[@"code"];
            if (code.integerValue == 0) {
                self.outputTextField.stringValue = resultDic[@"data"][@"testData"];
            } else {
                NSLog(@"网络请求失败");
            }
        } else {
            NSLog(@"网络请求失败");
        }
    }];

    
}


@end
