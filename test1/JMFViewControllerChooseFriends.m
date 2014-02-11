//
//  JMFViewControllerChooseFriends.m
//  test1
//
//  Created by Jean-Marie Ferdegue on 31/01/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import "JMFAppDelegate.h"
#import "JMFViewControllerChooseFriends.h"
#import "FacebookSDK/FBLoginView.h"
#import "NSDictionary+googleAnalysis.h"
#import "ImageWithText.h"

@interface JMFViewControllerChooseFriends ()
@property (strong, nonatomic) NSManagedObject *imageWithText;
@end

@implementation JMFViewControllerChooseFriends

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    JMFAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    self.imageWithText = [NSEntityDescription insertNewObjectForEntityForName:@"ImageWithText" inManagedObjectContext:context];
    [self.imageWithText addObserver:self forKeyPath:@"latitude" options:NSKeyValueObservingOptionNew context:NULL];
    [self.imageWithText addObserver:self forKeyPath:@"longitude" options:NSKeyValueObservingOptionNew context:NULL];
    FBLoginView *loginView = [[FBLoginView alloc] init];
    // Align the button in the center horizontally
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 5);
    [self.view addSubview:loginView];
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        NSLog(@"You are logged in... i think");
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        NSLog(@"You are not logged in");
//        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"] allowLoginUI:YES
//                                      completionHandler:
//         ^(FBSession *session, FBSessionState state, NSError *error) {
//             
//             // Retrieve the app delegate
//             JMFAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
//             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
//             [appDelegate sessionStateChanged:session state:state error:error];
//         }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveImage:(UIButton *)sender {
    NSLog(@"Saving the image and its details");
    NSString *title = self.pictureTitle.text;
    NSData *image = UIImagePNGRepresentation(self.imageView.image);
    
    
    [self.imageWithText setValue:title forKey:@"title"];
    [self.imageWithText setValue:image forKey:@"image"];
    NSError *error;
    if ([self.imageWithText.managedObjectContext save:&error]) {
        [self fetchLatLng];
        
    }
}

- (void)fetchLatLng
{
    NSManagedObjectID *mid = [self.imageWithText objectID];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Now I am on a different thread
        JMFAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        context.persistentStoreCoordinator = [appDelegate persistentStoreCoordinator];
        ImageWithText *image = (ImageWithText *)[context objectWithID:mid];
        
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", image.title];
        NSURL *googleUrl = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:googleUrl];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        
        
        image.latitude = [jsonData latitude];
        image.longitude = [jsonData longitude];
        
        [context save:nil];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"latitude"]) {
            self.latitude.text=[[self.imageWithText valueForKey:@"latitude"] stringValue];
    }
    if ([keyPath isEqual:@"longitude"]) {
        self.longitude.text=[[self.imageWithText valueForKey:@"longitude"] stringValue];
    }
}

- (void) dealloc {
    [self.imageWithText removeObserver:self forKeyPath:@"latitude"];
    [self.imageWithText removeObserver:self forKeyPath:@"longitude"];
}

- (IBAction)buttonTouched:(UIButton *)sender
{
    NSLog(@"Toto");
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
@end
