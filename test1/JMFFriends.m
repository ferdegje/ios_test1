//
//  JMFFriends.m
//  test1
//
//  Created by Jean-Marie Ferdegue on 11/02/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import "JMFFriends.h"

@implementation JMFFriends
@synthesize category;
@synthesize name;

+ (id)friendOfCategory:(NSString *)category name:(NSString *)name
{
    JMFFriends *aFriend = [[self alloc] init];
    aFriend.category = category;
    aFriend.name = name;
    return aFriend;
}
@end
