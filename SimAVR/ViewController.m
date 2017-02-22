//
//  ViewController.m
//  SimAVR
//
//  Created by wangyang on 2017/2/22.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "ViewController.h"
#import "AVR.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AVR run:@""];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
