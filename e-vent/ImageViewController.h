//
//  ImageViewController.h
//  Top Places
//
//  Created by Fábio C.S. Miranda on 10/14/14.
//
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, strong) NSString *eventStarts;
@property (nonatomic, strong) NSString *eventEnds;
@end
