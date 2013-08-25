//---------------------------------------------------------------------------
//
//	File: ViewAnimation.m
//
//  Abstract: Utility class to animate views and windows
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
//  Copyright (c) 2009 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import "ViewAnimation.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation ViewAnimation

//---------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return( nil );
} // init

//---------------------------------------------------------------------------

- (id) initViewAnimation:(id)theAnimationObject  
				  effect:(NSString *)theAnimationEffect 
				duration:(const NSTimeInterval)theAnimationDuration 
				   curve:(const NSAnimationCurve)theAnimationCurve
					mode:(const NSAnimationBlockingMode)theAnimationMode
{
	self = [super init];
	
	if( self )
	{
		// Create the attributes dictionary for the object we wish to animate.
		
		viewDictionary = [NSMutableDictionary new];
		
		if( viewDictionary )
		{
			// Set the target object
			
			[viewDictionary setObject:theAnimationObject 
							   forKey:NSViewAnimationTargetKey];
			
			// We wish to animate an object with a frame
			
			NSRect viewSize = [theAnimationObject frame];
			
			[viewDictionary setObject:[NSValue valueWithRect:viewSize] 
							   forKey:NSViewAnimationEndFrameKey];
			
			// Set this object to use the effect
			
			[viewDictionary setObject:theAnimationEffect  
							   forKey:NSViewAnimationEffectKey];
			
			// Create the view animation object.
			
			viewAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:viewDictionary, nil]];
			
			if( viewAnimation )
			{
				// Set some additional attributes for the animation.
				
				[viewAnimation setAnimationBlockingMode:theAnimationMode];
				[viewAnimation setDuration:theAnimationDuration];
				[viewAnimation setAnimationCurve:theAnimationCurve];
			} // if
		} // if
	} // if
	
	return( self );
} // initViewAnimation

//---------------------------------------------------------------------------

- (void) cleanUpViewAnimation
{
	if( viewDictionary )
	{
		[viewDictionary release];
		
		viewDictionary = nil;
	} // if
	
	if( viewAnimation )
	{
		[viewAnimation release];
		
		viewAnimation = nil;
	} // if
} // cleanUpViewAnimation

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpViewAnimation];
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

- (void) start
{
	[viewAnimation startAnimation];
} // start

//---------------------------------------------------------------------------

- (void) stop
{
	[viewAnimation stopAnimation];
} // stop

//---------------------------------------------------------------------------

- (BOOL) isStarted
{
	return( [viewAnimation isAnimating] );
} // isStarted

//---------------------------------------------------------------------------

- (BOOL) isStopped
{
	return( ![viewAnimation isAnimating] );
} // isStopped

//---------------------------------------------------------------------------

- (void) setDuration:(const NSTimeInterval)theAnimationDuration
{
	[viewAnimation setDuration:theAnimationDuration];
} // setDuration

//---------------------------------------------------------------------------

- (void) setCurve:(const NSAnimationCurve)theAnimationCurve
{
	[viewAnimation setAnimationCurve:theAnimationCurve];
} // setCurve

//---------------------------------------------------------------------------

- (void) setBlockingMode:(const NSAnimationBlockingMode)theAnimationMode
{
	[viewAnimation setAnimationBlockingMode:theAnimationMode];
} // setBlockingMode

//---------------------------------------------------------------------------

- (void) setEffect:(NSString *)theAnimationEffect 
{
	[viewDictionary setObject:theAnimationEffect  
					   forKey:NSViewAnimationEffectKey];
	
	[viewAnimation setViewAnimations:[NSArray arrayWithObjects:viewDictionary, nil]];
} // setEffect

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

