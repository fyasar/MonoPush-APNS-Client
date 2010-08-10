//
//  MPNotificationHandler.h
//  MonoPush APNS
//
//  Created by Fatih YASAR on 6/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MPNotification : NSObject {
	NSString *_appKey;
	NSString *_appSecret;
	NSString *_deviceToken;
	NSString *_deviceAlias;
}

@property (nonatomic, retain) NSString *_appKey;
@property (nonatomic, retain) NSString *_appSecret;
@property (nonatomic, retain) NSString *_deviceToken;
@property (nonatomic, retain) NSString *_deviceAlias;

- (void)RegisterDeviceWithToken:(NSData *)token;

+ (void)Init:(NSString *)appkey appSecret:(NSString *)secret;
+ (MPNotification *)shared;

@end

