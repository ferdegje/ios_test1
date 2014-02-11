//
//  NSDictionary+googleAnalysis.m
//  test1
//
//  Created by Jean-Marie Ferdegue on 07/02/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import "NSDictionary+googleAnalysis.h"

@implementation NSDictionary (googleAnalysis)
- (NSDictionary *) location
{
    return [[[[self valueForKey:@"results"] objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
}
- (NSNumber *) longitude
{
    return [self.location valueForKey:@"lat"];
}
- (NSNumber *) latitude
{
    return [self.location valueForKey:@"lng"];
}
@end
