//
//  PersonDatabase.m
//  SQLLite_TEST
//
//  Created by Steven Shatz on 12/3/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.


#import "PersonDatabase.h"

@implementation PersonDatabase

// ******************
// * Public Methods *
// ******************

- (id)init {
    
    self = [super init];
    if (self) {
        _arrayOfPersons = [[NSMutableArray alloc] initWithObjects:nil];
        
        NSArray *databasePathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        // NSSearchPathForDirectoriesInDomains: This function creates a list (i.e., an Array) of path strings for the specified directories in the specified domains
        //
        //  Note: The directory returned by this method may not exist. This method simply gives you the appropriate location for the requested directory.
        //        Depending on the application’s needs, it may be up to the developer to create the appropriate directory and any in between.
        //
        // NSDocumentDirectory = search the Documents subdirectory (under each user directory)
        // NSUserDomainMask = limit search to current user
        // YES = expand any tilde's in the path
        
        _dbPath = [databasePathArray objectAtIndex:0];    // databasePath = the 1st directory in the |databasePathArray|
        
        _dbName = @"Person.db";
        
        _dbFullName = [_dbPath stringByAppendingPathComponent:_dbName];
        
        NSLog(@"in PersonDatabase init: %@", _dbFullName);
        
        _sqlAO = [[SQLiteAccessObject alloc] initWithDatabase:_dbFullName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];    // defaultManager = the shared (singleton) file manager object
        
        if (![fileManager fileExistsAtPath:_dbFullName]) {
            
            [_sqlAO createDatabase];    // should never happen
        }
    }
    return self;
}

// If table does not exist, create it; if it exists, do nothing
- (void)createPersonsTable {
    
    const char *sql_stmt = "CREATE TABLE IF NOT EXISTS PERSONS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, AGE INTEGER)";
    
    // CREATE TABLE
    // The table named |PERSONS| will be built (if it is not already in existence)
    // The table will have 3 fields:
    //  1) ID - an integer (the Primary Key) - to be autoincremented (starting from 1)
    //          - INTEGER PRIMARY KEY is an alias for ROWID
    //          - On an INSERT, if ROWID is not specified, it will be auto filled with the value of the current
    //            highest ROWID + 1. But this could be a previously assigned and then deleted ROWID
    //          - However, if AUTOINCREMENT was specified on the CREATE, ROWID will always be set to a unique
    //            value; i.e., it will never be reassigned a ROWID that was previously deleted
    //  2) NAME - a text field
    //  3) AGE - an integer
    
    int createRc = SQLITE_ERROR;    // default return code
 
    int openRc = [self.sqlAO openDatabase];

    if (openRc == SQLITE_OK) {
        
        createRc = [self.sqlAO sqlExecStmt:sql_stmt];
        
        if (createRc == SQLITE_OK) {
            
//            [self showCreateAlert];
            
        } else {
            NSLog(@"\n\nCreate Persons Table Failed with return code: %d", createRc);
        }

        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nOpen Database Failed with return code: %d", openRc);
    }
}

- (void)getAllPersons {
    
    // OPEN db, PREPARE a "Select all records" stmt, process it in a STEP loop to list all persons in the database, and use
    //    the returned |person| values to rebuild |self.arrayOfPersons|
    
    int openRc = [self.sqlAO openDatabase];
    
    if (openRc == SQLITE_OK) {
        
        [self.arrayOfPersons removeAllObjects];
        
        const char *sql_stmt = "SELECT * FROM PERSONS";
        
        int prepareRc = [self.sqlAO sqlPrepareStmt:sql_stmt];     // sets self.personDB.preparedStmt
        
        if (prepareRc == SQLITE_OK) {
            
            while ([self.sqlAO sqlStep] == SQLITE_ROW) {

                NSString *keyString = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 0)];
                // 1st column (field) in returned Row
                
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 1)];
                // 2nd column (field) in returned Row
                
                NSString *ageString = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 2)];
                // 3rd col (field) in returned Row
                
                Person *person = [[Person alloc] init];
                
                [person setKey:[keyString intValue]];
                [person setName:name];
                [person setAge:[ageString intValue]];   // convert from UTF8 format to an int
                
                NSLog(@" key: %ld, name: %@, age: %d", person.key, person.name, person.age);
                
                [self.arrayOfPersons addObject:person];
            }
            
            [self.sqlAO sqlFinalizePreparedStmt];
            
        } else {
            NSLog(@"\n\nPrepare Failed with return code: %d", prepareRc);
        }
        
        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nOpen Database Failed with return code: %d", openRc);
    }
}

- (void)addPersonWithName:(NSString *)name age:(NSString *)age {
    
    // Build an INSERT sql stmt to add a new Person to the PERSONS Table
    // The 2 values Name (a UTF8 C string) and Age (an int) are passed from the contents of UITextFields
    // The Key (ID#) will automatically be set because it is defined as Auto Increment
    
    int openRc = [self.sqlAO openDatabase];
    
    if (openRc == SQLITE_OK) {
        
        NSString *insertStmt = [NSString stringWithFormat:@"INSERT INTO PERSONS (NAME,AGE) VALUES ('%@','%d')", name, [age intValue]];
        
        const char *sql_stmt = [insertStmt UTF8String];
        
        int execRc = [self.sqlAO sqlExecStmt:sql_stmt];
        
        if (execRc == SQLITE_OK) {
            Person *person = [[Person alloc] init];
            
            [person setKey:sqlite3_last_insert_rowid(self.sqlAO.database)];  // get key (i.e., primary key) of record just inserted into table
            
            [person setName:name];
            [person setAge:[age intValue]];  // Convert NSString to int
            
            [self.arrayOfPersons addObject:person];
            
//            [self showAddAlertForKey:person.key name:name];
            
        } else {
            NSLog(@"\n\nInsert Failed with return code: %d", execRc);
        }
        
        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nOpen Database Failed with return code: %d", openRc);
    }
}

- (void)deletePersonWithKey:(long)key {
    // The person whose id is |id| will be deleted from the PERSONS table of the database
    // Open the db, EXEC a "Delete person" stmt, and alert the user
    
    int openRc = [self.sqlAO openDatabase];
    
    if (openRc == SQLITE_OK) {
        
        NSString *deleteStatement = [NSString stringWithFormat:@"DELETE FROM PERSONS WHERE ID IS '%ld'", key];
        
        const char *sql_stmt = [deleteStatement UTF8String];
        
        int execRc = [self.sqlAO sqlExecStmt:sql_stmt];
        
        if (execRc == SQLITE_OK) {
            
//            [self showDeleteAlertForKey:key];
            
        } else {
            NSLog(@"\n\nDelete Failed with return code: %d", execRc);
        }
        
        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nOpen Database Failed with return code: %d", openRc);
    }
}


#pragma mark Alerts

- (void)showCreateAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create"
                                                    message:@"Persons table was successfully created"
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showAddAlertForKey:(long)key name:(NSString *)name {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add person"
                                                    message:[NSString stringWithFormat:@"%ld - %@ added to DB", key, name]
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showDeleteAlertForKey:(long)key {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete person"
                                                    message:[NSString stringWithFormat:@"Person with id: %ld was removed from DB", key]
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
}


@end
