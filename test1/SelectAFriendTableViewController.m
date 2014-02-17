//
//  SelectAFriendTableViewController.m
//  test1
//
//  Created by Jean-Marie Ferdegue on 11/02/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import "SelectAFriendTableViewController.h"
#import "Friends.h"
#import "JMFFakeContact.h"
#import <AddressBookUI/AddressBookUI.h>
#import "FacebookSDK/FBLoginView.h"

@interface SelectAFriendTableViewController ()

@end

@implementation SelectAFriendTableViewController
@synthesize friendsArray;
@synthesize filteredFriendsArray;
@synthesize friendsSearchBar;
@synthesize addressBookAlreadyLoaded;
NSString *const messageToConnectAddressBook = @"Import from Phonebook";
NSString *const messageToConnectFacebook = @"Import from Facebook";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self updateDataSource];
    JMFAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotificationOfNewContactsAdded:) name:@"com.razeware.test1.newcontactsadded" object:nil];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [filteredFriendsArray count];
    } else {
        return [friendsArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Create a new Candy Object
    Friends *aFriend = nil;
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        aFriend = [filteredFriendsArray objectAtIndex:indexPath.row];
    } else {
        aFriend = [friendsArray objectAtIndex:indexPath.row];
    }
//    aFriend = [friendsArray objectAtIndex:indexPath.row];
    // Configure the cell
    cell.textLabel.text = aFriend.name;
    cell.imageView.image = [UIImage imageWithData:aFriend.image];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredFriendsArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
    NSArray *tempArray = [friendsArray filteredArrayUsingPredicate:predicate];
    if (![scope isEqualToString:@"All"]) {
        // Further filter the array with the scope
        NSPredicate *scopePredicate;
        if ([scope isEqualToString:@"Phone"]) {
            scopePredicate = [NSPredicate predicateWithFormat:@"category contains[c] %@",@"AddressBook"];
        } else if ([scope isEqualToString:@"Facebook"]) {
            scopePredicate = [NSPredicate predicateWithFormat:@"facebookUser <> nil"];
        } else {
            NSLog(@"Filter scope %@ is unsupported", scope);
        }
        
        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
    }
    NSString* myNewString = [NSString stringWithFormat:@"%i", [tempArray count]];
    NSLog(@"%@", myNewString);
    filteredFriendsArray = [NSMutableArray arrayWithArray:tempArray];
    NSLog(@"results filtered %@", searchText);
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Utilities
// Add new method
- (void)receivedNotificationOfNewContactsAdded:(NSNotification *)notif {
    [self updateDataSource];
    // Reload the table
    [self.tableView reloadData];
}

- (void)updateDataSource
{
    JMFAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Friends" inManagedObjectContext:context];
    
    // Are there any contacts with a category of AddressBook. If so, that means the app has already had the right permissions to get the contacts
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == 'AddressBook'"];
    NSFetchRequest *requestObjectsFromAddressBook = [[NSFetchRequest alloc] init];
    [requestObjectsFromAddressBook setPredicate:predicate];
    [requestObjectsFromAddressBook setEntity:entityDescription];
    NSArray *arrayObjectsFromAddressBook = [context executeFetchRequest:requestObjectsFromAddressBook error:&error];
    NSUInteger *countOfObjectsFromAddressBook = [arrayObjectsFromAddressBook count];
    if (countOfObjectsFromAddressBook>0) {
        self.addressBookAlreadyLoaded = YES;
        [self retrieveContactsFromAddressBookIntoCoreData];
    } else {
        self.addressBookAlreadyLoaded = NO;
    }
    
    
    
    //    Friends *aFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
    //    aFriend.name = @"Lisa Cachou";
    //    aFriend.category = @"Facebook";
    
    //    if ([aFriend.managedObjectContext save:&error]) {
    //        NSLog(@"No error when saving the object");
    //    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *array = [context executeFetchRequest:request error:&error];
    //    friendsArray = [NSArray arrayWithObject:[JMFFriends friendOfCategory:@"Contacts" name:@"Add a friends from your contacts"]];
    //    friendsArray = array;
    friendsArray = [[NSMutableArray alloc] init];
    if (self.addressBookAlreadyLoaded == NO) {
        JMFFakeContact *aFakeContact = [JMFFakeContact setCategoryAndName:@"AddressBook" name:messageToConnectAddressBook];
        [friendsArray addObject:aFakeContact];
    }
    if (!(appDelegate.facebookLoggedIn)) {
        JMFFakeContact *fbFakeContact = [JMFFakeContact setCategoryAndName:@"Facebook" name:messageToConnectFacebook];
        fbFakeContact.facebookUser = @"123";
        [friendsArray addObject:fbFakeContact];
    }
    
    [friendsArray addObjectsFromArray:array];
    self.filteredFriendsArray = [NSMutableArray arrayWithCapacity:[friendsArray count]];
}

- (void)retrieveContactsFromFacebbokIntoCoreData
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             JMFAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}

- (void)retrieveContactsFromAddressBookIntoCoreData
{
    NSLog(@"Retrieving objects from the user address book");
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef peopleRef = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSArray *people = CFBridgingRelease(peopleRef); // No need to CFRelease peopleRef... CFBridgingRelease() transfers it to ARC
    
    JMFAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error = nil; // Always good practice to initialise everything
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Friends" inManagedObjectContext:context];
    
    
    for (int i = 0; i < people.count; i++) {
        // You've used (__bridge ABRecordRef) correctly here... you don't want to
        // change the retain/release count. Well done.
        ABRecordRef aPerson = (__bridge ABRecordRef)([people objectAtIndex:i]);
        
        // Retrieve the facebook user name from an existing contact
        NSString *facebookProfile = nil;
        ABMultiValueRef profile = ABRecordCopyValue(aPerson,  kABPersonInstantMessageProperty);
        if (ABMultiValueGetCount(profile) > 0)
        {
            // collect all emails in array
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(profile); i++)
            {
                NSDictionary *socialItem = (__bridge NSDictionary*)ABMultiValueCopyValueAtIndex(profile, i);
                NSString* SocialLabel =  [socialItem objectForKey:(NSString *)kABPersonInstantMessageServiceKey];
                
                if([SocialLabel isEqualToString:(NSString *)kABPersonInstantMessageServiceFacebook])
                {
                    facebookProfile = ([socialItem objectForKey:(NSString *)kABPersonInstantMessageUsernameKey]);
                    NSLog(@"fbName %@",facebookProfile);
                    
                }
                
            }
            CFRelease(profile);
        }
        
        // in some cases, iOS does not store the Facebook info of a profile into kABPersonInstantMessageServiceKey but in kABPersonSocialProfileProperty instead
        // code inspired from http://stackoverflow.com/questions/14507638/unable-to-get-facebook-profiles-from-abaddressbook-in-ios6
        if (facebookProfile == nil) {
            NSArray *linkedPeople = (__bridge_transfer NSArray *)ABPersonCopyArrayOfAllLinkedPeople (aPerson);
            for (int x = 0; x < [linkedPeople count]; x++)
            {
                ABMultiValueRef socialApps = ABRecordCopyValue((__bridge ABRecordRef)[linkedPeople objectAtIndex:x], kABPersonSocialProfileProperty);
                CFIndex thisSocialAppCount = ABMultiValueGetCount(socialApps);
                for (int i = 0; i < thisSocialAppCount; i++)
                {
                    NSDictionary *socialItem = (__bridge_transfer NSDictionary*)ABMultiValueCopyValueAtIndex(socialApps, i);
                    facebookProfile = [socialItem valueForKey:@"username"];
                }
                if (socialApps != Nil)
                    CFRelease(socialApps);
            }
        }
        // Is there an object already existing with this id
        NSFetchRequest *request = [[NSFetchRequest alloc] init]; //request that will be used to ensure there is not already an object with this id
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(iosABrecordId == %@) OR (facebookUser == %@ AND facebookUser <> nil)", [NSNumber numberWithInteger:ABRecordGetRecordID(aPerson)], facebookProfile];
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        NSArray *objectsWithThisId = [context executeFetchRequest:request error:&error];
        
        
        // if no object already exists
        if ([objectsWithThisId count] == 0) {
            Friends *aFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
            aFriend.name = CFBridgingRelease(ABRecordCopyCompositeName(aPerson)); // Also correct. Good.
            aFriend.category = @"AddressBook";
            aFriend.iosABrecordId = [NSNumber numberWithInteger:ABRecordGetRecordID(aPerson)];
            aFriend.facebookUser = Nil;
            aFriend.image = (__bridge NSData*)ABPersonCopyImageData(aPerson);
            aFriend.facebookUser = facebookProfile;
            
            if (![aFriend.managedObjectContext save:&error]) {
                NSLog(@"Error when saving the object: %@", error);
            }
        }
        
    }
}

#pragma mark - Click on an entry
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Value Selected by user
    NSArray *tableSource;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        tableSource=filteredFriendsArray;
    } else {
        tableSource=friendsArray;
    }
    Friends *selectedValue = [tableSource objectAtIndex:indexPath.row];
    if (selectedValue.name == messageToConnectAddressBook) {
        // Request authorization to Address Book
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    // First time access has been granted, add the contact
                    NSLog(@"You now have access to the adress book");
                    [self retrieveContactsFromAddressBookIntoCoreData];
                    [self updateDataSource];
                    [self.tableView reloadData];
                    
                } else {
                    // User denied access
                    // Display an alert telling user the contact could not be added
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access, add the contact
            [self retrieveContactsFromAddressBookIntoCoreData];
            [self updateDataSource];
            [self.tableView reloadData];
        }
        else {
            // The user has previously denied access
            // Send an alert telling user to change privacy setting in settings app
        }
    } else if (selectedValue.name == messageToConnectFacebook) {
        [self retrieveContactsFromFacebbokIntoCoreData];
    } else {
        NSLog(@"UUID %@", selectedValue.iosABrecordId);
        NSLog(@"Value selected %@", selectedValue.name);
    }

        //Pass selected value to a property declared in NewViewController
//    viewController.valueToPrint = selectedValue;
    //Push new view to navigationController stack
//    [self.navigationController pushViewController:viewController animated:YES];
}
@end
