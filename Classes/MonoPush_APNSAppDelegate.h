//
//  MonoPush_APNSAppDelegate.h
//  MonoPush APNS
//
//  Created by Fatih YASAR on 6/5/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

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
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MonoPush_APNSViewController *defaultViewController;
@property (nonatomic, retain) DiscountCouponController *discountCouponController; 
@property (nonatomic, retain) MovieController *movieController;
@property (nonatomic, retain) UINavigationController *navigationController;

- (void)OpenMovie;
- (void)OpenDiscountCoupon;
@end

