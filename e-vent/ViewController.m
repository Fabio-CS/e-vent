//
//  ViewController.m
//  e-vent
//
//  Created by Fábio C.S. Miranda on 11/4/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "ViewController.h"
#import "EventsDatabase.h"
#import "CreateCodeViewController.h"
#import "ReadCodeViewController.h"
#import "SavedEventsTVC.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *readCode;
@property (weak, nonatomic) IBOutlet UIButton *createCode;
@property (weak, nonatomic) IBOutlet UIButton *listCodes;

@end

@implementation ViewController

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = [segue identifier];
    if ([segueIdentifier isEqualToString:@"create"]) {
        CreateCodeViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
    }else if ([segueIdentifier isEqualToString:@"read"]) {
        ReadCodeViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
    }else if ([segueIdentifier isEqualToString:@"list"]) {
        SavedEventsTVC *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
    }
}

@end
