//
//  JMFFakeContact.m
//  test1
//
//  Created by Jean-Marie Ferdegue on 12/02/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import "JMFFakeContact.h"

@implementation JMFFakeContact
@synthesize category;
@synthesize name;
@synthesize image;

+ (id)setCategoryAndName:(NSString *)category name:(NSString *)name
{
    JMFFakeContact *aFriend = [[self alloc] init];
    aFriend.category = category;
    aFriend.name = name;
    aFriend.image = nil;
    return aFriend;
}
@end
