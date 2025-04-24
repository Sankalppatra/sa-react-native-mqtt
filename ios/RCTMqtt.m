//
//  RCTMqtt.m
//  RCTMqtt
//
//  Created by Tuan PM on 2/2/16.
//  Copyright © 2016 Tuan PM. All rights reserved.
//  Updated by Scott Spitler of KUHMUTE on 03/01/2021.
//  Copyright © 2021 Scott Spitler. All rights reserved.
//
//Package dependencies
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/RCTEventDispatcher.h>
//Project imports
#import "RCTMqtt.h"
#import "Mqtt.h"



@interface RCTMqtt ()
@property NSMutableDictionary *clients;
@end


@implementation RCTMqtt
{
    bool hasListeners;
}

RCT_EXPORT_MODULE();


+ (BOOL) requiresMainQueueSetup{
    return NO;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _clients = [[NSMutableDictionary alloc] init];
    }
    return self;
    
}


- (void)sendEventWithName:(NSString *)name body:(id)body {
    if (hasListeners && self.bridge) { // Only send events if anyone is listening
        [super sendEventWithName:name body:body];
    }
}

- (NSArray<NSString *> *)supportedEvents {
    return @[ @"mqtt_events" ];
}

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
    // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
    // Remove upstream listeners, stop unnecessary background tasks
}

RCT_EXPORT_METHOD(createClient:(NSDictionary *) options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSString *clientRef = [[NSUUID UUID] UUIDString];
    
    Mqtt *client = [[Mqtt alloc] initWithEmitter:self clientRef:clientRef];
    
    [[self clients] setObject:client forKey:clientRef];
    resolve(clientRef);
    
}

RCT_EXPORT_METHOD(removeClient:(nonnull NSString *) clientRef) {
    [[self clients] removeObjectForKey:clientRef];
}


RCT_EXPORT_METHOD(connect:(NSString *)clientRef
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    Mqtt *client = [[self clients] objectForKey:clientRef];
    if (!client) {
        reject(@"client_not_found", @"Client not found", nil);
        return;
    }
    [client connectWithOptions:options resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(disconnect:(NSString *)clientRef
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    Mqtt *client = [[self clients] objectForKey:clientRef];
    if (!client) {
        reject(@"client_not_found", @"Client not found", nil);
        return;
    }
    [client disconnectWithResolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(isConnected:(nonnull NSString *) clientRef resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    //RCTLogInfo(@"Bridge handling call to core for isConnected");
    if([[self clients] objectForKey:clientRef]) {
        BOOL conn = [[[self clients] objectForKey:clientRef] isConnected];
        //RCTLogInfo(@"Client: %@ isConnected: %s", clientRef, conn ? "true" : "false");
        resolve(@(conn));
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"com.kuhmute.kca" code:404 userInfo:@{@"Error reason": @"Client Not Found"}];
        reject(@"client_not_found", @"This client doesn't exist", error);
    }
}

RCT_EXPORT_METHOD(isSubbed:(nonnull NSString *) clientRef:(nonnull NSString*)topic resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    //RCTLogInfo(@"Bridge handling call to core for topic: %@", topic);
    if([[self clients] objectForKey:clientRef]) {
        BOOL subbed = [[[self clients] objectForKey:clientRef] isSubbed:clientRef];
        //RCTLogInfo(@"Client: %@ isSubbed: %s", clientRef, subbed ? "true" : "false");
        resolve(@(subbed));
    } else {
        
        NSError *error = [[NSError alloc] initWithDomain:@"com.kuhmute.kca" code:404 userInfo:@{@"Error reason": @"Client Not Found"}];
        reject(@"client_not_found", @"This client doesn't exist", error);
    }
}

RCT_EXPORT_METHOD(getTopics:(nonnull NSString *) clientRef resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    //RCTLogInfo(@"Bridge handling call to core for client: %@", clientRef);
    if([[self clients] objectForKey:clientRef]) {
        NSMutableArray *ret = [[[self clients] objectForKey:clientRef] getTopics];
        //RCTLogInfo(@"Client: %@ topics: %@", clientRef, ret);
        resolve(ret);
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"com.kuhmute.kca" code:404 userInfo:@{@"Error reason": @"Client Not Found"}];
        reject(@"client_not_found", @"This client doesn't exist", error);
    }
}



RCT_EXPORT_METHOD(disconnectAll) {
    if (self.clients.count > 0) {
        for(NSString* aClientRef in self.clients) {
            [[[self clients] objectForKey:aClientRef] disconnect];
        }
    }
}

RCT_EXPORT_METHOD(subscribe:(NSString *)clientRef
                  topic:(NSString *)topic
                  qos:(NSInteger)qos
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    Mqtt *client = [[self clients] objectForKey:clientRef];
    if (!client) {
        reject(@"client_not_found", @"Client not found", nil);
        return;
    }
    [client subscribe:topic qos:qos resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(unsubscribe:(NSString *)clientRef
                  topic:(NSString *)topic
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    Mqtt *client = [[self clients] objectForKey:clientRef];
    if (!client) {
        reject(@"client_not_found", @"Client not found", nil);
        return;
    }
    [client unsubscribe:topic resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(publish:(NSString *)clientRef
                  topic:(NSString *)topic
                  payload:(NSString *)payload
                  qos:(NSInteger)qos
                  retain:(BOOL)retain
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    Mqtt *client = [[self clients] objectForKey:clientRef];
    if (!client) {
        reject(@"client_not_found", @"Client not found", nil);
        return;
    }
    [client publish:topic payload:payload qos:qos retain:retain resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(close:(NSString *)clientRef
                  force:(BOOL)force
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    Mqtt *client = [[self clients] objectForKey:clientRef];
    if (!client) {
        reject(@"client_not_found", @"Client not found", nil);
        return;
    }
    [client close:force resolver:resolve rejecter:reject];
    [[self clients] removeObjectForKey:clientRef];
}

- (void)invalidate
{
    [self disconnectAll];
}

- (void)dealloc
{
}

@end
