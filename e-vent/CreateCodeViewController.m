//
//  CreateCodeViewController.m
//  e-vent
//
//  Created by Fábio C.S. Miranda on 11/5/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "CreateCodeViewController.h"
#import "ImageViewController.h"

@interface CreateCodeViewController()

@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerStart;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerEnd;

@property NSString *titleEvent;
@property NSDate *dateStart;
@property NSDate *dateEnd;
@end

@implementation CreateCodeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dateStart = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    self.dateEnd = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    [self.datePickerStart addTarget:self action:@selector(datePickerStartChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePickerEnd addTarget:self action:@selector(datePickerEndChanged:) forControlEvents:UIControlEventValueChanged];
    NSLog(@"View did load",nil);
}

- (void)datePickerStartChanged:(UIDatePicker *)datePicker{
    self.dateStart = [datePicker date];
    NSLog(@"Start Changed", nil);
}

- (void)datePickerEndChanged:(UIDatePicker *)datePicker{
    self.dateEnd = [datePicker date];
    NSLog(@"End Changed",nil);
}

- (IBAction)buttonGenerate:(UIButton *)sender {
    self.titleEvent = self.textFieldTitle.text;
}

-(NSString *)getCodeURL{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss"];
    NSLog(@"%@",self.dateStart);
    NSLog(@"%@",self.dateEnd);
    NSString *dtStart = [dateFormatter stringFromDate:self.dateStart];
    NSLog(@"%@",dtStart);
    NSString *dtEnd = [dateFormatter stringFromDate:self.dateEnd];
    NSLog(@"%@",dtEnd);
    NSString *url = @"http://api.qrserver.com/v1/create-qr-code/?color=000000&bgcolor=FFFFFF&data=BEGIN%3AVEVENT%0ASUMMARY%3A";
    NSString *escapedTitle =[self.titleEvent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByAppendingString:escapedTitle];
    url = [url stringByAppendingString:@"%0ADTSTART%3A"];
    url = [url stringByAppendingString:dtStart];
    url = [url stringByAppendingString:@"Z%0ADTEND%3A"];
    url = [url stringByAppendingString:dtEnd];
    url = [url stringByAppendingString:@"Z%0AEND%3AVEVENT&qzone=4&margin=0&size=300x300&ecc=L"];
    NSLog(@"%@",url);
    return url;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
        ImageViewController *ivc = (ImageViewController *)segue.destinationViewController;
        NSURL *url = [[NSURL alloc] initWithString:[self getCodeURL]];
        ivc.imageURL = url;
        ivc.eventTitle = self.titleEvent;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    ivc.eventStarts = [dateFormatter stringFromDate:self.dateStart];
    ivc.eventEnds = [dateFormatter stringFromDate:self.dateEnd];
}


@end
