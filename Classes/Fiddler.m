/**
 * Project: Fiddler: Calculating sunrise & sunset times in Objective C
 * File name: Fiddler.m
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

#import "Fiddler.h"
#import <Math.h>


// Ported from the Javascript version at: http://www.csgnetwork.com/sunriseset.html

@implementation Fiddler
@synthesize latitude,longitude,timeZone,date,sunrise,sunset;

- (Fiddler*) initWithDate:(NSDate*) myDate timeZone:(NSTimeZone*) tz latitude:(double) lat longitude:(double) lon
{
	if (self = [super init])
	{
		self.date = myDate;
		self.timeZone = tz;
		self.latitude = lat;
		self.longitude = lon;
	}
	
	[self reload];

	return self;
}

- (void) setTimeZone:(NSTimeZone *)tz	{
	[NSTimeZone setDefaultTimeZone:tz];
	timeZone = tz;
}

- (void) reload	{
	if (!timeZone || (latitude == 0 && longitude == 0))
	{
		NSLog(@"Missing critical information.  Exiting.");
		return;
	}
	
	// compute values
	[self setupSunriseSunset];
	
}

- (void) setupSunriseSunset  {
	[[NSCalendar currentCalendar] setTimeZone:self.timeZone];
	unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit;
	
	// Sunrise
	double utc = [self calcSunriseUTC];
	NSDate *gmt = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:(utc * 60.0)];
	NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:gmt];
	[gmt release];
	NSLog(@"sunrise = %d/%d/%d %d:%d:%d", comps.month, comps.day, comps.year, comps.hour, comps.minute, comps.second);	

	self.sunrise = [[NSCalendar currentCalendar] dateFromComponents:comps];		
	self.sunrise = [sunrise addTimeInterval:[timeZone daylightSavingTimeOffsetForDate:sunrise]];
	
	// Sunset
	utc = [self calcSunsetUTC];
	gmt = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:(utc * 60.0)];
	comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:gmt];
	[gmt release];
	NSLog(@"sunset = %d/%d/%d %d:%d:%d", comps.month, comps.day, comps.year, comps.hour, comps.minute, comps.second);	

	self.sunset = [[NSCalendar currentCalendar] dateFromComponents:comps];	
	self.sunset = [sunset addTimeInterval:[timeZone daylightSavingTimeOffsetForDate:sunset]];
}


/*/
//***********************************************************************/
//* Name:    calcSunriseUTC								*/
//* Type:    Function									*/
//* Purpose: calculate the Universal Coordinated Time (UTC) of sunrise	*/
//*			for the given day at the given location on earth	*/
//* Arguments:										*/
//*   JD  : julian day									*/
//*   latitude : latitude of observer in degrees				*/
//*   longitude : longitude of observer in degrees				*/
//* Return value:										*/
//*   time in minutes from zero Z							*/
//***********************************************************************/
-(double)calcSunriseUTC {
	return [self calcSunriseUTCForDegree:90.833];
}

-(double)calcSunriseUTCForDegree:(double) degAngle {
	double jd = [self calcJD];
	
	double t = [self calcTimeJulianCent:jd];
	
	// *** First pass to approximate sunrise
	double eqTime = [self calcEquationOfTime:t];
	double solarDec = [self calcSunDeclination:t];
	
	double hourAngle = [self calcHourAngleSunrise:latitude withSolarDec:solarDec degAngle:degAngle];

	double delta = longitude - [self radToDeg:hourAngle];
	
	double timeDiff = 4 * delta;	// in minutes of time
	
	double timeUTC = 720 + timeDiff - eqTime;	// in minutes
		
//	NSLog(@"eqTime = %f\nsolarDec = %f\ntimeUTC = %f", eqTime, solarDec, timeUTC);
	
	// *** Second pass includes fractional jday in gamma calc
	double newt = [self calcTimeJulianCent:([self calcJDFromJulianCent:t] + timeUTC/1440.0)]; 
	eqTime = [self calcEquationOfTime:newt];
	solarDec = [self calcSunDeclination:newt];
	hourAngle = [self calcHourAngleSunrise:latitude withSolarDec:solarDec degAngle:degAngle];
	
	delta = longitude - [self radToDeg:hourAngle];
	timeDiff = 4 * delta;
	timeUTC = 720 + timeDiff - eqTime; // in minutes
		
	return timeUTC;
}

//***********************************************************************/
//* Name:    calcSunsetUTC								*/
//* Type:    Function									*/
//* Purpose: calculate the Universal Coordinated Time (UTC) of sunset	*/
//*			for the given day at the given location on earth	*/
//* Arguments:										*/
//*   JD  : julian day									*/
//*   latitude : latitude of observer in degrees				*/
//*   longitude : longitude of observer in degrees				*/
//* Return value:										*/
//*   time in minutes from zero Z							*/
//***********************************************************************/
-(double) calcSunsetUTC {
	return [self calcSunsetUTCForDegree:90.833];
}

-(double) calcSunsetUTCForDegree:(double) degAngle {
	double jd = [self calcJD];
	double t = [self calcTimeJulianCent:jd];
	
	// *** First pass to approximate sunset
	double eqTime = [self calcEquationOfTime:t];
	double solarDec = [self calcSunDeclination:t];
	
	double hourAngle = [self calcHourAngleSunset:latitude withSolarDec:solarDec degAngle:degAngle];
	double delta = longitude - [self radToDeg:hourAngle];
	
	double timeDiff = 4 * delta;	// in minutes of time
	
	double timeUTC = 720 + timeDiff - eqTime;	// in minutes
	
//	NSLog(@"eqTime = %f\nsolarDec = %f\ntimeUTC = %f", eqTime, solarDec, timeUTC);
	
	// *** Second pass includes fractional jday in gamma calc
	double newt = [self calcTimeJulianCent:([self calcJDFromJulianCent:t] + timeUTC/1440.0)]; 
	eqTime = [self calcEquationOfTime:newt];
	solarDec = [self calcSunDeclination:newt];
	hourAngle = [self calcHourAngleSunset:latitude withSolarDec:solarDec degAngle:degAngle];
	
	delta = longitude - [self radToDeg:hourAngle];
	timeDiff = 4 * delta;
	timeUTC = 720 + timeDiff - eqTime; // in minutes
	
	return timeUTC;
	
}




//***********************************************************************/
//* Name:    calcJD									*/
//* Type:    Function									*/
//* Purpose: Julian day from calendar day						*/
//* Arguments:										*/
//*   year : 4 digit year								*/
//*   month: January = 1								*/
//*   day  : 1 - 31									*/
//* Return value:										*/
//*   The Julian day corresponding to the date					*/
//* Note:											*/
//*   Number is returned for start of day.  Fractional days should be	*/
//*   added later.									*/
//***********************************************************************/
-(double)calcJD
{
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:date];
	
	int year = [dateComponents year];
	int month = [dateComponents month];
	int day = [dateComponents day];
	
	if (month <= 2) {
		year -= 1;
		month += 12;
	}
	
	double A = floor(year/100);
	double B = 2 - A + (floor(A/4));
	double JD = floor(365.25 * (year + 4716)) + (floor(30.6001*(month+1))) + day + B - 1524.5;
	
	return JD;	
}

//***********************************************************************/
//* Name:    calcTimeJulianCent							*/
//* Type:    Function									*/
//* Purpose: convert Julian Day to centuries since J2000.0.			*/
//* Arguments:										*/
//*   jd : the Julian Day to convert						*/
//* Return value:										*/
//*   the T value corresponding to the Julian Day				*/
//***********************************************************************/
-(double)calcTimeJulianCent:(double)jd
{
	double T = (jd - 2451545.0)/36525.0;	
	return T;
}

//***********************************************************************/
//* Name:    calcEquationOfTime							*/
//* Type:    Function									*/
//* Purpose: calculate the difference between true solar time and mean	*/
//*		solar time									*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   equation of time in minutes of time						*/
//***********************************************************************/
-(double)calcEquationOfTime:(double)t	{
	double epsilon = [self calcObliquityCorrection:t];
	double l0 = [self calcGeomMeanLongSun:t];
	double e = [self calcEccentricityEarthOrbit:t];
	double m = [self calcGeomMeanAnomalySun:t];
	double y = tan([self degToRad:epsilon]/2.0);
	
	y *= y;
	
	double sin2l0 = sin(2.0 * [self degToRad:l0]);
	double sinm   = sin([self degToRad:m]);
	double cos2l0 = cos(2.0 * [self degToRad:l0]);
	double sin4l0 = sin(4.0 * [self degToRad:l0]);
	double sin2m  = sin(2.0 * [self degToRad:m]);
	
	double Etime = y * sin2l0 - 2.0 * e * sinm + 4.0 * e * y * sinm * cos2l0
	
	- 0.5 * y * y * sin4l0 - 1.25 * e * e * sin2m;
	return [self radToDeg:(Etime*4.0)];	// in minutes of time
	
}

//***********************************************************************/
//* Name:    calcObliquityCorrection						*/
//* Type:    Function									*/
//* Purpose: calculate the corrected obliquity of the ecliptic		*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   corrected obliquity in degrees						*/
//***********************************************************************/
-(double)calcObliquityCorrection:(double) t	{
	double e0 = [self calcMeanObliquityOfEcliptic:t];
	double omega = 125.04 - 1934.136 * t;
	double e = e0 + 0.00256 * cos([self degToRad:omega]);

	return e;		// in degrees
}

//***********************************************************************/
//* Name:    calcMeanObliquityOfEcliptic						*/
//* Type:    Function									*/
//* Purpose: calculate the mean obliquity of the ecliptic			*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   mean obliquity in degrees							*/
//***********************************************************************/
-(double)calcMeanObliquityOfEcliptic:(double)t	{
	double seconds = 21.448 - t*(46.8150 + t*(0.00059 - t*(0.001813)));
	double e0 = 23.0 + (26.0 + (seconds/60.0))/60.0;

	return e0;		// in degrees
}


//***********************************************************************/
//* Name:    calGeomMeanLongSun							*/
//* Type:    Function									*/
//* Purpose: calculate the Geometric Mean Longitude of the Sun		*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   the Geometric Mean Longitude of the Sun in degrees			*/
//***********************************************************************/
-(double) calcGeomMeanLongSun:(double) t	{
	double L0 = 280.46646 + t * (36000.76983 + 0.0003032 * t);
	
	while(L0 > 360.0)	{
		L0 -= 360.0;
	}
	
	while(L0 < 0.0)	{
		L0 += 360.0;
	}
	
	return L0;		// in degrees
	
}

//***********************************************************************/
//* Name:    calcSunDeclination							*/
//* Type:    Function									*/
//* Purpose: calculate the declination of the sun				*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   sun's declination in degrees							*/
//***********************************************************************/
-(double) calcSunDeclination:(double) t	{
	double e = [self calcObliquityCorrection:t];
	double lambda = [self calcSunApparentLong:t];
	double sint = sin([self degToRad:e]) * sin([self degToRad:lambda]);
	double theta = [self radToDeg:asin(sint)];
	
	return theta;		// in degrees
	
}

//***********************************************************************/
//* Name:    calcSunApparentLong							*/
//* Type:    Function									*/
//* Purpose: calculate the apparent longitude of the sun			*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   sun's apparent longitude in degrees						*/
//***********************************************************************/
-(double) calcSunApparentLong:(double) t	{
	double o = [self calcSunTrueLong:t];
	double omega = 125.04 - 1934.136 * t;
	double lambda = o - 0.00569 - 0.00478 * sin([self degToRad:omega]);
	
	return lambda;		// in degrees
}


//***********************************************************************/
//* Name:    calcSunTrueLong								*/
//* Type:    Function									*/
//* Purpose: calculate the true longitude of the sun				*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   sun's true longitude in degrees						*/
//***********************************************************************/
-(double) calcSunTrueLong:(double)t	{
	double l0 = [self calcGeomMeanLongSun:t];
	double c = [self calcSunEqOfCenter:t];
	double O = l0 + c;
	
	return O;		// in degrees
}

//***********************************************************************/
//* Name:    calcSunEqOfCenter							*/
//* Type:    Function									*/
//* Purpose: calculate the equation of center for the sun			*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   in degrees										*/
//***********************************************************************/
-(double) calcSunEqOfCenter:(double) t	{
	double m = [self calcGeomMeanAnomalySun:t];
	double mrad = [self degToRad:m];
	double sinm = sin(mrad);
	double sin2m = sin(mrad+mrad);
	double sin3m = sin(mrad+mrad+mrad);
	double C = sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin2m * (0.019993 - 0.000101 * t) + sin3m * 0.000289;
	
	return C;		// in degrees
	
}

//***********************************************************************/
//* Name:    calGeomAnomalySun							*/
//* Type:    Function									*/
//* Purpose: calculate the Geometric Mean Anomaly of the Sun		*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   the Geometric Mean Anomaly of the Sun in degrees			*/
//***********************************************************************/
-(double) calcGeomMeanAnomalySun:(double) t	{
	double M = 357.52911 + t * (35999.05029 - 0.0001537 * t);
	return M;		// in degrees
}


//***********************************************************************/
//* Name:    calcEccentricityEarthOrbit						*/
//* Type:    Function									*/
//* Purpose: calculate the eccentricity of earth's orbit			*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   the unitless eccentricity							*/
//***********************************************************************/
-(double) calcEccentricityEarthOrbit: (double) t	{
	double e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
	return e;		// unitless
}

//***********************************************************************/
//* Name:    calcHourAngleSunrise							*/
//* Type:    Function									*/
//* Purpose: calculate the hour angle of the sun at sunrise for the	*/
//*			latitude								*/
//* Arguments:										*/
//*   lat : latitude of observer in degrees					*/
//*	solarDec : declination angle of sun in degrees				*/
//* Return value:										*/
//*   hour angle of sunrise in radians						*/
//***********************************************************************/
-(double) calcHourAngleSunrise:(double)lat withSolarDec:(double)solarDec degAngle:(double) degAngle	{
	double latRad = [self degToRad:lat];
	double sdRad  = [self degToRad:solarDec];
	//	double HAarg = (cos([self degToRad:90.833])/(cos(latRad)*cos(sdRad))-tan(latRad) * tan(sdRad));
	double HA = (acos(cos([self degToRad:degAngle])/(cos(latRad)*cos(sdRad))-tan(latRad) * tan(sdRad)));
	
	return HA;		// in radians		
}

//***********************************************************************/
//* Name:    calcHourAngleSunset							*/
//* Type:    Function									*/
//* Purpose: calculate the hour angle of the sun at sunset for the	*/
//*			latitude								*/
//* Arguments:										*/
//*   lat : latitude of observer in degrees					*/
//*	solarDec : declination angle of sun in degrees				*/
//* Return value:										*/
//*   hour angle of sunset in radians						*/
//***********************************************************************/
-(double) calcHourAngleSunset:(double)lat withSolarDec:(double)solarDec	degAngle:(double) degAngle{
	double latRad = [self degToRad:lat];
	double sdRad  = [self degToRad:solarDec];
	//	double HAarg = (cos([self degToRad:90.833])/(cos(latRad)*cos(sdRad))-tan(latRad) * tan(sdRad));
	double HA = (acos(cos([self degToRad:degAngle])/(cos(latRad)*cos(sdRad))-tan(latRad) * tan(sdRad)));
	
	return -HA;		// in radians
}


//***********************************************************************/
//* Name:    calcJDFromJulianCent							*/
//* Type:    Function									*/
//* Purpose: convert centuries since J2000.0 to Julian Day.			*/
//* Arguments:										*/
//*   t : number of Julian centuries since J2000.0				*/
//* Return value:										*/
//*   the Julian Day corresponding to the t value				*/
//***********************************************************************/
-(double) calcJDFromJulianCent:(double) t	{
	double JD = t * 36525.0 + 2451545.0;
	return JD;
}



#pragma mark -
#pragma mark Calculate Solar Position
// Convert radian angle to degrees
-(double)radToDeg:(double)angleRad {
	return (180.0 * angleRad / M_PI);
}

// Convert degree angle to radians
-(double)degToRad:(double)angleDeg	{
	return (M_PI * angleDeg / 180.0);
}

- (void)dealloc {
	[self.sunrise release];
	[self.sunset release];
	[self.date release];
	[self.timeZone release];
    [super dealloc];
}





@end
