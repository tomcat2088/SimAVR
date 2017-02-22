//
//  main.m
//  SimAVR
//
//  Created by wangyang on 2017/2/22.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include "simavrlib/src/cmd/main.cpp"

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        cmd_main(argc, argv);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
