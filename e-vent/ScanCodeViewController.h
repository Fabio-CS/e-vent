//
//  ScanCodeViewController.h
//  e-vent
//
//  Created by Fábio C.S. Miranda on 12/3/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <EventKit/EventKit.h>

@interface ScanCodeViewController : ViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
