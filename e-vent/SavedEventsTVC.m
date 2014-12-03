//
//  SavedEventsTVC.m
//  e-vent
//
//  Created by Fábio C.S. Miranda on 12/3/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "SavedEventsTVC.h"
#import "Event.h"
#import "ImageViewController.h"
#import "EventsDatabase.h"

@interface SavedEventsTVC ()

@end

@implementation SavedEventsTVC

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"event_cell"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = event.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Starts: %@ - Ends: %@", [dateFormatter stringFromDate:event.dtStart], [dateFormatter stringFromDate:event.dtEnd]];
    
    return cell;
}

#pragma mark - Managed Context

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dtStart"
                                                              ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc
                           forSegue:nil
                      fromIndexPath:indexPath];
    }
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if ([vc isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *)vc;
        ivc.eventTitle = event.title;
        ivc.eventStarts = [dateFormatter stringFromDate:event.dtStart];
        ivc.eventEnds = [dateFormatter stringFromDate:event.dtEnd];
        ivc.image = [[UIImage alloc] initWithData:event.code];
        ivc.managedObjectContext = self.managedObjectContext;
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextChanged:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.managedObjectContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:self.managedObjectContext];
    [super viewWillDisappear:animated];
}

- (void)contextChanged:(NSNotification *)notification
{
    [self performFetch];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserverForName:EventsDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[EventsDatabaseAvailabilityContext];
                                                  }];
}

@end
