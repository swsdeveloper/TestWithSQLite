//
//  PersonDatabase.h
//  SQLLite_TEST
//
//  Created by Steven Shatz on 12/3/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.


#import <Foundation/Foundation.h>
#import "Constants.h"
#import "SQLiteAccessObject.h"
#import "Person.h"


@interface PersonDatabase : NSObject

@property (retain, nonatomic) NSString *dbPath;

@property (retain, nonatomic) NSString *dbName;

@property (retain, nonatomic) NSString *dbFullName;     // db = dbPath + dbName

@property (retain, nonatomic) NSMutableArray *arrayOfPersons;

@property (retain, nonatomic) SQLiteAccessObject *sqlAO;


- (id)init;

- (void)createPersonsTable;

- (void)getAllPersons;

- (void)addPersonWithName:(NSString *)name age:(NSString *)age;

- (void)updatePersonWithKey:(NSString *)key name:(NSString *)name age:(NSString *)age;

- (void)deletePersonWithKey:(long)key;

@end
