//
//  SelectAFriendTableViewController.h
//  test1
//
//  Created by Jean-Marie Ferdegue on 11/02/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMFAppDelegate.h"

@interface SelectAFriendTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) NSArray *friendsArray;
@property (strong,nonatomic) NSMutableArray *filteredFriendsArray;
@property IBOutlet UISearchBar *friendsSearchBar;
@end
