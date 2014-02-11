//
//  JMFFriends.h
//  test1
//
//  Created by Jean-Marie Ferdegue on 11/02/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friends.h"

@interface JMFFriends : NSObject {
    NSString *category;
    NSString *name;
}

@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *name;

+ (id)friendOfCategory:(NSString*)category name:(NSString*)name;

@end
