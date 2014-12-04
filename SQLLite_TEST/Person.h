//
//  Person.h
//  SQLLite_TEST
//
//  Created by Steven Shatz on 04/12/13.
//  Copyright (c) 2013 Steven Shatz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (assign, nonatomic) long key;

@property (retain, nonatomic) NSString *name;

@property (assign, nonatomic) int age;

@end
