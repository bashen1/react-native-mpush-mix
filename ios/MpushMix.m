#import "MpushMix.h"

#define REGISTRATION_ID @"registerID"

// 传入参数
#define ALIAS @"alias"
#define TAG @"tag"
#define ACCOUNT @"account"

//action
#define ACTION @"action"
#define SET_ACTION @"set"
#define UNSET_ACTION @"unset"

//event
#define CONNECT_EVENT @"ConnectEvent"
#define NOTIFICATION_EVENT @"NotificationEvent"
#define NOTIFICATION_ARRIVED_EVENT @"NotificationArrivedEvent"
#define CUSTOM_MESSAGE_EVENT @"CustomMessageEvent"
#define TAG_EVENT @"TagEvent"
#define ALIAS_EVENT @"AliasEvent"
#define ACCOUNT_EVENT @"AccountEvent"

@interface MpushMix ()

@end

@implementation MpushMix

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(MpushMixModule)

RCT_EXPORT_METHOD(initSDK)
{
    NSString *regid = [MiPushSDK getRegId];
    NSDictionary *ret = @{REGISTRATION_ID: regid};
    [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                        method:@"emit"
                          args:@[CONNECT_EVENT, ret]
                    completion:NULL];
}

RCT_EXPORT_METHOD(setAlias:(NSDictionary *)param)
{
    NSString *alias = (NSString *)param[@"alias"];
    [MiPushSDK setAlias:alias];
}

RCT_EXPORT_METHOD(unsetAlias:(NSDictionary *)param)
{
    NSString *alias = (NSString *)param[@"alias"];
    [MiPushSDK unsetAlias:alias];
}

RCT_EXPORT_METHOD(subscribe:(NSDictionary *)param)
{
    NSString *tag = (NSString *)param[@"tag"];
    [MiPushSDK subscribe:tag];
}

RCT_EXPORT_METHOD(unsubscribe:(NSDictionary *)param)
{
    NSString *tag = (NSString *)param[@"tag"];
    [MiPushSDK unsubscribe:tag];
}

RCT_EXPORT_METHOD(setAccount:(NSDictionary *)param)
{
    NSString *account = (NSString *)param[@"account"];
    [MiPushSDK setAccount:account];
}

RCT_EXPORT_METHOD(unsetAccount:(NSDictionary *)param)
{
    NSString *account = (NSString *)param[@"account"];
    [MiPushSDK unsetAccount:account];
}

RCT_EXPORT_METHOD(setBadge:(NSNumber *)number)
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[number integerValue]];
}

RCT_EXPORT_METHOD(clearAllNotification)
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


RCT_EXPORT_METHOD(cancelLocalNotifications:(NSDictionary<NSString *, id> *)userInfo)
{
  for (UILocalNotification *notification in [UIApplication sharedApplication].scheduledLocalNotifications) {
    __block BOOL matchesAll = YES;
    NSDictionary<NSString *, id> *notificationInfo = notification.userInfo;
    // Note: we do this with a loop instead of just `isEqualToDictionary:`
    // because we only require that all specified userInfo values match the
    // notificationInfo values - notificationInfo may contain additional values
    // which we don't care about.
    [userInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
      if (![notificationInfo[key] isEqual:obj]) {
        matchesAll = NO;
        *stop = YES;
      }
    }];
    if (matchesAll) {
      [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
  }
}

- (void)miPushRequestSuccWithSelector:(NSString *)selector data:(NSDictionary *)data
{
    NSLog(@"data:%@", data);
    if ([selector isEqualToString:@"registerMiPush:"]) {
    }else if ([selector isEqualToString:@"registerApp"]) {
        // 获取regId
        NSLog(@"regid = %@", data[@"regid"]);
    }else if ([selector isEqualToString:@"bindDeviceToken:"]) {
        // 获取regId
        NSDictionary *ret = @{REGISTRATION_ID: data[@"regid"]};
        [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                            method:@"emit"
                              args:@[CONNECT_EVENT, ret]
                        completion:NULL];
    }else if ([selector isEqualToString:@"setAlias:"]) {
        // 设置别名
        NSDictionary *ret = @{ACTION: SET_ACTION, ALIAS: data[@"alias"]};
        [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                            method:@"emit"
                              args:@[ALIAS_EVENT, ret]
                        completion:NULL];
    }else if ([selector isEqualToString:@"unsetAlias:"]) {
        // 取消别名
        NSDictionary *ret = @{ACTION: UNSET_ACTION, ALIAS: data[@"alias"]};
        [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                            method:@"emit"
                              args:@[ALIAS_EVENT, ret]
                        completion:NULL];
    }else if ([selector isEqualToString:@"subscribe:"]) {
        NSDictionary *ret = @{ACTION: SET_ACTION, TAG: data[@"subscribe"]};
        [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                            method:@"emit"
                              args:@[TAG_EVENT, ret]
                        completion:NULL];
    }else if ([selector isEqualToString:@"unsubscribe:"]) {
        NSDictionary *ret = @{ACTION: UNSET_ACTION, TAG: data[@"subscribe"]};
        [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                            method:@"emit"
                              args:@[TAG_EVENT, ret]
                        completion:NULL];
    }else if ([selector isEqualToString:@"setAccount:"]) {
        NSDictionary *ret = @{ACTION: SET_ACTION, ACCOUNT: data[@"account"]};
        [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                            method:@"emit"
                              args:@[ACCOUNT_EVENT, ret]
                        completion:NULL];
    }else if ([selector isEqualToString:@"unsetAccount:"]) {
        NSDictionary *ret = @{ACTION: UNSET_ACTION, ACCOUNT: data[@"account"]};
        [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                            method:@"emit"
                              args:@[ACCOUNT_EVENT, ret]
                        completion:NULL];
    }else if ([selector isEqualToString:@"unregisterMiPush"]) {
    }
}

- (void)miPushRequestErrWithSelector:(NSString *)selector error:(int)error data:(NSDictionary *)data
{
    // 请求失败
    NSLog(@"error:%d", error);
}

- (void)miPushReceiveNotification:(NSDictionary *)data {
    NSLog(@"data2:%@", data);
}

+ (void)application:(id)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //[MiPushSDK registerMiPush:self type:0 connect:YES];
}

+ (void)application:(id)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //注册APNS成功, 注册deviceToken
    
    [MiPushSDK bindDeviceToken:deviceToken];
}

+ (void)application:(id)application didReceiveRemoteNotification:(NSDictionary *)notification {
    [MiPushSDK handleReceiveRemoteNotification:notification];
}

// 应用在前台收到通知
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
}

// 点击通知进入应用
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"xmpush_click" object:userInfo];
    completionHandler();
}

// 发送事件
- (void) handleSend:(NSNotification *)notification {
    [self sendEventWithName:notification.name body:notification.object];
}

- (void)startObserving
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSend:)
                                                 name:@"xmpush_click"
                                               object:nil];
}

- (void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//事件处理
- (NSArray<NSString *> *)supportedEvents
{
    return @[CONNECT_EVENT,NOTIFICATION_EVENT,NOTIFICATION_ARRIVED_EVENT,CUSTOM_MESSAGE_EVENT,TAG_EVENT,ALIAS_EVENT,ACCOUNT_EVENT];
}

@end
