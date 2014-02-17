//
//  JMFAppDelegate.m
//  test1
//
//  Created by Jean-Marie Ferdegue on 31/01/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import "JMFAppDelegate.h"
#import "FacebookSDK/FBSession.h"
#import "FacebookSDK/FBAppCall.h"
#import "Friends.h"

// Ensure that any observations about NSManagedObjectContexts being saved
// are merged with the main thread's context ON THE MAIN THREAD. The
// notifications are not guaranteed to be delivered on any given thread.
static dispatch_queue_t contextMergingDispatchQueue = nil;

@implementation JMFAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (void)initialize
{
    if (self == [JMFAppDelegate class]) {
        contextMergingDispatchQueue = dispatch_queue_create("com.test1.cdmergequeue", NULL);
    }
}

- (void)mergeContextDidSaveOnMainThread:(NSNotification *)notification
{
    dispatch_async(contextMergingDispatchQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        });
    });
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeContextDidSaveOnMainThread:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"test1" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"test1.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Facebook Handling
// This method will handle ALL the session state changes in the app
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    // Set the button title as "Log in with Facebook"
//    UIButton *loginButton = [self.customLoginViewController loginButton];
//    [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    
    // Confirm logout message
    [self setFacebookLoggedIn:NO];
    [self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    // Set the button title as "Log out"
//    UIButton *loginButton = self.customLoginViewController.loginButton;
//    [loginButton setTitle:@"Log out" forState:UIControlStateNormal];
    
    // Welcome message
    [self setFacebookLoggedIn:YES];
//    [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
    [self retrieveFacebookFriendsFromOffset:0];
}

- (void) retrieveFacebookFriendsFromOffset:(int)offset
{
    // pagination largely inspired by http://stackoverflow.com/questions/14006244/objective-c-facebook-graph-api-pagination
    int limit = 100; // we will retrieve friends of the user by batches of limit
    NSDictionary *params;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Friends" inManagedObjectContext:context];
    
    
    params = [NSDictionary dictionaryWithObjectsAndKeys:
              [NSString stringWithFormat:@"%d", offset], @"offset",
              [NSString stringWithFormat:@"%d", limit], @"limit",
              nil];
    [FBRequestConnection startWithGraphPath:@"me/friends?fields=id,name,username"
                                 parameters:params HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Sucess! Include your code to handle the results here
                                  
                                  NSArray *rdata = [result objectForKey:@"data"];
                                  NSLog(@"user events: %@", rdata);
                                  if ([rdata count] >= limit) {
                                      int newOffset;
                                      newOffset = offset +limit;
                                      [self retrieveFacebookFriendsFromOffset:newOffset];
                                  }
                                  for (NSDictionary *aFbFriend in rdata) {
                                      // Make sure that this user isn't already in the Friends coredata table
                                      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookUser == %@", [aFbFriend objectForKey:@"username"]];
                                      NSFetchRequest *requestOfUsersWithThisFbUsername = [[NSFetchRequest alloc] init];
                                      [requestOfUsersWithThisFbUsername setPredicate:predicate];
                                      [requestOfUsersWithThisFbUsername setEntity:entityDescription];
                                      NSArray *arrayObjectsAlreadyStored = [context executeFetchRequest:requestOfUsersWithThisFbUsername error:&error];
                                      Friends *newFriend;
                                      if ([arrayObjectsAlreadyStored count] == 0) { // If the user didn't already exist in coredata table friends, then we create a new one
                                          newFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
                                          newFriend.facebookUser = [aFbFriend objectForKey:@"username"];
                                          newFriend.name = [aFbFriend objectForKey:@"name"];
                                          newFriend.category = @"Facebook";
                                          NSString *pictureUrl;
                                          pictureUrl= @"%@ picture", newFriend.facebookUser;
                                          [FBRequestConnection startWithGraphPath:pictureUrl completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                              NSLog(result);
                                                newFriend.image = (NSData *)result;
                                                if (!([newFriend.managedObjectContext save:&error])) {
                                                    NSLog(@"Error while saving a new friend from Facebook: %@", error);
                                                }
                                          }];
                                      } else {
                                          newFriend = [arrayObjectsAlreadyStored objectAtIndex:0];
                                      }
                                      
                                      
                                  }
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  if ([FBErrorUtility shouldNotifyUserForError:error]) {
                                      [self showMessage:[FBErrorUtility userMessageForError:error] withTitle:@"While trying to retrieve your friends"];
                                  } else {
                                      NSInteger *errorCategory = [FBErrorUtility errorCategoryForError:error];
                                      NSLog([NSString stringWithFormat:@"%d", errorCategory]);
                                      NSLog([error userInfo]);
                                  }
                              }
                          }];
}
// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // Note this handler block should be the exact same as the handler passed to any open calls.
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         JMFAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [appDelegate sessionStateChanged:session state:state error:error];
     }];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}
@end
