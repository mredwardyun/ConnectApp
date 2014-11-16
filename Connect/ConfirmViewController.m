//
//  ConfirmViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "ConfirmViewController.h"
#import "FinishViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@interface ConfirmViewController () <CBPeripheralManagerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *phoneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *yoSwitch;

@property (nonatomic) NSMutableDictionary *confirmedServicesWithInfo;
@property (nonatomic) NSString *confirmationToSend;
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end

#define NOTIFY_MTU      20

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	NSArray *requestedServices = [self.requestedServicesWithInfo allKeys];
	if (![requestedServices containsObject:@"FB"]) {
		[self.facebookSwitch setEnabled:NO];
	}
	if (![requestedServices containsObject:@"PHONE"]) {
		[self.phoneSwitch setEnabled:NO];
	}
	if (![requestedServices containsObject:@"TWITTER"]) {
		[self.twitterSwitch setEnabled:NO];
	}
	if (![requestedServices containsObject:@"YO"]) {
		[self.yoSwitch setEnabled:NO];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
}

- (void)sendConfirmation {
	NSMutableString *stringToSend = [[NSMutableString alloc] init];
	self.confirmedServicesWithInfo = [[NSMutableDictionary alloc] init];
	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"realname"];
	NSString *fb = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbusername"];
	NSString *fbmanual = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbmanual"];
	NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phonenumber"];
	NSString *twitter = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"];
	NSString *yo = [[NSUserDefaults standardUserDefaults] objectForKey:@"YoID"];
	[stringToSend appendString:[NSString stringWithFormat:@"NAME:%@\n", name]];
	[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"NAME"] forKey:@"NAME"];
	if (self.facebookSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"FB:%@\n", fb]];
		[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"FB"] forKey:@"FB"];
		if (fbmanual) {
			[stringToSend appendString:[NSString stringWithFormat:@"FBMANUAL:%@\n", fbmanual]];
		}
		if (self.requestedServicesWithInfo[@"FBMANUAL"]) {
			[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"FBMANUAL"] forKey:@"FBMANUAL"];
		}
	}
	if (phone && self.phoneSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"PHONE:%@\n", phone]];
		[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"PHONE"] forKey:@"PHONE"];
	}
	if (twitter && self.twitterSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"TWITTER:%@\n", twitter]];
		[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"TWITTER"] forKey:@"TWITTER"];
	}
	if (yo && self.yoSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"YO:%@\n", yo]];
		[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"YO"] forKey:@"YO"];
	}
	self.confirmationToSend = stringToSend;
	NSLog(@"sendconfirmation stringToSend %@", stringToSend);
	NSLog(@"sendconfirmation confirmedServicesWithInfo %@", self.confirmedServicesWithInfo);
}
- (IBAction)confirmButtonPressed:(id)sender {
	_peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[NSThread sleepForTimeInterval:0.25];
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Start advertising");
			[self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
		});
	});
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue destinationViewController] isKindOfClass:[FinishViewController class]]) {
		((FinishViewController *)[segue destinationViewController]).confirmedServicesWithInfo = self.confirmedServicesWithInfo;
		((FinishViewController *)[segue destinationViewController]).needsReceive = NO;
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
	self.dataToSend = [self.confirmationToSend dataUsingEncoding:NSUTF8StringEncoding];
	
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
			[self performSegueWithIdentifier:@"SendRequests" sender:self];
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


@end
