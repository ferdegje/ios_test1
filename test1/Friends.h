//
//  Friends.h
//  test1
//
//  Created by Jean-Marie Ferdegue on 12/02/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * facebookUser;
@property (nonatomic, retain) NSNumber * iosABrecordId;
@property (nonatomic, retain) NSString * name;

@end
