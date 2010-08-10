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

#import "MonoPush_APNSAppDelegate.h"
#import "MonoPush_APNSViewController.h"
#import "ASIFormDataRequest.h"
#import "DiscountCouponController.h"
#import "MovieController.h"

#define ApplicationKey @"f73c85b2-bf63-4278-9f13-9d8e00bfc9b9"
#define ApplicationSecret @"42acdd7b-49f7-4230-86a8-5eb6b49a9523"

@implementation MonoPush_APNSAppDelegate

@synthesize window;
@synthesize defaultViewController;
@synthesize navigationController;
@synthesize discountCouponController;
@synthesize movieController;

- (void)dealloc {
	[navigationController release];
	[discountCouponController release];
	[movieController release];
    [defaultViewController release];
    [window release];
    [super dealloc];
}


- (void)viewDidLoad {
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	//hide statusbar for main page 
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];	
	
	//add navcontroller default view to 
	[window addSubview:navigationController.view];
	[self.navigationController setNavigationBarHidden:YES];
	
    [window makeKeyAndVisible];
	
	//NSLog(@"%@", ((MonoPush_APNSViewController *)[navigationController topViewController]).deviceToken);
	//Initialize MonoPush Notification wrapper
	[MPNotification Init:ApplicationKey appSecret:ApplicationSecret];
	
	//Register for notifications
	[[UIApplication sharedApplication]
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
										 UIRemoteNotificationTypeSound |
										 UIRemoteNotificationTypeAlert)];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
	
	if ([application enabledRemoteNotificationTypes] == 0) {
		NSLog(@"Notifications are disabled for this application.");
		return;
	}
	
	//Register device to MonoPush server
	[[MPNotification shared] RegisterDeviceWithToken:_deviceToken];
	

	NSString *token = [[MPNotification shared] _deviceToken];
	NSString *tokenInfo = [NSString stringWithFormat:@"Received device token : %@", token];
	//Update View with the current token

	[((MonoPush_APNSViewController *)[navigationController topViewController]).infoDisplay setText:tokenInfo]; 
		
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //self.deviceAlias = [userDefaults stringForKey: @"_UADeviceAliasKey"];		
	
}



- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	NSLog(@"error ocurred during registering remote notifications : %@", error);
	
	NSString *errorTitle = @"Error Ocurred";
	NSString *errorMessage = @"Ops, error ocurred during registering remote notifications"
	"Please check the http://www.monopush.com/support support site for solve this problem";
	
	UIAlertView *notificationRegistrationError = [[UIAlertView alloc] initWithTitle:errorTitle
																			message:errorMessage
																		   delegate:nil
																  cancelButtonTitle:@"OK"
																  otherButtonTitles:nil];
	
	[notificationRegistrationError show];
	[notificationRegistrationError release];
	
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
