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

@interface BroadcastingViewController () <CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic) NSMutableDictionary *requestedServicesWithInfo;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIImageView *Logo;

@property (nonatomic) NSString *messageToBroadcast;
@property (nonatomic) NSString *requestReceived;
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;

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

- (void)startListening {
	_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	
	// And somewhere to store the incoming data
	_data = [[NSMutableData alloc] init];
}

- (void)processRequests {
	NSString *messageReceived = self.requestReceived;
	NSLog(@"processrequests message received %@", messageReceived);
	self.requestedServicesWithInfo = [[NSMutableDictionary alloc] init];

	NSArray *components = [messageReceived componentsSeparatedByString:@"\n"];
	for (NSString *component in components) {
		if ([component containsString:@"NAME:"]) {
			NSString *name = [component componentsSeparatedByString:@"NAME:"][1];
			[self.requestedServicesWithInfo setObject:name forKey:@"NAME"];
		}
		else if ([component containsString:@"FB:"]) {
			NSString *fb = [component componentsSeparatedByString:@"FB:"][1];
			[self.requestedServicesWithInfo setObject:fb forKey:@"FB"];
		}
		else if ([component containsString:@"PHONE:"]) {
			NSString *phone = [component componentsSeparatedByString:@"PHONE:"][1];
			[self.requestedServicesWithInfo setObject:phone forKey:@"PHONE"];
		}
		else if ([component containsString:@"TWITTER:"]) {
			NSString *twitter = [component componentsSeparatedByString:@"TWITTER:"][1];
			[self.requestedServicesWithInfo setObject:twitter forKey:@"TWITTER"];
		}
		else if ([component containsString:@"YO:"]) {
			NSString *yo = [component componentsSeparatedByString:@"YO:"][1];
			[self.requestedServicesWithInfo setObject:yo forKey:@"YO"];
		}
	}
	NSLog(@"processrequests requested services %@", self.requestedServicesWithInfo);
	[self.peripheralManager stopAdvertising];
	[self.centralManager stopScan];
	[self performSegueWithIdentifier:@"ConfirmRequests" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSLog(@"Prepare for segue");
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
			[self startListening];
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


#pragma mark - Central Methods



/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	if (central.state != CBCentralManagerStatePoweredOn) {
		// In a real app, you'd deal with all the states correctly
		return;
	}
	
	// The state must be CBCentralManagerStatePoweredOn...
	
	// ... so start scanning
	[self scan];
	
}


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
	[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
												options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
	
	NSLog(@"Scanning started");
}


/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	// Reject any where the value is above reasonable range
	if (RSSI.integerValue > -15) {
		return;
	}
	
	// Reject if the signal strength is too low to be close enough (Close is around -22dB)
	if (RSSI.integerValue < -35) {
		return;
	}
	
	NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
	
	// Ok, it's in range - have we already seen it?
	if (self.discoveredPeripheral != peripheral) {
		
		// Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
		self.discoveredPeripheral = peripheral;
		
		// And connect
		NSLog(@"Connecting to peripheral %@", peripheral);
		[self.centralManager connectPeripheral:peripheral options:nil];
	}
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
	[self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	NSLog(@"Peripheral Connected");
	
	// Stop scanning
	[self.centralManager stopScan];
	NSLog(@"Scanning stopped");
	
	// Clear the data that we may already have
	[self.data setLength:0];
	
	// Make sure we get the discovery callbacks
	peripheral.delegate = self;
	
	// Search only for services that match our UUID
	[peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	if (error) {
		NSLog(@"Error discovering services: %@", [error localizedDescription]);
		[self cleanup];
		return;
	}
	
	// Discover the characteristic we want...
	
	// Loop through the newly filled peripheral.services array, just in case there's more than one.
	for (CBService *service in peripheral.services) {
		[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
	}
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	// Deal with errors (if any)
	if (error) {
		NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
		[self cleanup];
		return;
	}
	
	// Again, we loop through the array, just in case.
	for (CBCharacteristic *characteristic in service.characteristics) {
		
		// And check if it's the right one
		if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
			
			// If it is, subscribe to it
			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
		}
	}
	
	// Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (error) {
		NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
		return;
	}
	
	NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
	
	// Have we got everything we need?
	if ([stringFromData isEqualToString:@"EOM"]) {
		
		// We have, so show the data,
		self.requestReceived = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
		
		// Cancel our subscription to the characteristic
		[peripheral setNotifyValue:NO forCharacteristic:characteristic];
		
		// and disconnect from the peripehral
		[self.centralManager cancelPeripheralConnection:peripheral];
		[self processRequests];
	}
	
	// Otherwise, just add the data on to what we already have
	[self.data appendData:characteristic.value];
	
	// Log it
	NSLog(@"Received: %@", stringFromData);
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (error) {
		NSLog(@"Error changing notification state: %@", error.localizedDescription);
	}
	
	// Exit if it's not the transfer characteristic
	if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
		return;
	}
	
	// Notification has started
	if (characteristic.isNotifying) {
		NSLog(@"Notification began on %@", characteristic);
	}
	
	// Notification has stopped
	else {
		// so disconnect from the peripheral
		NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
		[self.centralManager cancelPeripheralConnection:peripheral];
	}
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	NSLog(@"Peripheral Disconnected");
	self.discoveredPeripheral = nil;
	
	// We're disconnected, so start scanning again
//	[self scan];
}


/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
	// Don't do anything if we're not connected
	if (!self.discoveredPeripheral.isConnected) {
		return;
	}
	
	// See if we are subscribed to a characteristic on the peripheral
	if (self.discoveredPeripheral.services != nil) {
		for (CBService *service in self.discoveredPeripheral.services) {
			if (service.characteristics != nil) {
				for (CBCharacteristic *characteristic in service.characteristics) {
					if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
						if (characteristic.isNotifying) {
							// It is notifying, so unsubscribe
							[self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
							
							// And we're done.
							return;
						}
					}
				}
			}
		}
	}
	
	// If we've got this far, we're connected, but we're not subscribed, so we just disconnect
	[self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}


@end
