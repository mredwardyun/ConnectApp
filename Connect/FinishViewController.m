//
//  WaitingForConfirmationViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/16/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "FinishViewController.h"
#import "YO.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Parse/Parse.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@interface FinishViewController () <CBCentralManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *WaitingLabel;

@property (nonatomic) NSString *confirmationReceived;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;

@end

@implementation FinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (!self.needsReceive) {
		[self performActions];
	} else {
		// listen
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
		
		// And somewhere to store the incoming data
		_data = [[NSMutableData alloc] init];
	}
	
}

- (void)processConfirmation {
	NSString *confirmation = self.confirmationReceived;
	self.confirmedServicesWithInfo = [[NSMutableDictionary alloc] init];
	
	NSArray *components = [confirmation componentsSeparatedByString:@"\n"];
	for (NSString *component in components) {
		if ([component containsString:@"NAME:"]) {
			NSString *name = [component componentsSeparatedByString:@"NAME:"][1];
			[self.confirmedServicesWithInfo setObject:name forKey:@"NAME"];
		}
		else if ([component containsString:@"FB:"]) {
			NSString *fb = [component componentsSeparatedByString:@"FB:"][1];
			[self.confirmedServicesWithInfo setObject:fb forKey:@"FB"];
		}
		else if ([component containsString:@"PHONE:"]) {
			NSString *phone = [component componentsSeparatedByString:@"PHONE:"][1];
			[self.confirmedServicesWithInfo setObject:phone forKey:@"PHONE"];
		}
		else if ([component containsString:@"TWITTER:"]) {
			NSString *twitter = [component componentsSeparatedByString:@"TWITTER:"][1];
			[self.confirmedServicesWithInfo setObject:twitter forKey:@"TWITTER"];
		}
		else if ([component containsString:@"YO:"]) {
			NSString *yo = [component componentsSeparatedByString:@"YO:"][1];
			[self.confirmedServicesWithInfo setObject:yo forKey:@"YO"];
		}
	}
	[self performActions];
}

- (void)performActions{
	NSString *name = self.confirmedServicesWithInfo[@"NAME"];
	NSString *firstName = [name componentsSeparatedByString:@" "][0];
	NSString *lastName = [name componentsSeparatedByString:@" "][1];
	self.WaitingLabel.text = @"Confirmed!";
	if (self.confirmedServicesWithInfo[@"PHONE"]) {
		ABPeoplePickerNavigationController *peoplePicker=[[ABPeoplePickerNavigationController alloc] init];
		ABAddressBookRef addressBook = [peoplePicker addressBook];
		
		// create person record
		
		ABRecordRef person = ABPersonCreate();
		// set name and other string values
		
		NSString *phoneNo= self.confirmedServicesWithInfo[@"PHONE"];
		
		
		CFErrorRef cfError=nil;
		
		if (firstName) {
			ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName) , nil);
		}
		
		if (lastName) {
			ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName) , nil);
		}
		
		if (phoneNo)
		{
			ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			NSArray *venuePhoneNumbers = [phoneNo componentsSeparatedByString:@" or "];
			for (NSString *venuePhoneNumberString in venuePhoneNumbers)
				ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFStringRef) venuePhoneNumberString, kABPersonPhoneMainLabel, NULL);
			ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
			CFRelease(phoneNumberMultiValue);
		}
		
		
		//Add person Object to addressbook Object.
		ABAddressBookAddRecord(addressBook, person, &cfError);
		
		if (ABAddressBookSave(addressBook, nil)) {
			NSLog(@"\nPerson Saved successfuly");
		} else {
			NSLog(@"\n Error Saving person to AddressBook");
		}
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	if (self.confirmedServicesWithInfo[@"TWITTER"]) {
		NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/friendships/create.json?user_id=%@&follow=true", self.confirmedServicesWithInfo[@"TWITTER"]];
		NSURL *verify = [NSURL URLWithString:urlString];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
		[[PFTwitterUtils twitter] signRequest:request];
		NSURLResponse *response = nil;
		NSError *error;
		[NSURLConnection sendSynchronousRequest:request
							  returningResponse:&response
										  error:&error];
		NSLog(@"Think I added twitter");
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	if (self.confirmedServicesWithInfo[@"YO"]) {
		[YO sendYOToIndividualUser:self.confirmedServicesWithInfo[@"YO"]];
		NSLog(@"Think I added Yo");
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	if (self.confirmedServicesWithInfo[@"FBMANUAL"]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		NSString *urlString = [NSString stringWithFormat:@"fb://profile/%@", self.confirmedServicesWithInfo[@"FBMANUAL"]];
		NSURL *url = [NSURL URLWithString:urlString];
		[[UIApplication sharedApplication] openURL:url];
		NSLog(@"Think I added FBManual");
	}
	else if (self.confirmedServicesWithInfo[@"FB"]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		NSString *urlString = [NSString stringWithFormat:@"http://facebook.com/%@", self.confirmedServicesWithInfo[@"FB"]];
		NSURL *url = [NSURL URLWithString:urlString];
		[[UIApplication sharedApplication] openURL:url];
		NSLog(@"Think I added FB auto");
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
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
		self.confirmationReceived = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
		
		// Cancel our subscription to the characteristic
		[peripheral setNotifyValue:NO forCharacteristic:characteristic];
		
		// and disconnect from the peripehral
		[self.centralManager cancelPeripheralConnection:peripheral];
		[self processConfirmation];
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
	[self scan];
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
