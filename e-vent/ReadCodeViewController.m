//
//  ReadCodeViewController.m
//  e-vent
//
//  Created by Fábio C.S. Miranda on 11/5/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "ReadCodeViewController.h"
@interface ReadCodeViewController()<UIScrollViewDelegate, UISplitViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelStarts;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labelEnds;
@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, strong) NSString *eventStarts;
@property (nonatomic, strong) NSString *eventEnds;
@property (nonatomic, strong) NSDate *eventDTStarts;
@property (nonatomic, strong) NSDate *eventDTEnds;
@end
@implementation ReadCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    if (self.eventTitle) {
        self.labelTitle.text = [self.labelTitle.text stringByAppendingString:self.eventTitle];
        self.labelStarts.text = [self.labelStarts.text stringByAppendingString:self.eventStarts];
        self.labelEnds.text = [self.labelEnds.text stringByAppendingString:self.eventEnds];
    }
}


- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

-(void)setEventDTStarts:(NSDate *)eventDTStarts{
    self.eventDTStarts = eventDTStarts;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.eventStarts = [dateFormatter stringFromDate:self.eventDTStarts];
}

-(void)setEventDTEnds:(NSDate *)eventDTEnds{
    self.eventDTEnds = eventDTEnds;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.eventStarts = [dateFormatter stringFromDate:self.eventDTStarts];
}

-(void)setEventTitle:(NSString *)eventTitle{
    self.eventTitle = eventTitle;
    self.labelTitle.text = [self.labelTitle.text stringByAppendingString:self.eventTitle];
}

-(void)setEventStarts:(NSString *)eventStarts{
    self.eventStarts = eventStarts;
    self.labelStarts.text = [self.labelStarts.text stringByAppendingString:self.eventStarts];
}

-(void)setEventEnds:(NSString *)eventEnds{
    self.eventEnds = eventEnds;
    self.labelEnds.text = [self.labelEnds.text stringByAppendingString:self.eventEnds];
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    self.scrollView.zoomScale = 1.0;
    [self.imageView sizeToFit];
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (IBAction)selectImage:(id)sender {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    [self iCalStringParser:@"jajajaja"];
    [self createCalendarEvent];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
}

#pragma mark - createEvent
- (void)createCalendarEvent{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = self.eventTitle;
        event.startDate = self.eventDTStarts;
        event.endDate = self.eventDTEnds;
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    }];
}

- (NSDictionary *)iCalStringParser:(NSString *)icalString{
    icalString = @"BEGIN:VEVENT\nSUMMARY:Evento\nDTSTART:20141201T120000Z\nDTEND:20141203T120000Z\nEND:VEVENT";
    NSMutableDictionary *iCalDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataEvent = [NSMutableArray arrayWithArray:[icalString componentsSeparatedByString:@"\n"]];
    [dataEvent removeObjectAtIndex:0];
    [dataEvent removeLastObject];
    for (NSString *data in dataEvent) {
        NSArray *item = [NSArray arrayWithArray:[data componentsSeparatedByString:@":"]];
        [iCalDict setObject:item[1] forKey:item[0]];
    }
    NSString *strDTStart = [iCalDict objectForKey:@"DTSTART"];
    NSString *strDTEnd = [iCalDict objectForKey:@"DTEND"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    NSDate *dtStart = [dateFormatter dateFromString:strDTStart];
    NSDate *dtEnd = [dateFormatter dateFromString:strDTEnd];
    [iCalDict setObject:dtStart forKey:@"DTSTART"];
    [iCalDict setObject:dtEnd forKey:@"DTEND"];
    self.eventTitle = [iCalDict objectForKey:@"SUMMARY"];
    self.eventDTStarts = [iCalDict objectForKey:@"DTSTART"];
    self.eventDTEnds = [iCalDict objectForKey:@"DTEND"];
    return iCalDict;
}

#pragma mark - iPadView
- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end
