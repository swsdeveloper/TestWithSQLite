//
//  ViewController.m
//  SQLLite_TEST
//
//  Created by Steven Shatz on 12/01/14.
//  Copyright (c) 2013 Steven Shatz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (MYDEBUG) { NSLog(@"in ViewDidLoad"); }
    
    [[self myTableView] setDelegate:self];
    [[self myTableView] setDataSource:self];
    
    self.personDB = [[PersonDatabase alloc] init];
        
    [self.personDB createPersonsTable];    // If table already exists, this effectively does nothing
    
    [self displayAllPersons];
}

- (void)displayAllPersons {
    
    if (MYDEBUG) { NSLog(@"in displayAllPersons"); }
    
    [self.personDB getAllPersons];      // Rebuilds self.arrayOfPersons

    [[self myTableView] reloadData];    // Redisplay UITableView from self.arrayOfPersons
}

- (IBAction)addPersonButton:(id)sender {
    
    if (MYDEBUG) { NSLog(@" --------------------------- Add Person button was tapped.."); }
    
    [self.personDB addPersonWithName:self.nameField.text age:self.ageField.text];
    
    [self displayAllPersons];
}

// The following method toggles tableView Editing mode on and off (and changes the button's name, accordingly)
- (IBAction)deletePersonButton:(id)sender { // This button is intially labeled "Delete" when pgm starts
    
    if (MYDEBUG) { NSLog(@" --------------------------- Delete Person button was tapped.."); }
    
    UIButton *btn = sender;
    
    if ([[self myTableView] isEditing]) {   // If we're already in Editing Mode and the Done button was hit, change button label back to "Delete"
        [btn setTitle:@"Delete" forState:UIControlStateNormal];
    }
    else {                                  // else, we're not in Editing Mode (initial setting), so change Delete button label to "Done"
        [btn setTitle:@"Done" forState:UIControlStateNormal];
    }
    
    [[self myTableView] setEditing:!self.myTableView.editing animated:YES]; // If not in Editing Mode, switch to Editing Mode; else vice-versa
}

#pragma mark UITableView Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.personDB.arrayOfPersons count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    Person *person = [self.personDB.arrayOfPersons objectAtIndex:indexPath.row];
    
    if (person) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (key=%ld)", person.name, person.key];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", person.age];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (MYDEBUG) { NSLog(@"in commitEditingStyle"); }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Person *person = [self.personDB.arrayOfPersons objectAtIndex:indexPath.row];
        
        if (person) {
            
            [self.personDB deletePersonWithKey:person.key];    // remove object from database
            
            [self.personDB.arrayOfPersons removeObjectAtIndex:indexPath.row];   // remove object from tableView datasource
        
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];    // remove object fm tableView
            
            [tableView reloadData];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
