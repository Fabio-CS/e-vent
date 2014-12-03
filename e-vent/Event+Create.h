//
//  Event+Create.h
//  e-vent
//
//  Created by Fábio C.S. Miranda on 12/3/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "Event.h"

@interface Event (Create)
+ (Event *)eventWithTitle:(NSString *)title
                dateStart:(NSDate *)dtStart
               andDateEnd:(NSDate *)dtEnd
                andqrcore:(NSData *)imgage
   inManagedObjectContext:(NSManagedObjectContext *)context;
@end
