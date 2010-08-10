// Copyright (c) 1999 Sky Technologies Ltd. <support@monopush.com>
// All Rights Reserved.

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation 
// and/or other materials provided with the distribution.

// THIS SOFTWARE IS PROVIDED BY SKY TECHNOLOGIES LTD AND CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
// BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
// IN NO EVENT SHALL SKY TECHNOLOGIES LTD OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

/******************************************************************************/
// WARNING: Anything below could change without warning in future versions if
// submit patches to support@monopush.com or send us a pull request on
// http://github.com/fyasar/MonoPush-APNS-Client
/******************************************************************************/


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
