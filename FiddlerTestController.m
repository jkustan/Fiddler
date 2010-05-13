/**
 * Project: Fiddler: Calculating sunrise & sunset times in Objective C
 * File name: FiddlerTestController.m
 * Description:  This is the testbed for the Fiddler functions
 *   
 * @author Jack Kustanowitz, MountainPass Technology LLC http://www.MountainPassTech.com, Copyright (C) 2010.
 *   
 * @see The GNU Public License (GPL)
 * 
 * This program is free software; you can redistribute it and/or modify 
 * it under the terms of the GNU General Public License as published by 
 * the Free Software Foundation; either version 2 of the License, or 
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
 * for more details.
 * 
 * You should have received a copy of the GNU General Public License along with Fiddler. If not, see http://www.gnu.org/licenses/.
 */

#import "FiddlerTestController.h"
#import "Fiddler.h"


@implementation FiddlerTestController

@synthesize txtLatitude, txtLongitude, txtTZOffset, lblDate, lblSunrise, lblSunset;

NSString * const DateFormat = @"MM/dd/yy";


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	// set up the current date
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	NSString* date = [dateFormatter stringFromDate:[NSDate date]];
	lblDate.text = date;
	
}
 
 - (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	 [theTextField resignFirstResponder];
	 return YES;
 }

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction) btnCalculate_Clicked: (id) sender	{
	// set up formatter
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:DateFormat];
	
	// set up current time zone
	NSTimeZone* tz =  [NSTimeZone timeZoneForSecondsFromGMT:([txtTZOffset.text intValue] * 3600)];
								
	// get current date
	NSDate* date = [formatter dateFromString:lblDate.text];
	
	// set up Fiddler object
	Fiddler* fiddler = [[Fiddler alloc] initWithDate:date timeZone:tz latitude:[txtLatitude.text doubleValue] longitude:[txtLongitude.text doubleValue]];
	
	// setup sunrise/sunset
	[fiddler reload];

	// display computed values
	[formatter setTimeStyle:NSDateFormatterFullStyle];
	lblSunrise.text = [formatter stringFromDate:fiddler.sunrise];
	lblSunset.text = [formatter stringFromDate:fiddler.sunset];
}

-(IBAction) btnChangeDate_Clicked: (id) sender	{
	// set up the actionsheet with the date picker
	NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n";
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:title delegate:self
								  cancelButtonTitle:nil
								  destructiveButtonTitle:nil
								  otherButtonTitles:@"Set", nil];
	
	UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];
	datePicker.datePickerMode = UIDatePickerModeDate;
	datePicker.tag = 101;
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:DateFormat];
	NSDate* date = [formatter dateFromString:lblDate.text];
	datePicker.date = date;
	[actionSheet addSubview:datePicker];
	
	[actionSheet showInView:self.view];

}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex	{
	// Recover the picker
	UIDatePicker *datePicker = (UIDatePicker*) [actionSheet viewWithTag:101];;
	
	// set up the date label on the form
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"MM/dd/yy"];
	 NSString *timestamp = [formatter stringFromDate:datePicker.date];
	 lblDate.text = timestamp;
	
	 [actionSheet release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
