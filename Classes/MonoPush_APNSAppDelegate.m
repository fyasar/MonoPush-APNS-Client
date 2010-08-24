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


//Add MonoPush main library refference
#import "MPNotification.h"

#import "MonoPush_APNSAppDelegate.h"
#import "MonoPush_APNSViewController.h"
#import "ASIFormDataRequest.h"
#import "DiscountCouponController.h"
#import "MovieController.h"

//Your Application key and application secret  
#define kApplicationKey @"<your app key>"
#define kApplicationSecret @"<your app secret>"


@implementation MonoPush_APNSAppDelegate

@synthesize window;
@synthesize defaultViewController;
@synthesize navigationController;
@synthesize discountCouponController;
@synthesize movieController;
@synthesize timer;
@synthesize countdownSeconds;

- (void)dealloc {
	[navigationController release];
	[discountCouponController release];
	[movieController release];
    [defaultViewController release];
    [timer release];
    [window release];
    [super dealloc];
}


- (void)viewDidLoad {
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent];
}

// When the application launch completed app delegate will be fire this event
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	self.countdownSeconds = 60;
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];	
	
	[window addSubview:navigationController.view];
	[self.navigationController setNavigationBarHidden:YES];
	
    [window makeKeyAndVisible];
	
	//** MonoPush MainLibrary: Initialize MonoPush's Notification wrapper
	[MPNotification Init:kApplicationKey appSecret:kApplicationSecret];
	[[MPNotification shared] setDelegate:self];
	
	//Register this application for notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(
									   UIRemoteNotificationTypeBadge |
									   UIRemoteNotificationTypeSound | 
									   UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
	
	//check remote notification enabled or not 
	if ([application enabledRemoteNotificationTypes] == 0) {
		NSLog(@"Notifications are disabled for this application.");
		return;
	}
	
	//** MonoPush MainLibrary: Register device to MonoPush server
	[[MPNotification shared] RegisterDeviceWithToken:_deviceToken];
	//[self startTimer];

	NSString *token = [[MPNotification shared] _deviceToken];
	NSString *tokenInfo = [NSString stringWithFormat:@"%@ device token received from Apple", token];
	NSLog(@"%@", tokenInfo);

	//Update UI View with the current token
	[MPNotification shared].isDeviceTokenReceived = YES;
	[((MonoPush_APNSViewController *)[navigationController topViewController]) updateStatusIcons]; 
	[((MonoPush_APNSViewController *)[navigationController topViewController]).infoDisplay setText:tokenInfo];
}

- (void)MPCommunicationDidFinish:(int)statusCode responseText:(NSString *)statusText
{
	if(statusCode != 200 && statusCode != 201) {
        [((MonoPush_APNSViewController *)[navigationController topViewController]) updateStatusIcons];
    }else {
		if(![statusText isEqualToString:@""])
			[((MonoPush_APNSViewController *)[navigationController topViewController]).infoDisplay setText:statusText];
		[((MonoPush_APNSViewController *)[navigationController topViewController]) updateStatusIcons]; 						
	}	
}

// When the remote notification failed app delegate will be fire this event
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	NSLog(@"error ocurred during registering remote notifications : %@", error);
	
	NSString *errorTitle = @"Error Ocurred";
	NSString *errorMessage = @"Ooops, error ocurred during registering remote notifications"
	"Please visit http://www.monopush.com/support site for solve this problem";
	
	UIAlertView *notificationRegistrationError = [[UIAlertView alloc] initWithTitle:errorTitle
													message:errorMessage
													delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles:nil
												  ];
	
	[notificationRegistrationError show];
	[notificationRegistrationError release];
	
	[[MPNotification shared] failedReceiveNotification:error];
	[MPNotification shared].isDeviceTokenReceived = NO;
	[((MonoPush_APNSViewController *)[navigationController topViewController]) updateStatusIcons]; 
	//update network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



//notification recieving
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"remote notification recieved: %@",[userInfo description]);    
	if([userInfo objectForKey:@"args"])
	{
		if([[userInfo objectForKey:@"args"] objectForKey:@"action"])
		{
			NSString *actionArgument = [[userInfo objectForKey:@"args"] objectForKey:@"action"];
			[NSTimer  scheduledTimerWithTimeInterval:1.0f
												target:self
												selector:@selector(ShowController:)
												userInfo:actionArgument
												repeats:NO];			
		}
	}

	NSString *notificationMessage = [userInfo descriptionWithLocale:nil indent:1];
	UIAlertView *notificationAlert = [[UIAlertView alloc] 
									  initWithTitle:@"Remote Notification Received" 
									  message:notificationMessage 
									  delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [notificationAlert show];
    [notificationAlert release];
	
	/*
	for (id key in userInfo) {
		NSDictionary *jsonkey = (NSDictionary *)key;
		NSLog(@"jsonkey : %@", jsonkey);
		if([jsonkey isEqual:@"action"])
		{
			NSString *controller = [userInfo objectForKey:@"action"];
			[NSTimer  scheduledTimerWithTimeInterval:1.0f
											  target:self
											selector:@selector(ShowController:)
											userInfo:controller
											 repeats:NO];
			
			break;
		}
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    } 
	 */
	

}


- (void)applicationWillTerminate:(UIApplication *)application {
    [MPNotification dispose];
}


- (void)ShowController:(NSTimer *)theTimer {
	NSString *theControllerName = (NSString *)[theTimer userInfo];
	if([theControllerName isEqual:@"discount-coupon"])
	{
		[self OpenDiscountCoupon];	
		
	}else if ([theControllerName isEqual:@"video"]) {
		[self OpenMovie];
	}
}


//Show the movie viewcontroller
- (void)OpenMovie
{
	MovieController *movie = [[MovieController alloc] initWithNibName:@"MovieController" bundle:nil];
	self.movieController = movie;
	[movie release];
	
	
	[self.navigationController pushViewController:self.movieController animated:YES];
}

//Show discount coupon view controller
- (void)OpenDiscountCoupon
{
	DiscountCouponController *discountCoupon = [[DiscountCouponController alloc] initWithNibName:@"DiscountCouponController" bundle:nil];
	self.discountCouponController = discountCoupon;
	[discountCoupon release];
	
	[self.navigationController pushViewController:self.discountCouponController animated:YES];
}




@end
