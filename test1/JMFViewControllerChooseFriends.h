//
//  JMFViewControllerChooseFriends.h
//  test1
//
//  Created by Jean-Marie Ferdegue on 31/01/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMFAppDelegate.h"

@interface JMFViewControllerChooseFriends : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *pictureTitle;
- (IBAction)buttonTouched:(UIButton *)sender;
@end
