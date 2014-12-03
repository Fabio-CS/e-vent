//
//  Event+Create.m
//  e-vent
//
//  Created by Fábio C.S. Miranda on 12/3/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "Event+Create.h"

@implementation Event (Create)

+(Event *)eventWithTitle:(NSString *)title dateStart:(NSDate *)dtStart andDateEnd:(NSDate *)dtEnd andqrcore:(NSData *)image inManagedObjectContext:(NSManagedObjectContext *)context{
    Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                          inManagedObjectContext:context];
    event.title = title;
    event.dtStart = dtStart;
    event.dtEnd = dtEnd;
    event.code = image;
    return event;
}


@end

