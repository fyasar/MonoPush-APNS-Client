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


#import "MonoPush_APNSViewController.h"
#import "ASIFormDataRequest.h"

#define kApplicationKey @"f73c85b2-bf63-4278-9f13-9d8e00bfc9b9"
#define kApplicationSecret @"42acdd7b-49f7-4230-86a8-5eb6b49a9523"

@implementation MonoPush_APNSViewController
@synthesize infoDisplay, backgroundImageView, deviceToken;

- (void)viewDidLoad {
		[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
	[self setStatus];
	[self setTitle:@"MonoPush APNS"];
    [super viewDidLoad];
}

-(void)sendTest
{
	/*
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	NSString *UAServer = @"http://app.monopush.com/api/device/register";
	//NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", UAServer, @"/api/device_tokens/", self.deviceToken];
	NSURL *url = [NSURL URLWithString:  UAServer];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	request.requestMethod = @"POST";
	
	// Send along our device alias as the JSON encoded request body
	//if(self.deviceAlias != nil && [self.deviceAlias length] > 0) {
	[request addRequestHeader: @"Content-Type" value: @"application/json"];
	[request appendPostData:[[NSString stringWithFormat: @"{\"tokens\": [\"%@\"]}", [userDefaults valueForKey:@"_UALastDeviceToken"]]
							 dataUsingEncoding:NSUTF8StringEncoding]];
	//}
	
	[request addRequestHeader:@"ApplicationKey" value:@"cf1c291a-36c8-4411-81d1-9d8d012c1ee6"];
	[request addRequestHeader:@"ApplicationSecret" value:@"aad41e50-61e4-4db0-8282-cf351927340e"];
	
	// Authenticate to the server
	request.username = kApplicationKey;
	request.password = kApplicationSecret;
	
	[request setDelegate:self];
	[request setDidFinishSelector: @selector(successMethod:)];
	[request setDidFailSelector: @selector(requestWentWrong:)];
	[queue addOperation:request];
	 */
}



- (void)setStatus {
	/*
	NSString *model = [[UIDevice currentDevice] model];
	if ([[[NSBundle mainBundle] bundleIdentifier] compare: @"com.urbanairship.pushtest"] == NSOrderedSame) {
		NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
		NSLog(identifier);
		
		[infoDisplay setText: @"ERROR: Invalid bundle identifier."
		 " Please change your bundle identifier in APNS-info.plist to the one you specified in the "
		 "Apple iPhone Developer Portal.\n\nIt should be something like: "
		 "com.example.yourapp"];
	} else if ([model compare: @"iPhone Simulator"] == NSOrderedSame) {
		[infoDisplay setText: @"ERROR: Remote notifications are not supported in the simulator."];
	}
	self._info = [infoDisplay text];
*/
}


- (void)successMethod:(ASIHTTPRequest *) request {
	//[userDefaults setValue: self.deviceToken forKey: @"_UALastDeviceToken"];
	//[userDefaults setValue: self.deviceAlias forKey: @"_UALastAlias"];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[infoDisplay setText: @"Echo was send to API server."];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSError *error = [request error];
	UIAlertView *someError = [[UIAlertView alloc] initWithTitle: 
							  @"Network error" message: @"Error registering with server"
													   delegate: self
											  cancelButtonTitle: @"Ok"
											  otherButtonTitles: nil];
	[someError show];
	[someError release];
	NSLog(@"ERROR: NSError query result: %@", error);
}


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[backgroundImageView release];
	[deviceToken release];
	[infoDisplay release];
    [super dealloc];
}

@end
