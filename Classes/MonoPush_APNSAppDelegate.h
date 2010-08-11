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

#import <UIKit/UIKit.h>

#import "DiscountCouponController.h"
#import "MovieController.h"

@class MonoPush_APNSViewController;

@interface MonoPush_APNSAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MonoPush_APNSViewController *defaultViewController;	
	DiscountCouponController *discountCouponController; 
	MovieController *movieController; 
	UINavigationController *navigationController;
	NSTimer* timer;
	int countdownSeconds;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MonoPush_APNSViewController *defaultViewController;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) NSTimer *timer;
@property int countdownSeconds;

//Utility controllers
//These controllers will be open when the arguments received via push notification
@property (nonatomic, retain) DiscountCouponController *discountCouponController; 
@property (nonatomic, retain) MovieController *movieController;

- (void)startTimer;
- (void)timerTick;
- (void)OpenMovie;
- (void)OpenDiscountCoupon;
@end

