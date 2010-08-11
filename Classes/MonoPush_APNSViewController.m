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
#import "MPNotification.h"

@implementation MonoPush_APNSViewController
@synthesize infoDisplay, backgroundImageView, deviceToken;
@synthesize defaultInformation, soundInformation;
@synthesize deviceTokenRecievedLabel;
@synthesize deviceTokenRegisteredLabel;


- (void)viewDidLoad {
		[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
		
	self.defaultInformation = [NSString stringWithString:@"Welcome to MonoPush client example." 
							   "\nThis example app developed for that how to connect to MonoPush API via http request." 
							   "\nAs you can see the above icons shows you your app connection status."];
	
	self.soundInformation = [NSString stringWithString:@"You can customize sounds easyly." 
													   "\nWe included sample sound files into this app bundle, just add sound=\"sound.wav\" into your push request.\n" 
													   "- Incoming.wav\n"
													   "- yoda.wav\n"
													   "- dolfijn.wav\n"
													   "- kikker.wav\n"
													   "- tarzan.wav\n"
													   "- r2d2.wav"];
		
	[self setStatus:0];
	[self setTitle:@"MonoPush APNS"];
    [super viewDidLoad];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[backgroundImageView release];
	[deviceToken release];
	[infoDisplay release];
	[defaultInformation release];
    [soundInformation release];
    [deviceTokenRecievedLabel release];
    [deviceTokenRegisteredLabel release];
	[super dealloc];
}


- (void)setStatus:(int)statusMode {
	if(statusMode == 0) //defaul info
		infoDisplay.text = self.defaultInformation;
	else { //sound info
		infoDisplay.text = self.soundInformation;
	}
}

- (void)updateStatusIcons
{
	if([MPNotification shared].isDeviceTokenReceived)
	{
		deviceTokenRecievedLabel.text = @"OK";
		if([MPNotification shared].isDeviceTokenRegistered)
		{
			deviceTokenRegisteredLabel.text = @"OK";
		}else {
			deviceTokenRegisteredLabel.text = @"ERR";
		}		
	}else {
		deviceTokenRecievedLabel.text = @"ERR";
		deviceTokenRegisteredLabel.text = @"ERR";
	}
}

- (void)showSoundInformation
{
	[self setStatus:1];	
}

- (void)sendMeEmail
{
	if([MPNotification shared].isDeviceTokenReceived)
	{
		UIAlertView *notificationAlert = [[UIAlertView alloc] 
										  initWithTitle:@"Warning" 
										  message:@"Your device didn't get device token yet" 
										  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[notificationAlert show];
		[notificationAlert release];
		return;		
	}
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"About your device token"];
		
	NSString *emailBody = [NSString stringWithFormat:@"Hello,\n"
						   "Your device token is :%@\n"
						   "Thank you\n\n"
						   "MonoPush Example Client", self.deviceToken];
	
	[picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}


- (void)showInformation {
	[self setStatus:0];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}




@end
