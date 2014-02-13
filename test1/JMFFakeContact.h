//
//  JMFFakeContact.h
//  test1
//
//  Created by Jean-Marie Ferdegue on 12/02/2014.
//  Copyright (c) 2014 Jean-Marie Ferdegue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMFFakeContact : NSObject {
    NSString *category;
    NSString *name;
}
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *name;

+ (id)setCategoryAndName:(NSString*)category name:(NSString*)name;
@end
