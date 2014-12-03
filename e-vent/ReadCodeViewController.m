//
//  ReadCodeViewController.m
//  e-vent
//
//  Created by Fábio C.S. Miranda on 11/5/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "ReadCodeViewController.h"
#import "Event+Create.h"
#import "AppDelegate.h"

@interface ReadCodeViewController()<UIScrollViewDelegate, UISplitViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>
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
    _eventDTStarts = eventDTStarts;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.eventStarts = [dateFormatter stringFromDate:self.eventDTStarts];
}

-(void)setEventDTEnds:(NSDate *)eventDTEnds{
    _eventDTEnds = eventDTEnds;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.eventEnds = [dateFormatter stringFromDate:self.eventDTEnds];
}

-(void)setEventTitle:(NSString *)eventTitle{
    _eventTitle = eventTitle;
    self.labelTitle.text = [_labelTitle.text stringByAppendingString:_eventTitle];
}

-(void)setEventStarts:(NSString *)eventStarts{
    _eventStarts = eventStarts;
    self.labelStarts.text = [self.labelStarts.text stringByAppendingString:_eventStarts];
    NSLog(@"String eventStarts: %@", self.eventStarts);
}

-(void)setEventEnds:(NSString *)eventEnds{
    _eventEnds = eventEnds;
    self.labelEnds.text = [_labelEnds.text stringByAppendingString:_eventEnds];
     NSLog(@"String eventEnds: %@", self.eventEnds);
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
    [self readCode];
  
}

-(void)readCode{
    NSURL *url = [NSURL URLWithString:@"http://api.qrserver.com/v1/read-qr-code/"];
    //NSURL *url = [NSURL URLWithString:@"http://postcatcher.in/catchers/547e447e0e93f102000002ac"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"SportuondoFormBoundary";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSData *imageData = UIImagePNGRepresentation(self.image);

    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // Build the request body
    
    NSMutableData *body = [NSMutableData data];
    // Body part for "deviceId" parameter. This is a string.
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"MAX_FILE_SIZE"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", @"1048576"] dataUsingEncoding:NSUTF8StringEncoding]];
    // Body part for the attachament. This is an image.
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.png\"\r\n", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Setup the session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                   };
    [request setHTTPBody:body];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *localError = nil;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                if (localError){
                    NSLog(@"JSON PARSER ERROR: %@", localError);
                }else{
                    NSArray *jsonResult = [jsonDict valueForKey:@"symbol"];
                    NSDictionary *qrcode = [[NSDictionary alloc] initWithDictionary:[[jsonResult firstObject] firstObject]];
                    NSString *icalString = [qrcode valueForKeyPath:@"data"];
                    [self iCalStringParser:icalString];
                    [self createCalendarEvent];
                }
            });
        }
    }];
    [task resume];

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
        Event *eventSaved = [Event eventWithTitle:self.eventTitle dateStart:self.eventDTStarts andDateEnd:self.eventDTEnds andqrcore:UIImagePNGRepresentation(self.image) inManagedObjectContext:self.managedObjectContext];
        NSLog(@"Event Saved: %@",eventSaved);
        
        UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Event Created!"
                                                         message:[NSString stringWithFormat:@"The event: %@ was created in your calendar", self.eventTitle]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [message show];
    }];
}

- (NSDictionary *)iCalStringParser:(NSString *)icalString{
    //icalString = @"BEGIN:VEVENT\nSUMMARY:Evento\nDTSTART:20141201T120000Z\nDTEND:20141203T120000Z\nEND:VEVENT";
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
