//
//  BroadcastingViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "BroadcastingViewController.h"
#import "ConfirmViewController.h"
#import "FUIButton.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@interface BroadcastingViewController () <CBPeripheralManagerDelegate>

@property (nonatomic) NSMutableDictionary *requestedServicesWithInfo;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIImageView *Logo;

@property (nonatomic) NSString *messageToBroadcast;
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end

#define NOTIFY_MTU      20

@implementation BroadcastingViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self prepareBroadcastMessage];
	_peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
	
	UIImage *originalImage = self.Logo.image;
	double width = originalImage.size.width;
	double height = originalImage.size.height;
	double apect = width/height;
	
	double nHeight = 320.f/ apect;
	self.Logo.frame = CGRectMake(0, 0, 320, nHeight);
	self.Logo.center = self.view.center;
	self.Logo.image = originalImage;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[NSThread sleepForTimeInterval:0.25];
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Start advertising");
			[self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
		});
	});
}

- (void)viewWillDisappear:(BOOL)animated
{
	// Don't keep it going while we're not showing.
	[self.peripheralManager stopAdvertising];
	
	[super viewWillDisappear:animated];
}

- (void)prepareBroadcastMessage {
	NSMutableString *messageToBroadcast = [[NSMutableString alloc] init];
	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"realname"];
	NSString *fb = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbusername"];
	NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phonenumber"];
	NSString *twitter = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"];
	NSString *yo = [[NSUserDefaults standardUserDefaults] objectForKey:@"YoID"];
	
	[messageToBroadcast appendString:[NSString stringWithFormat:@"NAME:%@\n", name]];
	[messageToBroadcast appendString:[NSString stringWithFormat:@"FB:%@\n", fb]];
	
	if (phone) {
		[messageToBroadcast appendString:@"PHONE"];
	}
	if (twitter) {
		[messageToBroadcast appendString:@"TWITTER\n"];
	}
	if (yo) {
		[messageToBroadcast appendString:@"YO\n"];
	}
	NSLog(@"broadcastmessage %@", messageToBroadcast);
	self.messageToBroadcast = messageToBroadcast;
	// broadcast this message
	
}

//- (void)listenForRequests {
//	NSString *messageReceived = @""; //change
//	NSLog(@"listenforrequests message received %@", messageReceived);
//	self.requestedServicesWithInfo = [[NSMutableDictionary alloc] init];
//
//	NSArray *components = [messageReceived componentsSeparatedByString:@"\n"];
//	for (NSString *component in components) {
//		if ([component containsString:@"NAME:"]) {
//			NSString *name = [component componentsSeparatedByString:@"NAME:"][1];
//			[self.requestedServicesWithInfo setObject:name forKey:@"NAME"];
//		}
//		else if ([component containsString:@"FB:"]) {
//			NSString *fb = [component componentsSeparatedByString:@"FB:"][1];
//			[self.requestedServicesWithInfo setObject:fb forKey:@"FB"];
//		}
//		else if ([component containsString:@"PHONE:"]) {
//			NSString *phone = [component componentsSeparatedByString:@"PHONE:"][1];
//			[self.requestedServicesWithInfo setObject:phone forKey:@"PHONE"];
//		}
//		else if ([component containsString:@"TWITTER:"]) {
//			NSString *twitter = [component componentsSeparatedByString:@"TWITTER:"][1];
//			[self.requestedServicesWithInfo setObject:twitter forKey:@"TWITTER"];
//		}
//		else if ([component containsString:@"YO:"]) {
//			NSString *yo = [component componentsSeparatedByString:@"YO:"][1];
//			[self.requestedServicesWithInfo setObject:yo forKey:@"YO"];
//		}
//	}
//	NSLog(@"listenforrequests requestedserviceswithinfo %@", self.requestedServicesWithInfo);
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[self.peripheralManager stopAdvertising];
	if ([[segue destinationViewController] isKindOfClass:[ConfirmViewController class]]) {
		((ConfirmViewController *)[segue destinationViewController]).requestedServicesWithInfo = self.requestedServicesWithInfo;
	}
}



#pragma mark - Peripheral Methods



/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
	// Opt out from any other state
	if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
		return;
	}
	
	// We're in CBPeripheralManagerStatePoweredOn state...
	NSLog(@"self.peripheralManager powered on.");
	
	// ... so build our service.
	
	// Start with the CBMutableCharacteristic
	self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
																	 properties:CBCharacteristicPropertyNotify
																		  value:nil
																	permissions:CBAttributePermissionsReadable];
	
	// Then the service
	CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
																	   primary:YES];
	
	// Add the characteristic to the service
	transferService.characteristics = @[self.transferCharacteristic];
	
	// And add it to the peripheral manager
	[self.peripheralManager addService:transferService];
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
	NSLog(@"Central subscribed to characteristic");
	
	// Get the data
	self.dataToSend = [self.messageToBroadcast dataUsingEncoding:NSUTF8StringEncoding];
	
	// Reset the index
	self.sendDataIndex = 0;
	
	// Start sending
	[self sendData];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
	NSLog(@"Central unsubscribed from characteristic");
}


/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
	// First up, check if we're meant to be sending an EOM
	static BOOL sendingEOM = NO;
	
	if (sendingEOM) {
		
		// send it
		BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
		
		// Did it send?
		if (didSend) {
			[self.peripheralManager stopAdvertising];
			// It did, so mark it as sent
			sendingEOM = NO;
			
			NSLog(@"Sent: EOM");
		}
		
		// It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
		return;
	}
	
	// We're not sending an EOM, so we're sending data
	
	// Is there any left to send?
	
	if (self.sendDataIndex >= self.dataToSend.length) {
		
		// No data left.  Do nothing
		return;
	}
	
	// There's data left, so send until the callback fails, or we're done.
	
	BOOL didSend = YES;
	
	while (didSend) {
		
		// Make the next chunk
		
		// Work out how big it should be
		NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
		
		// Can't be longer than 20 bytes
		if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
		
		// Copy out the data we want
		NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
		
		// Send it
		didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
		
		// If it didn't work, drop out and wait for the callback
		if (!didSend) {
			return;
		}
		
		NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
		NSLog(@"Sent: %@", stringFromData);
		
		// It did send, so update our index
		self.sendDataIndex += amountToSend;
		
		// Was it the last one?
		if (self.sendDataIndex >= self.dataToSend.length) {
			
			// It was - send an EOM
			
			// Set this so if the send fails, we'll send it next time
			sendingEOM = YES;
			
			// Send it
			BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
			
			if (eomSent) {
				// It sent, we're all done
				sendingEOM = NO;
				
				NSLog(@"Sent: EOM");
			}
			
			return;
		}
	}
}

/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
	// Start sending again
	[self sendData];
}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];

    //self.connectButton.buttonColor = [UIColor turquoiseColor];
    //self.connectButton.shadowColor = [UIColor greenSeaColor];
    //self.connectButton.shadowHeight = 0.0f;
    //self.connectButton.cornerRadius = 4.0f;
    //self.connectButton.titleLabel.font = [UIFont flatFontOfSize:30];
    //[self.connectButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    //[self.connectButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    //CGRect buttonFrame = self.connectButton.frame;
    //buttonFrame.size = CGSizeMake(200, 200);
    //self.connectButton.frame = buttonFrame;
	
//}

@end
