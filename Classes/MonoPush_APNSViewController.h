//
//  MonoPush_APNSViewController.h
//  MonoPush APNS
//
//  Created by Fatih YASAR on 6/5/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonoPush_APNSViewController : UIViewController {
	NSString *deviceToken;
	IBOutlet UIImageView *backgroundImageView; 
	IBOutlet UITextView *infoDisplay;
}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UITextView *infoDisplay;
@property (nonatomic, retain) NSString *deviceToken;

- (void)setStatus;
- (IBAction)sendTest;


@end

