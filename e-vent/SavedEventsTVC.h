//
//  SavedEventsTVC.h
//  e-vent
//
//  Created by Fábio C.S. Miranda on 12/3/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface SavedEventsTVC : CoreDataTableViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath;

@end
