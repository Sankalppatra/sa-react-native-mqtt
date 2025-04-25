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
@property (nonatomic, strong) NSMutableDictionary<NSString *, Mqtt *> *clients;
@end


@implementation RCTMqtt
{
    BOOL hasListeners;
}

RCT_EXPORT_MODULE(RCTMqtt)


+ (BOOL) requiresMainQueueSetup{
    return NO;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _clients = [[NSMutableDictionary alloc] init];
        hasListeners = NO;
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
    
    NSString *clientRef = [[NSProcessInfo processInfo] globallyUniqueString];
    
    Mqtt *client = [[Mqtt alloc] initWithEmitter:self options:options clientRef:clientRef];
    
    if (client) {
        self.clients[clientRef] = client;
        resolve(clientRef);
    } else {
        NSError *error = [NSError errorWithDomain:@"com.kuhmute.kca" 
                                            code:500 
                                        userInfo:@{@"Error reason": @"Failed to create MQTT client"}];
        reject(@"client_creation_failed", @"Failed to create MQTT client", error);
    }
}

RCT_EXPORT_METHOD(removeClient:(NSString *) clientRef) {
    [self.clients removeObjectForKey:clientRef];
}


RCT_EXPORT_METHOD(connect:(NSString *) clientRef) {
    [self.clients[clientRef] connect];
}

RCT_EXPORT_METHOD(disconnect:(NSString *) clientRef) {
    [self.clients[clientRef] disconnect];
}

RCT_EXPORT_METHOD(isConnected:(NSString *) clientRef resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    //RCTLogInfo(@"Bridge handling call to core for isConnected");
    Mqtt *client = self.clients[clientRef];
    if (client) {
        BOOL conn = [client isConnected];
        //RCTLogInfo(@"Client: %@ isConnected: %s", clientRef, conn ? "true" : "false");
        resolve(@(conn));
    } else {
        NSError *error = [NSError errorWithDomain:@"com.kuhmute.kca" 
                                            code:404 
                                        userInfo:@{@"Error reason": @"Client Not Found"}];
        reject(@"client_not_found", @"This client doesn't exist", error);
    }
}

RCT_EXPORT_METHOD(isSubbed:(NSString *) clientRef topic:(NSString*)topic resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    //RCTLogInfo(@"Bridge handling call to core for topic: %@", topic);
    Mqtt *client = self.clients[clientRef];
    if (client) {
        BOOL subbed = [client isSubbed:topic];
        //RCTLogInfo(@"Client: %@ isSubbed: %s", clientRef, subbed ? "true" : "false");
        resolve(@(subbed));
    } else {
        
        NSError *error = [NSError errorWithDomain:@"com.kuhmute.kca" 
                                            code:404 
                                        userInfo:@{@"Error reason": @"Client Not Found"}];
        reject(@"client_not_found", @"This client doesn't exist", error);
    }
}

RCT_EXPORT_METHOD(getTopics:(NSString *) clientRef resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    //RCTLogInfo(@"Bridge handling call to core for client: %@", clientRef);
    Mqtt *client = self.clients[clientRef];
    if (client) {
        NSMutableArray *ret = [client getTopics];
        //RCTLogInfo(@"Client: %@ topics: %@", clientRef, ret);
        resolve(ret);
    } else {
        NSError *error = [NSError errorWithDomain:@"com.kuhmute.kca" 
                                            code:404 
                                        userInfo:@{@"Error reason": @"Client Not Found"}];
        reject(@"client_not_found", @"This client doesn't exist", error);
    }
}



RCT_EXPORT_METHOD(disconnectAll) {
    for (Mqtt *client in self.clients.allValues) {
        [client disconnect];
    }
    [self.clients removeAllObjects];
}

RCT_EXPORT_METHOD(subscribe:(NSString *) clientRef topic:(NSString *)topic qos:(NSNumber *)qos) {
    [self.clients[clientRef] subscribe:topic qos:qos];
}

RCT_EXPORT_METHOD(unsubscribe:(NSString *) clientRef topic:(NSString *)topic) {
    [self.clients[clientRef] unsubscribe:topic];
}

RCT_EXPORT_METHOD(publish:(NSString *) clientRef topic:(NSString *)topic data:(NSString*)data qos:(NSNumber *)qos retain:(BOOL)retain) {
    [self.clients[clientRef] publish:topic
                               data:[data dataUsingEncoding:NSUTF8StringEncoding]
                                qos:qos
                             retain:retain];
    
}

- (void)invalidate
{
    [self disconnectAll];
    [super invalidate];
}

- (void)dealloc
{
    [self disconnectAll];
}

@end