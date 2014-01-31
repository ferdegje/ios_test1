//
//  JMFAppDelegate.h
//  test1
//
//  Created by Jean-Marie Ferdegue on 31/01/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
