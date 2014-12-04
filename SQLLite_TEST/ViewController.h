//
//  ViewController.h
//  SQLLite_TEST
//
//  Created by Steven Shatz on 12/01/14.
//  Copyright (c) 2013 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "PersonDatabase.h"
#import "Person.h"

@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@property (weak, nonatomic) IBOutlet UITextField *ageField;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (retain, nonatomic) PersonDatabase *personDB;


- (IBAction)addPersonButton:(id)sender;

- (IBAction)deletePersonButton:(id)sender;

- (void)displayAllPersons;


@end
