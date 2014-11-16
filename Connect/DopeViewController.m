//
//  DopeViewController.m
//  Connect
//
//  Created by Edward Yun on 11/16/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "DopeViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import "FinishViewController.h"

@interface DopeViewController () <CBPeripheralManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *facebookImage;
@property (weak, nonatomic) IBOutlet UIImageView *twitterImage;
@property (weak, nonatomic) IBOutlet UIImageView *yoImage;
@property (weak, nonatomic) IBOutlet UIImageView *phoneImage;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *yoButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (nonatomic, assign) BOOL fbRequested;
@property (nonatomic, assign) BOOL twRequested;
@property (nonatomic, assign) BOOL yoRequested;
@property (nonatomic, assign) BOOL phRequested;

@property (nonatomic) NSString *requestToSend;

@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end

#define NOTIFY_MTU      20

@implementation DopeViewController

- (IBAction)facebookButtonPressed:(id)sender {
	if(self.facebookImage.alpha == 0.5){
		_fbRequested = YES;
		self.facebookImage.alpha = 1.0;
	}else{
		_fbRequested = NO;
		self.facebookImage.alpha = 0.5;
	}
}
- (IBAction)twitterButtonPressed:(id)sender {
	if (self.twitterImage.alpha == 0.5 && [self.availableServices containsObject:@"TWITTER"]){
		self.twitterImage.alpha = 1.0;
		_twRequested = YES;
	}else{
		_twRequested = NO;
		self.twitterImage.alpha = 0.5;
	}
}
- (IBAction)yoButtonPressed:(id)sender {
	if(self.yoImage.alpha == 0.5 && [self.availableServices containsObject:@"YO"]){
		self.yoImage.alpha = 1.0;
		_yoRequested = YES;
	}else{
		_yoRequested = NO;
		self.yoImage.alpha = 0.5;
	}
}

- (IBAction)phoneButtonPressed:(id)sender {
	if(self.phoneImage.alpha == 0.5 && [self.availableServices containsObject:@"PHONE"]){
		self.phoneImage.alpha = 1.0;
		_phRequested = YES;
	}else{
		_phRequested = NO;
		self.phoneImage.alpha = 0.5;
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	NSLog(@"Entered dopeview");
	_fbRequested = NO;
	_twRequested = NO;
	_yoRequested = NO;
	_phRequested = NO;
}

- (IBAction)sendButtonPressed:(id)sender {
	[self sendRequestForServices];
	_peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[NSThread sleepForTimeInterval:0.25];
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Start advertising");
			[self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
		});
	});
}

- (void)sendRequestForServices {
	NSMutableString *stringToSend = [[NSMutableString alloc] init];
	
	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"realname"];
	NSString *fb = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbusername"];
	NSString *fbmanual = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbmanual"];
	NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phonenumber"];
	NSString *twitter = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"];
	NSString *yo = [[NSUserDefaults standardUserDefaults] objectForKey:@"YoID"];
	[stringToSend appendString:[NSString stringWithFormat:@"NAME:%@\n", name]];
	if (_fbRequested) {
		[stringToSend appendString:[NSString stringWithFormat:@"FB:%@\n", fb]];
		if (fbmanual) {
			[stringToSend appendString:[NSString stringWithFormat:@"FBMANUAL:%@\n", fbmanual]];
		}
	}
	if (phone && _phRequested) {
		[stringToSend appendString:[NSString stringWithFormat:@"PHONE:%@\n", phone]];
	}
	if (twitter && _twRequested) {
		[stringToSend appendString:[NSString stringWithFormat:@"TWITTER:%@\n", twitter]];
	}
	if (yo && _yoRequested) {
		[stringToSend appendString:[NSString stringWithFormat:@"YO:%@\n", yo]];
	}
	self.requestToSend = stringToSend;
	NSLog(@"sendRequestForServices %@", self.requestToSend);
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	 if ([[segue destinationViewController] isKindOfClass:[FinishViewController class]]) {
		 ((FinishViewController *)[segue destinationViewController]).needsReceive = YES;
		 NSLog(@"dopeview moved to finish");
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
	self.dataToSend = [self.requestToSend dataUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"Data to send %@", self.dataToSend);
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
			
			// It did, so mark it as sent
			sendingEOM = NO;
			
			NSLog(@"Sent: EOM");
			
			[self.peripheralManager stopAdvertising];
			[self performSegueWithIdentifier:@"SendRequests" sender:self];
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
