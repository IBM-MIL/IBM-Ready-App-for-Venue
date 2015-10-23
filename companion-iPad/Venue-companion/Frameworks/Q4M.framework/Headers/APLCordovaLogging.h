//
//  APLCordovaLogging.h
//  Applause-iOS
//
//  Created by Łukasz Przytuła on 25.05.2015.
//  Copyright (c) 2015 Applause. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APLCordovaLogging <NSObject>

@property(nonatomic, strong) id commandDelegate;

- (instancetype)initWithWebView:(UIWebView *)theWebView;

- (void)start:(id)command;

- (void)log:(id)command;

- (void)report:(id)command;

- (void)feedback:(id)command;
- (void)sendFeedback:(id)command;

- (void)crash:(id)command;

@end
