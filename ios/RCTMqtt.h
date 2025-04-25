//
//  RCTMqtt.h
//  RCTMqtt
//
//  Created by Tuan PM on 2/2/16.
//  Copyright © 2016 Tuan PM. All rights reserved.
//  Updated by Scott Spitler of KUHMUTE on 03/01/2021.
//  Copyright © 2021 Scott Spitler. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTMqtt : RCTEventEmitter <RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END