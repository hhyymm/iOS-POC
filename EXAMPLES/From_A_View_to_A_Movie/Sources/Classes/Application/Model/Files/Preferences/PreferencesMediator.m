//---------------------------------------------------------------------------------------
//
//	File: PreferencesMediator.m
//
//  Abstract: Utility class for managing application's preferences
// 			 
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
//  Computer, Inc. ("Apple") in consideration of your agreement to the
//  following terms, and your use, installation, modification or
//  redistribution of this Apple software constitutes acceptance of these
//  terms.  If you do not agree with these terms, please do not use,
//  install, modify or redistribute this Apple software.
//  
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software. 
//  Neither the name, trademarks, service marks or logos of Apple Computer,
//  Inc. may be used to endorse or promote products derived from the Apple
//  Software without specific prior written permission from Apple.  Except
//  as expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//  
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//  
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
// 
//  Copyright (c) 2008-2009 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#import "PreferencesMediator.h"

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------------------

@implementation PreferencesMediator

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Application Startup

//---------------------------------------------------------------------------------------

- (id) initPreferencesWithName:(NSString *)thePListName
{
	self = [super init];
	
	if( self )
	{
		if( thePListName )
		{
			NSArray *components = nil;
			
			NSArray  *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
			NSString *libPath = [libPaths objectAtIndex:0];
			
			components          = [NSArray arrayWithObjects:libPath,@"Preferences",thePListName,nil];
			appPropertyListPath = [[NSString pathWithComponents:components] retain];
			
			appDefaults         = nil;
			appPropertyList     = nil;
		} // if
		else
		{
			NSLog( @">> ERROR: Preferences Mediator - Invalid Property list name" );
		} // else
	} // if
	
	return self;
} // init

//---------------------------------------------------------------------------

+ (id) preferencesWithName:(NSString *)thePListName
{
	return( [[[PreferencesMediator allocWithZone:[self zone]] initPreferencesWithName:thePListName] autorelease] );
} // preferencesWithName

//---------------------------------------------------------------------------------------

- (void) cleanUpPrefs
{
	if( appPropertyList )
	{
		[appPropertyList release];
		
		appPropertyList = nil;
	} // if
	
	if( appDefaults )
	{
		[appDefaults release];
		
		appDefaults = nil;
	} // if
	
	if( appPropertyListPath )
	{
		[appPropertyListPath  release];
		
		appPropertyListPath = nil;
	} // if
} // cleanUpPrefs

//---------------------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpPrefs];
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------------------

- (NSDictionary *) defaults
{
	return( appDefaults );
} // defaults

//---------------------------------------------------------------------------------------

- (BOOL) exists
{
	return( [[NSFileManager defaultManager] fileExistsAtPath:appPropertyListPath] );
} // exists

//---------------------------------------------------------------------------------------

- (id) objectForKey:(id)theKey
{
	id object = nil;
	
	if( theKey )
	{
		object = [appDefaults objectForKey:theKey];
	} // object
	
	return( object );
} // objectForKey

//---------------------------------------------------------------------------------------

- (NSArray *) objectsForKeys:(NSArray *)theKeys
{
	NSMutableArray  *objects = nil;
	
	if( theKeys )
	{
		objects = [NSMutableArray arrayWithCapacity:[theKeys count]];
		
		if( objects )
		{
			id  key    = nil;
			id  object = nil;
			
			for( key in theKeys ) 
			{
				object = [appDefaults objectForKey:key];
				
				[objects addObject:object];
			} // for
		} // if
	} // if
	
	return( objects );
} // objectsForKeys

//---------------------------------------------------------------------------------------

- (void) setObject:(id)theObject
			forKey:(NSString *)theKey
{
	if( theObject && theKey )
	{
		[appDefaults setObject:theObject
						forKey:theKey];
	} // if
} // setObject

//---------------------------------------------------------------------------------------

- (void) setObjects:(NSArray *)theObjects
			forKeys:(NSArray *)theKeys
{
	if( theObjects && theKeys )
	{
		id          preferencesObject = nil;
		NSString   *preferencesKey    = nil;
		NSUInteger  preferencesIndex  = 0;
		
		if( appPropertyList == nil )
		{
			appDefaults = [[NSMutableDictionary alloc] initWithCapacity:[theKeys count]];
		} // else

		for( preferencesKey in theKeys ) 
		{
			preferencesObject = [theObjects objectAtIndex:preferencesIndex];
			
			[appDefaults setObject:preferencesObject 
							forKey:preferencesKey];
			
			preferencesIndex++;
		} // for
	} // if
} // setObjects

//---------------------------------------------------------------------------------------

- (BOOL) read
{
	BOOL plistExists   = [[NSFileManager defaultManager] fileExistsAtPath:appPropertyListPath];
	BOOL plistRedeable = [[NSFileManager defaultManager] isReadableFileAtPath:appPropertyListPath];
	BOOL plistIsValid  = plistExists && plistRedeable;
	
	if( plistIsValid )
	{
		NSData *appPropertyListData = [NSData dataWithContentsOfFile:appPropertyListPath];
		
		if( appPropertyListData )
		{
			NSString  *errorDescription = nil;
			
			appPropertyList = [NSPropertyListSerialization propertyListFromData:appPropertyListData
															   mutabilityOption:NSPropertyListImmutable
																		 format:&appPropertyListFormat
															   errorDescription:&errorDescription];
			
			if( appPropertyList )
			{
				[appPropertyList retain];
				
				appDefaults  = [[NSMutableDictionary alloc] initWithDictionary:appPropertyList];
			} // if
			else
			{
				NSLog( @">> ERROR: Preferences Mediator - Property List From Data: %@", errorDescription );
				
				[errorDescription release];
			} // else
		} // if
	} // if
	
	return( plistIsValid );
} // read

//---------------------------------------------------------------------------------------

- (BOOL) write
{
	BOOL       plistWritten = NO;
	NSString  *dataError    = nil;
	NSData    *plistData    = [NSPropertyListSerialization dataFromPropertyList:appDefaults
																		 format:NSPropertyListXMLFormat_v1_0
															   errorDescription:&dataError];
	
	if( plistData )
	{
		NSError *writeError = nil;
		
		plistWritten = [plistData writeToFile:appPropertyListPath 
									  options:NSAtomicWrite
										error:&writeError];
		
		if( !plistWritten )
		{
			NSLog( @">> ERROR: Preferences Mediator - Writing to a property list file: %@", writeError );
			
			[writeError release];
		} // if
	} // if
	else
	{
		NSLog( @">> ERROR:  Preferences Mediator - Data From Property List: %@", dataError );
		
		[dataError release];
	} // else
	
	return( plistWritten );
} // write

//---------------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
