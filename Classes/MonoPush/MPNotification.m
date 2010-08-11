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
@synthesize _lastError;

@synthesize isDeviceTokenReceived;
@synthesize isDeviceTokenRegistered;

- (void)dealloc {
	[_appKey release];
	[_appSecret release];
	[_deviceToken release];
	[_deviceAlias release];
	[_lastError release];
    [super dealloc];
}

+(void)dispose {
    [_mpNotificationInstance release];
    _mpNotificationInstance = nil;
}


- (id)initWithId:(NSString *)appkey appSecret:(NSString *)secret {
    if (self = [super init]) {
        self._appKey = appkey;
        self._appSecret = secret;
        self._deviceToken = nil;
        self._deviceAlias = nil;
		self._lastError = nil;
		self.isDeviceTokenReceived = NO;
		self.isDeviceTokenRegistered = NO;
    }
    return self;
}

+ (void)Init:(NSString *)appkey appSecret:(NSString *)appSecret
{
	[self EnsureRunningInDevice];
	
	@synchronized(self)
	{
		if (!_mpNotificationInstance) {
			_mpNotificationInstance = [[MPNotification alloc] initWithId:appkey appSecret:appSecret];
		}		
	}	
}

//is device running into simulator ?
+ (void)EnsureRunningInDevice
{
		if ([[[UIDevice currentDevice] model] compare:@"iPhone Simulator"] == NSOrderedSame) {
			UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Warning"
																message:@"Application running in simulator, you cannot receive any notification on this mode"
															   delegate:self
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			
			[someError show];
			[someError release];
		}
}

// Register current device to MonoPush via API  
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
	 
	 //these information should provide to MonoPush 
	 //Otherwise, you cannot see many reports correctly
	 UIDevice *dev = [UIDevice currentDevice];
	 NSString *deviceUuid = dev.uniqueIdentifier;
	 NSString *deviceName = dev.name;
	 NSString *deviceModel = dev.model;
	 NSString *deviceSystemVersion = dev.systemVersion;
	 NSString *deviceSystemName = dev.systemName;
	
	//Build register device json payload
	NSMutableDictionary* jsonObject = [NSMutableDictionary dictionary];
	[jsonObject setObject:deviceUuid forKey:@"udid"];
	[jsonObject setObject:preferredLang forKey:@"preferedlanguage"];
	[jsonObject setObject:deviceName forKey:@"devicename"];
	[jsonObject setObject:deviceModel forKey:@"devicemodel"];
	[jsonObject setObject:deviceSystemVersion forKey:@"systemver"];
	[jsonObject setObject:deviceSystemName forKey:@"systemos"];

	NSString *jsonPayloadString = [jsonObject JSONRepresentation];
	NSLog(@"json payload : %@", jsonPayloadString );
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://app.monopush.com/api/device/register/%@", self._deviceToken]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	
	[request setUsername:_mpNotificationInstance._appKey];
	[request setPassword:_mpNotificationInstance._appSecret];
	[request setRequestMethod:@"PUT"];
	[request addRequestHeader: @"Content-Type" value: @"application/json"];
	[request appendPostData:[jsonPayloadString
							 dataUsingEncoding:NSUTF8StringEncoding]];
	
	request.timeOutSeconds = 60;
	[request setDelegate:self];
	[request startAsynchronous];
		
}

- (void)failedReceiveNotification:(NSError*)error
{
	self.isDeviceTokenReceived = NO;
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	
	
	
	//grap responsed data
	int statusCode = [request responseStatusCode];
	NSString *statusText = [request responseString];	
	
	if(statusCode != 200 && statusCode != 201) {
        NSLog(@"Error registering device token, statusCode :%d, statusText :%@", statusCode, statusText);
		self._lastError = statusText;
    }else {
		self.isDeviceTokenRegistered = YES;
        NSLog(@"Device token registered, statusCode :%d, statusText :%@", statusCode, statusText);
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{	
	//grap responsed data
	int statusCode = [request responseStatusCode];
	NSString *statusText = [request responseString];	
	
	NSError *error = [request error];
	NSLog(@"Http request error : %@", error);
	NSLog(@"Error registering device token, statusCode :%d, statusText :%@", statusCode, statusText);
	self._lastError = statusText;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


+ (MPNotification *)shared
{
    if (_mpNotificationInstance == nil) {
        [NSException raise:@"InstanceNotExists" format:@"Attempted to access instance before initializaion."];
    }
    return _mpNotificationInstance;	
}







@end
