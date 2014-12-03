//
//  ScanCodeViewController.m
//  e-vent
//
//  Created by Fábio C.S. Miranda on 12/3/14.
//  Copyright (c) 2014 Fábio C.S. Miranda. All rights reserved.
//

#import "ScanCodeViewController.h"
#import "Event+Create.h"

@interface ScanCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) CALayer *targetLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, copy) NSMutableArray *codeObjects;
@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, strong) NSDate *eventDTStarts;
@property (nonatomic, strong) NSDate *eventDTEnds;
@end

@implementation ScanCodeViewController


- (NSMutableArray *)codeObjects
{
    if (!_codeObjects)
    {
        _codeObjects = [NSMutableArray new];
    }
    return _codeObjects;
}

- (AVCaptureSession *)captureSession
{
    if (!_captureSession)
    {
        NSError *error = nil;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device.isAutoFocusRangeRestrictionSupported)
        {
            if ([device lockForConfiguration:&error])
            {
                [device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
                [device unlockForConfiguration];
            }
        }
        
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (deviceInput)
        {
            _captureSession = [[AVCaptureSession alloc] init];
            if ([_captureSession canAddInput:deviceInput])
            {
                [_captureSession addInput:deviceInput];
            }
            
            AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            if ([_captureSession canAddOutput:metadataOutput])
            {
                [_captureSession addOutput:metadataOutput];
                [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
                [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            }
            
            self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.previewLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:self.previewLayer];
            
            self.targetLayer = [CALayer layer];
            self.targetLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:self.targetLayer];
            
        }
        else
        {
            NSLog(@"Input Device error: %@",[error localizedDescription]);
        }
    }
    return _captureSession;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRunning];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self stopRunning];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self startRunning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startRunning
{
    self.codeObjects = nil;
    [self.captureSession startRunning];
}

- (void)stopRunning
{
    [self.captureSession stopRunning];
    self.captureSession = nil;
}

- (void)clearTargetLayer
{
    NSArray *sublayers = [[self.targetLayer sublayers] copy];
    for (CALayer *sublayer in sublayers)
    {
        [sublayer removeFromSuperlayer];
    }
}

- (void)showDetectedObjects
{
    for (AVMetadataObject *object in self.codeObjects)
    {
        if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.strokeColor = [UIColor redColor].CGColor;
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
            shapeLayer.lineWidth = 2.0;
            shapeLayer.lineJoin = kCALineJoinRound;
            CGPathRef path = createPathForPoints([(AVMetadataMachineReadableCodeObject *)object corners]);
            shapeLayer.path = path;
            CFRelease(path);
            [self.targetLayer addSublayer:shapeLayer];
        }
    }
}

CGMutablePathRef createPathForPoints(NSArray* points)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint point;
    
    if ([points count] > 0)
    {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:0], &point);
        CGPathMoveToPoint(path, nil, point.x, point.y);
        
        int i = 1;
        while (i < [points count])
        {
            CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:i], &point);
            CGPathAddLineToPoint(path, nil, point.x, point.y);
            i++;
        }
        
        CGPathCloseSubpath(path);
    }
    
    return path;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    for (AVMetadataObject *metadataObject in metadataObjects)
    {
        AVMetadataObject *transformedObject = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        [self.codeObjects addObject:transformedObject];
        AVMetadataMachineReadableCodeObject *qrcode = (AVMetadataMachineReadableCodeObject *)metadataObject;
        NSString *qrCodeString = qrcode.stringValue;
        [self iCalStringParser:qrCodeString];
        [self createCalendarEvent];
    }
    
    [self clearTargetLayer];
    [self showDetectedObjects];
    [self.captureSession stopRunning];
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
        Event *eventSaved = [Event eventWithTitle:self.eventTitle dateStart:self.eventDTStarts andDateEnd:self.eventDTEnds andqrcore:nil inManagedObjectContext:self.managedObjectContext];
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



@end
