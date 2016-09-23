//
//  AppDelegate.h
//  Chatter1
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate :  UIResponder <UIApplicationDelegate>

//- (NSString *)test:(NSString *)test;
- (void)sendReply:(NSString *) body forParentId:(NSString *) parentId replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler;
- (void)handleSdkManagerLogout;

@end
