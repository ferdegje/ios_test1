//
//  SelectAFriendTableViewController.m
//  test1
//
//  Created by Jean-Marie Ferdegue on 11/02/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import "SelectAFriendTableViewController.h"
#import "JMFFriends.h"
#import "Friends.h"
#import <AddressBookUI/AddressBookUI.h>

@interface SelectAFriendTableViewController ()

@end

@implementation SelectAFriendTableViewController
@synthesize friendsArray;
@synthesize filteredFriendsArray;
@synthesize friendsSearchBar;

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
    // Sample Data for candyArray
    JMFAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    Friends *aFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
    aFriend.name = @"Lisa Cachou";
    aFriend.category = @"Facebook";

    if ([aFriend.managedObjectContext save:&error]) {
        NSLog(@"No error when saving the object");
    }
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Friends" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *array = [context executeFetchRequest:request error:&error];
//    friendsArray = [NSArray arrayWithObject:[JMFFriends friendOfCategory:@"Contacts" name:@"Add a friends from your contacts"]];
    friendsArray = array;
    self.filteredFriendsArray = [NSMutableArray arrayWithCapacity:[friendsArray count]];
    // Reload the table
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
    JMFFriends *aFriend = nil;
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        aFriend = [filteredFriendsArray objectAtIndex:indexPath.row];
    } else {
        aFriend = [friendsArray objectAtIndex:indexPath.row];
    }
    aFriend = [friendsArray objectAtIndex:indexPath.row];
    // Configure the cell
    cell.textLabel.text = aFriend.name;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredFriendsArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    NSArray *tempArray = [friendsArray filteredArrayUsingPredicate:predicate];
    if (![scope isEqualToString:@"All"]) {
        // Further filter the array with the scope
        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
    }
    filteredFriendsArray = [NSMutableArray arrayWithArray:tempArray];
    NSLog(@"results filtered");
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

#pragma mark - Click on an entry
- (void)retrieveContactsFromAddressBookIntoCoreData:(ABAddressBookRef)addressBook
{
    CFArrayRef peopleCoreFoundation = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex countOfPeople = ABAddressBookGetPersonCount(addressBook);
    NSArray *people = (__bridge NSArray*)peopleCoreFoundation;
    CFRelease(peopleCoreFoundation);
    JMFAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    for (int i = 0; i < countOfPeople; i++) {
        ABRecordRef aPerson = (__bridge ABRecordRef)([people objectAtIndex:i]);
        Friends *aFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
        aFriend.name = CFBridgingRelease(ABRecordCopyCompositeName(aPerson));
        aFriend.category = @"AddressBook";
//        aFriend.iosABrecordId = ABRecordGetRecordID(aPerson);
        if ([aFriend.managedObjectContext save:&error]) {
            NSLog(@"No error when saving the object");
        }

//        NSString *name =
//        ABMultiValueRef phoneNumbers = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
////        NSString *firstPhone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
//        ABRecordID *recordId = ABRecordGetRecordID(aPerson);

    }

    CFRelease(countOfPeople);
    NSLog(@"people");
}

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
    NSLog(@"Value selected %@", selectedValue.name);
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                NSLog(@"You now have access to the adress book");
                [self retrieveContactsFromAddressBookIntoCoreData:addressBookRef];
                
                
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self retrieveContactsFromAddressBookIntoCoreData:addressBookRef];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    //Pass selected value to a property declared in NewViewController
//    viewController.valueToPrint = selectedValue;
    //Push new view to navigationController stack
//    [self.navigationController pushViewController:viewController animated:YES];
}
@end
