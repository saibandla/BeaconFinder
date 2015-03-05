//
//  ViewController.m
//  Beacon Finder
//
//  Created by Geniusport on 3/5/15.
//  Copyright (c) 2015 adeptpros. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *uuid;
@property (strong, nonatomic) IBOutlet UILabel *major;
@property (strong, nonatomic) IBOutlet UILabel *minor;
@property (strong, nonatomic) IBOutlet UILabel *proxyRange;

@end

@implementation ViewController
CLLocationManager *locationManager;
NSString *uuid=@"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
CLBeaconRegion *beconRegion;
- (void)viewDidLoad
{
    [super viewDidLoad];
    locationManager=[[CLLocationManager alloc]init];
   beconRegion=[[CLBeaconRegion alloc]initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:uuid] identifier:@"Estimote"];
    [locationManager startMonitoringForRegion:beconRegion];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    if([beconRegion isEqual:region])
    {
        [locationManager startRangingBeaconsInRegion:beconRegion];
    }
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if([beconRegion isEqual:region])
    {
        [locationManager stopRangingBeaconsInRegion:beconRegion];
    }
}
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if(beacons.count>0)
    {
    CLBeacon *firstBecon=[beacons firstObject];
        NSString *uuid=firstBecon.proximityUUID.UUIDString;
        int major=firstBecon.major.intValue;
        int minor=firstBecon.minor.intValue;
        
        NSURL *proximityUrl;
        self.uuid.text=[self.uuid.text stringByAppendingString:uuid];;
        self.major.text=[self.major.text stringByAppendingString:[NSString stringWithFormat:@" %d",major]];
                self.minor.text=[self.minor.text stringByAppendingString:[NSString stringWithFormat:@" %d",minor]];
        switch (firstBecon.proximity) {
            case CLProximityImmediate:
                proximityUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://nivansys.com/iBeacon.php?proximity=Immediate"]];
                self.proxyRange.text=[self.proxyRange.text stringByAppendingString:@" Immediate"];
                break;
            case CLProximityNear:
                proximityUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://nivansys.com/iBeacon.php?proximity=Near"]];
                self.proxyRange.text=[self.proxyRange.text stringByAppendingString:@" Near"];

                break;
            case CLProximityFar:
                proximityUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://nivansys.com/iBeacon.php?proximity=Far"]];
                self.proxyRange.text=[self.proxyRange.text stringByAppendingString:@" Far"];

                break;
            case CLProximityUnknown:
                 proximityUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://nivansys.com/iBeacon.php?proximity=Far"]];
                self.proxyRange.text=[self.proxyRange.text stringByAppendingString:@" Far"];

                break;
            default:
                break;
        }
        [self excuteUrlAsync:proximityUrl];
    }
}
-(void)excuteUrlAsync:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(121, 0), ^{
        NSData *data=[NSData dataWithContentsOfURL:url];
   NSDictionary *response= [NSJSONSerialization JSONObjectWithData:data options:nil error:NULL];
       if(![response objectForKey:@"error"])
       {
           dispatch_sync(dispatch_get_main_queue(), ^{
               UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Promotinal Message" message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
               [alert show];

           });
        }
    });
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
