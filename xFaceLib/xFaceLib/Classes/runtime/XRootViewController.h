//
//  XRootViewController.h
//  xFaceLib
//
//  Copyright (c) 2014年 Polyvi Inc. All rights reserved.
//

#import "XViewController.h"

extern NSString* const kClientNotification;

@class XRuntime;

@interface XRootViewController : XViewController

@property (strong, nonatomic) XRuntime *runtime;

@end
