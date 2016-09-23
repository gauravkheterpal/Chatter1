//
//  AppDelegate.m
//  Chatter1
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//


#import "AppDelegate.h"
#import "InitialViewController.h"
#import <SalesforceSDKCore/SFPushNotificationManager.h>
#import <SalesforceSDKCore/SFDefaultUserManagementViewController.h>
#import <SalesforceSDKCore/SalesforceSDKManager.h>
#import <SalesforceSDKCore/SFUserAccountManager.h>
#import <SalesforceCommonUtils/SFLogger.h>
#import <SalesforceRestAPI/SFRestRequest.h>
#import <SalesforceRestAPI/SFRestAPI+Blocks.h>
#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <SalesforceSDKCore/SFAuthenticationManager.h>

static NSString * const RemoteAccessConsumerKey = @"3MVG9ZL0ppGP5UrBly5N4WklgL_oa_TOvi7dzTSrvsU0KFwic7eu9RSvcgKkTiTb81lXYELT4DP381bv0sAhV";
static NSString * const OAuthRedirectURI        = @"testsfdc:///mobilesdk/detect/oauth/done";

static NSString * const PostFeedItemsToChatterWallURL = @"/v32.0/chatter/feed-elements";

@interface AppDelegate ()<WCSessionDelegate>

- (void)setupRootViewController;

- (void)initializeAppViewState;

@end

@implementation AppDelegate

@synthesize window = _window;

- (id)init
{
    self = [super init];
    if (self) {
        [SFLogger setLogLevel:SFLogLevelDebug];

        [SFUserAccountManager sharedInstance].oauthClientId = RemoteAccessConsumerKey;
        [SFUserAccountManager sharedInstance].oauthCompletionUrl = OAuthRedirectURI;
        [SFUserAccountManager sharedInstance].scopes = [NSSet setWithObjects:@"web", @"api", nil];
        if ([WCSession isSupported]) {
            WCSession* session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
        }
    }
    return self;
}

- (void)startWCSession {
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)storeCurrentUser:(SFUserAccount *)currentUser {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:currentUser] forKey:@"Chatter1_SFUserAccount_currentUser"];
}

- (void)removeCurrentUser {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Chatter1_SFUserAccount_currentUser"];
}

- (SFUserAccount *)currentUser {
    SFUserAccount *user = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Chatter1_SFUserAccount_currentUser"]];
    return user;
}

- (void)login {
    __weak AppDelegate *weakSelf = self;
    [[SFAuthenticationManager sharedManager]
     loginWithCompletion:(SFOAuthFlowSuccessCallbackBlock)^(SFOAuthInfo *info) {
         NSLog(@"Authentication Done");
         [weakSelf setupRootViewController];
         SFIdentityData *claims = [SFAuthenticationManager sharedManager].idCoordinator.idData;
         NSLog(@"claims = %@",claims);
         NSLog(@"accessToken = %@", [SFAuthenticationManager sharedManager].coordinator.credentials.accessToken);
         SFUserAccount *currentUser = [[SFUserAccountManager sharedInstance] currentUser];
         [self storeCurrentUser:currentUser];
     }
     failure:(SFOAuthFlowFailureCallbackBlock)^(SFOAuthInfo *info, NSError *error) {
         NSLog(@"Authentication Failed");
         // handle error hare.
     }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self initializeAppViewState];
    SFUserAccount *curerentUser = [self currentUser];
    if (curerentUser) {
        [[SFUserAccountManager sharedInstance] setCurrentUser:curerentUser];
        [self setupRootViewController];
    } else {
        [self login];
        if ([WCSession isSupported]) {
            WCSession* session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
        }
    }
    
    NSLog(@"Register for Notification");
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                (UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    NSLog(@"Register for Salesforce push notification");
    [[SFPushNotificationManager sharedInstance] registerForRemoteNotifications];
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[SFPushNotificationManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    if ([[SFUserAccountManager sharedInstance] currentUser].credentials.accessToken != nil) {
        [[SFPushNotificationManager sharedInstance] registerForSalesforceNotifications];
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError :%@",error);
}


#pragma mark - Private methods

- (void)initializeAppViewState
{
    self.window.rootViewController = [[InitialViewController alloc] initWithNibName:nil bundle:nil];
    [self.window makeKeyAndVisible];
}

- (void)setupRootViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *rootVC = [storyboard instantiateInitialViewController];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:46.0/255.0 green:140.0/255.0 blue:212.0/255.0 alpha:1.0]];
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.window.rootViewController = rootVC;
}


- (void)resetViewState:(void (^)(void))postResetBlock
{
    if ([self.window.rootViewController presentedViewController]) {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            postResetBlock();
        }];
    } else {
        postResetBlock();
    }
}

- (void)handleSdkManagerLogout
{
    [self log:SFLogLevelDebug msg:@"SFAuthenticationManager logged out.  Resetting app."];
    [self resetViewState:^{
       
        [self initializeAppViewState];
        [self removeCurrentUser];
        
        NSArray *allAccounts = [SFUserAccountManager sharedInstance].allUserAccounts;
        if ([allAccounts count] > 1) {
            SFDefaultUserManagementViewController *userSwitchVc = [[SFDefaultUserManagementViewController alloc] initWithCompletionBlock:^(SFUserManagementAction action) {
                [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
            }];
            [self.window.rootViewController presentViewController:userSwitchVc animated:YES completion:NULL];
        } else {
            if ([allAccounts count] == 1) {
                [SFUserAccountManager sharedInstance].currentUser = ([SFUserAccountManager sharedInstance].allUserAccounts)[0];
            }
            
            [self login];
        }
    }];
}

- (void)handleUserSwitch:(SFUserAccount *)fromUser
                  toUser:(SFUserAccount *)toUser
{
    [self log:SFLogLevelDebug format:@"SFUserAccountManager changed from user %@ to %@.  Resetting app.",
     fromUser.userName, toUser.userName];
    [self resetViewState:^{
        [self initializeAppViewState];
        [self login];
    }];
}


- (void)sendReply:(NSString *) body forParentId:(NSString *) parentId replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    NSDictionary *dict =  @{ @"body": @{ @"messageSegments": @[@{ @"type": @"Text", @"text": body }] } };
    NSString *path = [NSString stringWithFormat:@"/services/data/v37.0/chatter/feed-elements/%@/capabilities/comments/items?text=New+comment", parentId];
    SFRestRequest * request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:dict];
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
        NSLog(@"ERROR %@",e.localizedDescription);
        //replyHandler(@{ @"response:": e.localizedDescription });
    } completeBlock:^ (id response) {
        NSLog(@"RESPONSE - %@",response);
        if(response) {
            //replyHandler(@{ @"response:": response });
        }
    }];
}

@end
