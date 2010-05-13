/**
 * Project: Fiddler: Calculating sunrise & sunset times in Objective C
 * File name: Fiddler.h
 * Description:  This contains the basic functions to calculate sunrise & sunset
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

#import <Foundation/Foundation.h>
#import "Time.h"

@interface Fiddler : NSObject {
	double latitude;
	double longitude;
	NSTimeZone *timeZone;
	NSDate *sunrise;
	NSDate *sunset;
	NSDate *date;
}

@property() double latitude;
@property() double longitude;
@property(nonatomic,retain) NSDate *date;
@property(nonatomic,retain) NSTimeZone *timeZone;
@property(nonatomic,retain) NSDate *sunrise;
@property(nonatomic,retain) NSDate *sunset;

- (Fiddler*) initWithDate:(NSDate*) myDate timeZone:(NSTimeZone*) tz latitude:(double) lat longitude:(double) lon;
- (void) reload;

-(void) setupSunriseSunset;
-(double) calcJD;
-(double) calcTimeJulianCent:(double)jd;
-(double) calcSunriseUTC;
-(double) calcSunriseUTCForDegree:(double) degAngle;
-(double) calcSunsetUTC;
-(double) calcSunsetUTCForDegree:(double) degAngle;
-(double) calcEquationOfTime:(double)t;
-(double) calcMeanObliquityOfEcliptic:(double)t;
-(double) calcObliquityCorrection:(double) t;
-(double) calcGeomMeanLongSun:(double) t;
-(double) calcSunApparentLong:(double) t;
-(double) calcSunDeclination:(double) t;
-(double) calcSunTrueLong:(double)t;
-(double) calcSunEqOfCenter:(double) t;
-(double) calcGeomMeanAnomalySun:(double) t;
-(double) calcEccentricityEarthOrbit: (double) t;
-(double) calcHourAngleSunrise:(double)lat withSolarDec:(double)solarDec degAngle:(double) degAngle;
-(double) calcHourAngleSunset:(double)lat withSolarDec:(double)solarDec	degAngle:(double) degAngle;
-(double) calcJDFromJulianCent:(double) t;
-(double) degToRad:(double)angleDeg;
-(double) radToDeg:(double)angleRad;



@end
