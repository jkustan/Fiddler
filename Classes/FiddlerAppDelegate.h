/**
 * Project: Fiddler: Calculating sunrise & sunset times in Objective C
 * File name: FiddlerAppDelegate.h
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

#import <UIKit/UIKit.h>
@class FiddlerTestController;

@interface FiddlerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	FiddlerTestController *fiddlerTestController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) FiddlerTestController *fiddlerTestController;
@end

