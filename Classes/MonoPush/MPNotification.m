//
//  MPNotificationHandler.m
//  MonoPush APNS
//
//  Created by Fatih YASAR on 6/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPNotification.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"



@implementation MPNotification

static MPNotification *_mpNotificationInstance;
		
@synthesize _appKey;
@synthesize _appSecret;
@synthesize _deviceToken;
@synthesize _deviceAlias;

- (void)dealloc {
	[_appKey release];
	[_appSecret release];
	[_deviceToken release];
	[_deviceAlias release];
    [super dealloc];
}

- (id)initWithId:(NSString *)appkey appSecret:(NSString *)secret {
    if (self = [super init]) {
        self._appKey = appkey;
        self._appSecret = secret;
        self._deviceToken = nil;
        self._deviceAlias = nil;
    }
    return self;
}

+ (void)Init:(NSString *)appkey appSecret:(NSString *)appSecret
{
	@synchronized(self)
	{
		if (!_mpNotificationInstance) {
			_mpNotificationInstance = [[MPNotification alloc] initWithId:appkey appSecret:appSecret];
		}		
	}	
}


- (void)RegisterDeviceWithToken:(NSData *)deviceToken
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	//pick device token
    self._deviceToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
						  stringByReplacingOccurrencesOfString:@">" withString:@""]
						 stringByReplacingOccurrencesOfString: @" " withString: @""];
		
	
	 //get the preferred language
	 NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	 NSArray* languages = [defs objectForKey:@"AppleLanguages"];
	 NSString* preferredLang = [languages objectAtIndex:0];
	 
	 UIDevice *dev = [UIDevice currentDevice];
	 NSString *deviceUuid = dev.uniqueIdentifier;
	 NSString *deviceName = dev.name;
	 NSString *deviceModel = dev.model;
	 NSString *deviceSystemVersion = dev.systemVersion;
	 NSString *deviceSystemName = dev.systemName;
	
	//Build register device json payload
	NSMutableDictionary* jsonObject = [NSMutableDictionary dictionary];
	[jsonObject setObject:self._deviceToken forKey:@"token"];
	[jsonObject setObject:deviceUuid forKey:@"udid"];
	[jsonObject setObject:preferredLang forKey:@"preferedlanguage"];
	[jsonObject setObject:deviceName forKey:@"devicename"];
	[jsonObject setObject:deviceModel forKey:@"devicemodel"];
	[jsonObject setObject:deviceSystemVersion forKey:@"systemver"];
	[jsonObject setObject:deviceSystemName forKey:@"systemos"];

	NSString *jsonPayloadString = [jsonObject JSONRepresentation];
	NSLog(@"json payload : %@", jsonPayloadString );
	
	NSURL *url = [NSURL URLWithString:@"http://app.monopush.com/api/device/register"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	
	[request setUsername:_mpNotificationInstance._appKey];
	[request setPassword:_mpNotificationInstance._appSecret];
	[request setRequestMethod:@"PUT"];
	
	[request addRequestHeader: @"Content-Type" value: @"application/json"];
	[request appendPostData:[jsonPayloadString
							 dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setDelegate:self];
	[request startAsynchronous];
		
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// Use when fetching text data
	//NSString *responseString = [request responseString];	
	// Use when fetching binary data
	//NSData *responseData = [request responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	//NSError *error = [request error];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


+(MPNotification *)shared
{
    if (_mpNotificationInstance == nil) {
        [NSException raise:@"InstanceNotExists" format:@"Attempted to access instance before initializaion."];
    }
    return _mpNotificationInstance;	
}







@end
